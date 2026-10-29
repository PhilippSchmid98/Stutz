'use strict';

const fs = require('node:fs');
const path = require('node:path');
const readline = require('node:readline');
const {
    decodeDocumentData,
    documentsPath,
    validateDocumentPath,
    verifyBackupDirectory,
} = require('./firestore-backup-format');
const { storedMinorUnits } = require('./money-minor-units');
const { summarizeTransactions } = require('./transaction-months');

function parseArguments(argv) {
    const options = {
        input: null,
        report: null,
        userId: null,
    };

    for (const argument of argv) {
        if (argument.startsWith('--input=')) {
            options.input = path.resolve(argument.slice('--input='.length));
        } else if (argument.startsWith('--report=')) {
            options.report = path.resolve(argument.slice('--report='.length));
        } else if (argument.startsWith('--user-id=')) {
            const userId = argument.slice('--user-id='.length);
            if (userId.length === 0 || userId.includes('/')) {
                throw new Error('--user-id must be a single non-empty path segment');
            }
            options.userId = userId;
        } else {
            throw new Error(`Unknown argument: ${argument}`);
        }
    }

    if (options.input == null) {
        throw new Error('Pass --input=<backup-directory>');
    }
    return options;
}

function userCollectionDocumentPath(documentPath, collectionId) {
    const segments = documentPath.split('/');
    return segments.length === 4
        && segments[0] === 'users'
        && segments[2] === collectionId;
}

function categoryTotalsMinor(data, documentPath) {
    const totals = data.categoryTotalsMinor;
    if (totals == null || typeof totals !== 'object' || Array.isArray(totals)) {
        throw new Error(`${documentPath} has no categoryTotalsMinor map`);
    }

    const result = {};
    for (const [categoryId, amountMinor] of Object.entries(totals)) {
        result[categoryId] = storedMinorUnits(
            { amountMinor },
            {
                allowZero: true,
                label: `${documentPath} category ${categoryId}`,
                legacyField: 'amount',
                minorField: 'amountMinor',
            },
        ).minor;
    }
    return result;
}

function equalTotals(left, right) {
    const leftEntries = Object.entries(left).sort(([a], [b]) => a.localeCompare(b));
    const rightEntries = Object.entries(right).sort(([a], [b]) => a.localeCompare(b));
    return JSON.stringify(leftEntries) === JSON.stringify(rightEntries);
}

function reconcileUser(userId, transactions, summaries) {
    const expected = summarizeTransactions(transactions.map(({ data, path: transactionPath }) => ({
        amountMinor: storedMinorUnits(data, {
            label: transactionPath,
            legacyField: 'amount',
            minorField: 'amountMinor',
        }).minor,
        dateTime: data.dateTime,
        expenseNodeId: data.expenseNodeId,
    })));
    const actualByMonth = new Map(
        summaries
            .filter(({ path: documentPath }) => !documentPath.endsWith('/_meta'))
            .map((summary) => [path.basename(summary.path), summary]),
    );
    const issues = [];

    for (const [monthKey, expectedSummary] of expected) {
        const actual = actualByMonth.get(monthKey);
        if (actual == null) {
            issues.push({
                type: 'missing-summary',
                userId,
                monthKey,
            });
            continue;
        }
        actualByMonth.delete(monthKey);

        const { data, path: documentPath } = actual;
        if (data.monthKey !== monthKey || data.year !== Number(monthKey.slice(0, 4))
            || data.month !== Number(monthKey.slice(5, 7))) {
            issues.push({
                type: 'invalid-summary-metadata',
                userId,
                monthKey,
                path: documentPath,
            });
        }
        if (data.transactionCount !== expectedSummary.transactionCount) {
            issues.push({
                type: 'transaction-count-mismatch',
                userId,
                monthKey,
                path: documentPath,
                actual: data.transactionCount,
                expected: expectedSummary.transactionCount,
            });
        }

        let actualTotals;
        try {
            actualTotals = categoryTotalsMinor(data, documentPath);
        } catch (error) {
            issues.push({
                type: 'invalid-category-totals',
                userId,
                monthKey,
                path: documentPath,
                message: error.message,
            });
            continue;
        }
        if (!equalTotals(actualTotals, expectedSummary.categoryTotalsMinor)) {
            issues.push({
                type: 'category-totals-mismatch',
                userId,
                monthKey,
                path: documentPath,
                actual: actualTotals,
                expected: expectedSummary.categoryTotalsMinor,
            });
        }
    }

    for (const [monthKey, summary] of actualByMonth) {
        issues.push({
            type: 'unexpected-summary',
            userId,
            monthKey,
            path: summary.path,
        });
    }

    return {
        issueCount: issues.length,
        issues,
        summaryCount: summaries.filter(({ path: documentPath }) =>
            !documentPath.endsWith('/_meta')).length,
        transactionCount: transactions.length,
        userId,
    };
}

async function loadRecords(backupDirectory, userId) {
    const users = new Map();
    const input = fs.createReadStream(documentsPath(backupDirectory), {
        encoding: 'utf8',
    });
    const lines = readline.createInterface({ crlfDelay: Infinity, input });
    let lineNumber = 0;

    try {
        for await (const line of lines) {
            lineNumber++;
            const record = JSON.parse(line);
            const documentPath = validateDocumentPath(record.path);
            if (!Object.hasOwn(record, 'data')) {
                throw new Error(`Backup line ${lineNumber} has no document data`);
            }
            if (!userCollectionDocumentPath(documentPath, 'transactions')
                && !userCollectionDocumentPath(documentPath, 'transactionMonths')) {
                continue;
            }

            const segments = documentPath.split('/');
            if (userId != null && segments[1] !== userId) continue;

            const user = users.get(segments[1]) ?? {
                summaries: [],
                transactions: [],
            };
            const document = {
                data: decodeDocumentData(record.data, {
                    doc: (referencePath) => ({ path: referencePath }),
                }),
                path: documentPath,
            };
            if (segments[2] === 'transactions') {
                user.transactions.push(document);
            } else {
                user.summaries.push(document);
            }
            users.set(segments[1], user);
        }
    } finally {
        lines.close();
        input.destroy();
    }
    return users;
}

async function verifyTransactionMonths(options) {
    const manifest = await verifyBackupDirectory(options.input);
    const users = await loadRecords(options.input, options.userId);
    const results = [...users.entries()]
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([userId, records]) =>
            reconcileUser(userId, records.transactions, records.summaries));
    const report = {
        backup: {
            checksum: manifest.checksum,
            documentCount: manifest.documentCount,
            input: options.input,
            scope: manifest.scope,
        },
        issueCount: results.reduce((sum, result) => sum + result.issueCount, 0),
        users: results,
    };

    if (options.report != null) {
        await fs.promises.writeFile(
            options.report,
            `${JSON.stringify(report, null, 2)}\n`,
            'utf8',
        );
    }
    return report;
}

async function main(argv = process.argv.slice(2)) {
    const options = parseArguments(argv);
    const report = await verifyTransactionMonths(options);
    for (const user of report.users) {
        console.log(
            `${user.userId}: ${user.transactionCount} transactions, `
            + `${user.summaryCount} summaries, ${user.issueCount} issues`,
        );
    }
    console.log(
        `${report.issueCount === 0 ? 'Verified' : 'Found'} ${report.issueCount} `
        + `transaction-month reconciliation issue(s).`,
    );
    if (report.issueCount > 0) process.exitCode = 1;
    return report;
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exitCode = 1;
    });
}

module.exports = {
    parseArguments,
    reconcileUser,
    verifyTransactionMonths,
};
