'use strict';

const admin = require('firebase-admin');
const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, getApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { validateArchive } = require('./firestore-restore');
const { verifyBackupDirectory } = require('./firestore-backup-format');
const { storedMinorUnits } = require('./money-minor-units');
const { TIME_ZONE, summarizeTransactions } = require('./transaction-months');

const DEFAULT_PROJECT_ID = 'stutz-7ed90';
const DEFAULT_EMULATOR_HOST = '127.0.0.1:8080';
const MAX_BATCH_OPERATIONS = 500;
const MIGRATION_VERSION = 3;
const MONEY_MIGRATION_VERSION = 1;
const SOURCE_COLLECTIONS = ['transactions', 'expense_nodes', 'incomes'];

function parseArguments(argv) {
    const options = {
        apply: false,
        backupDir: null,
        emulator: false,
        projectId: process.env.GCLOUD_PROJECT || DEFAULT_PROJECT_ID,
        report: null,
        userId: null,
    };

    for (const argument of argv) {
        if (argument === '--apply') {
            options.apply = true;
        } else if (argument === '--dry-run') {
            options.apply = false;
        } else if (argument === '--emulator') {
            options.emulator = true;
        } else if (argument.startsWith('--backup-dir=')) {
            options.backupDir = path.resolve(argument.slice('--backup-dir='.length));
        } else if (argument.startsWith('--project-id=')) {
            options.projectId = argument.slice('--project-id='.length);
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
    return options;
}

async function validateMigrationBackup(options) {
    if (options.backupDir == null) {
        if (options.apply) {
            throw new Error('--apply requires --backup-dir=<all-scope-backup>');
        }
        return null;
    }

    const manifest = await verifyBackupDirectory(options.backupDir);
    if (manifest.scope !== 'all') {
        throw new Error('Money migration requires a scope=all backup');
    }
    const selection = await validateArchive(options.backupDir, manifest, {
        allowProjectMismatch: false,
        deleteMissing: false,
        input: options.backupDir,
        projectId: options.projectId,
        scope: 'all',
        userId: options.userId,
    });
    console.log(
        `Verified all-scope backup: ${selection.selectedDocumentCount} documents, `
        + `SHA-256 ${manifest.checksum}`,
    );
    return manifest;
}

function initializeFirestore(options) {
    if (options.emulator) {
        process.env.FIRESTORE_EMULATOR_HOST ??= DEFAULT_EMULATOR_HOST;
        const app = admin.initializeApp({ projectId: options.projectId });
        return getFirestore(app);
    }
    if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        throw new Error(
            'Set GOOGLE_APPLICATION_CREDENTIALS before scanning production data.',
        );
    }
    const app = admin.initializeApp({
        credential: applicationDefault(),
        projectId: options.projectId,
    });
    return getFirestore(app);
}

function moneyFieldForCollection(collectionId) {
    switch (collectionId) {
        case 'transactions':
            return { legacyField: 'amount', minorField: 'amountMinor', required: true };
        case 'expense_nodes':
            return {
                legacyField: 'plannedAmount',
                minorField: 'plannedAmountMinor',
                required: false,
            };
        case 'incomes':
            return { legacyField: 'amount', minorField: 'amountMinor', required: true };
        default:
            throw new Error(`Unsupported money collection: ${collectionId}`);
    }
}

function normalizeSourceDocument(document, { forceWrite = false } = {}) {
    const collectionId = document.path.split('/')[2];
    const fields = moneyFieldForCollection(collectionId);
    const normalized = storedMinorUnits(document.data, {
        ...fields,
        label: document.path,
    });
    if (normalized == null) {
        return { normalized: null, operation: null, rounding: null };
    }

    const operation = normalized.needsWrite || forceWrite
        ? {
            data: { [fields.minorField]: normalized.minor },
            deleteFields: Object.hasOwn(document.data, fields.legacyField)
                ? [fields.legacyField]
                : [],
            path: document.path,
            type: 'set',
        }
        : null;
    const rounding = normalized.adjustmentMajor === 0
        ? null
        : {
            adjustmentMajor: normalized.adjustmentMajor,
            path: document.path,
        };
    return { normalized, operation, rounding };
}

function mapsEqual(left, right) {
    const leftEntries = Object.entries(left).sort(([a], [b]) => a.localeCompare(b));
    const rightEntries = Object.entries(right).sort(([a], [b]) => a.localeCompare(b));
    return JSON.stringify(leftEntries) === JSON.stringify(rightEntries);
}

function buildUserPlan(userId, records) {
    const operations = [];
    const roundingAdjustments = [];
    const normalizedTransactions = [];
    let sourceTotalMinor = 0;
    const existingMetaRecord = (records.transactionMonths ?? []).find(
        (document) => document.path.endsWith('/transactionMonths/_meta'),
    );
    const moneyMigrationComplete =
        existingMetaRecord?.data?.moneyMigrationVersion === MONEY_MIGRATION_VERSION
        && existingMetaRecord?.data?.moneyMigrationStatus === 'complete';

    for (const collectionId of SOURCE_COLLECTIONS) {
        for (const document of records[collectionId] ?? []) {
            const converted = normalizeSourceDocument(document, {
                forceWrite: !moneyMigrationComplete,
            });
            if (converted.operation != null) operations.push(converted.operation);
            if (converted.rounding != null) roundingAdjustments.push(converted.rounding);
            if (collectionId === 'transactions') {
                const transaction = {
                    amountMinor: converted.normalized.minor,
                    dateTime: document.data.dateTime,
                    expenseNodeId: document.data.expenseNodeId,
                };
                normalizedTransactions.push(transaction);
                sourceTotalMinor += transaction.amountMinor;
            }
        }
    }

    const summaries = summarizeTransactions(normalizedTransactions);
    const existingMonths = new Map(
        (records.transactionMonths ?? []).map((document) => [
            document.path.split('/').at(-1),
            document,
        ]),
    );
    let summaryTotalMinor = 0;

    for (const [monthKey, summary] of summaries) {
        for (const value of Object.values(summary.categoryTotalsMinor)) {
            summaryTotalMinor += value;
        }
        const existing = existingMonths.get(monthKey);
        existingMonths.delete(monthKey);
        const [year, month] = monthKey.split('-').map(Number);
        const data = {
            categoryTotalsMinor: summary.categoryTotalsMinor,
            month,
            monthKey,
            transactionCount: summary.transactionCount,
            year,
        };
        const isCurrent = moneyMigrationComplete
            && existing != null
            && !Object.hasOwn(existing.data, 'categoryTotals')
            && existing.data.monthKey === monthKey
            && existing.data.year === year
            && existing.data.month === month
            && existing.data.transactionCount === summary.transactionCount
            && mapsEqual(
                existing.data.categoryTotalsMinor ?? {},
                summary.categoryTotalsMinor,
            );
        if (!isCurrent) {
            operations.push({
                data,
                deleteFields: existing != null
                    && Object.hasOwn(existing.data, 'categoryTotals')
                    ? ['categoryTotals']
                    : [],
                path: `users/${userId}/transactionMonths/${monthKey}`,
                type: 'set',
            });
        }
    }

    const existingMeta = existingMonths.get('_meta');
    existingMonths.delete('_meta');
    for (const document of existingMonths.values()) {
        operations.push({ path: document.path, type: 'delete' });
    }

    if (existingMeta?.data?.migrationVersion !== MIGRATION_VERSION
        || existingMeta?.data?.status !== 'complete'
        || existingMeta?.data?.timezone !== TIME_ZONE
        || existingMeta?.data?.moneyMigrationVersion !== MONEY_MIGRATION_VERSION
        || existingMeta?.data?.moneyMigrationStatus !== 'complete') {
        operations.push({
            data: {
                migrationVersion: MIGRATION_VERSION,
                moneyMigrationStatus: 'complete',
                moneyMigrationVersion: MONEY_MIGRATION_VERSION,
                status: 'complete',
                timezone: TIME_ZONE,
            },
            deleteFields: [],
            path: `users/${userId}/transactionMonths/_meta`,
            serverTimestampFields: ['updatedAt'],
            type: 'set',
        });
    }

    if (sourceTotalMinor !== summaryTotalMinor) {
        throw new Error(
            `${userId}: source total ${sourceTotalMinor} does not match `
            + `summary total ${summaryTotalMinor}`,
        );
    }

    return {
        operations,
        report: {
            monthCount: summaries.size,
            operationCount: operations.length,
            roundingAdjustments,
            sourceTotalMinor,
            summaryTotalMinor,
            transactionCount: normalizedTransactions.length,
            userId,
        },
    };
}

async function loadUserRecords(userReference) {
    const result = {};
    for (const collectionId of [...SOURCE_COLLECTIONS, 'transactionMonths']) {
        const snapshot = await userReference.collection(collectionId).get();
        result[collectionId] = snapshot.docs.map((document) => ({
            data: document.data(),
            path: document.ref.path,
        }));
    }
    return result;
}

async function discoverUserReferences(db, userId) {
    if (userId != null) return [db.collection('users').doc(userId)];

    const references = new Map();
    const users = await db.collection('users').get();
    for (const user of users.docs) references.set(user.ref.path, user.ref);
    for (const collectionId of [...SOURCE_COLLECTIONS, 'transactionMonths']) {
        const snapshot = await db.collectionGroup(collectionId).get();
        for (const document of snapshot.docs) {
            const userReference = document.ref.parent.parent;
            if (userReference?.parent.id === 'users') {
                references.set(userReference.path, userReference);
            }
        }
    }
    return [...references.values()].sort((left, right) =>
        left.path.localeCompare(right.path),
    );
}

async function applyOperations(db, operations) {
    for (let index = 0; index < operations.length; index += MAX_BATCH_OPERATIONS) {
        const batch = db.batch();
        for (const operation of operations.slice(index, index + MAX_BATCH_OPERATIONS)) {
            const reference = db.doc(operation.path);
            if (operation.type === 'delete') {
                batch.delete(reference);
                continue;
            }
            const data = { ...operation.data };
            for (const field of operation.deleteFields ?? []) {
                data[field] = FieldValue.delete();
            }
            for (const field of operation.serverTimestampFields ?? []) {
                data[field] = FieldValue.serverTimestamp();
            }
            batch.set(reference, data, { merge: true });
        }
        await batch.commit();
    }
}

async function writeReport(reportPath, report) {
    if (reportPath == null) return;
    await fs.promises.mkdir(path.dirname(reportPath), { recursive: true });
    await fs.promises.writeFile(
        reportPath,
        `${JSON.stringify(report, null, 2)}\n`,
        'utf8',
    );
}

async function main(argv = process.argv.slice(2)) {
    const options = parseArguments(argv);
    const backup = await validateMigrationBackup(options);
    const db = initializeFirestore(options);
    const app = getApp();
    const report = {
        applied: options.apply,
        backupChecksum: backup?.checksum ?? null,
        generatedAt: new Date().toISOString(),
        projectId: options.projectId,
        users: [],
    };

    try {
        const userReferences = await discoverUserReferences(db, options.userId);
        for (const userReference of userReferences) {
            const records = await loadUserRecords(userReference);
            const plan = buildUserPlan(userReference.id, records);
            if (options.apply) {
                await applyOperations(db, plan.operations);
                const verification = buildUserPlan(
                    userReference.id,
                    await loadUserRecords(userReference),
                );
                if (verification.operations.length !== 0) {
                    throw new Error(
                        `${userReference.id}: post-migration verification has `
                        + `${verification.operations.length} pending operations`,
                    );
                }
            }
            report.users.push(plan.report);
            console.log(
                `${options.apply ? '[apply]' : '[dry-run]'} ${userReference.id}: `
                + `${plan.report.transactionCount} transactions, `
                + `${plan.report.monthCount} months, `
                + `${plan.report.operationCount} operations, `
                + `${plan.report.roundingAdjustments.length} rounding adjustments`,
            );
        }
    } finally {
        await app.delete();
    }

    await writeReport(options.report, report);
    return report;
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exitCode = 1;
    });
}

module.exports = {
    MIGRATION_VERSION,
    MONEY_MIGRATION_VERSION,
    applyOperations,
    buildUserPlan,
    loadUserRecords,
    moneyFieldForCollection,
    normalizeSourceDocument,
    parseArguments,
    validateMigrationBackup,
};