'use strict';

const admin = require('firebase-admin');
const path = require('node:path');
const { applicationDefault, getApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const {
    TIME_ZONE,
    countMonthKeys,
    summarizeTransactions,
} = require('./transaction-months');
const {
    validateArchive,
} = require('./firestore-restore');
const {
    verifyBackupDirectory,
} = require('./firestore-backup-format');

const DEFAULT_PROJECT_ID = 'stutz-7ed90';
const DEFAULT_EMULATOR_HOST = '127.0.0.1:8080';
const MAX_BATCH_OPERATIONS = 500;
const MONTH_COLLECTION = 'transactionMonths';
const META_DOCUMENT = '_meta';

function parseArguments(argv) {
    const options = {
        dryRun: false,
        emulator: false,
        backupDir: null,
        requireBackup: false,
        projectId: process.env.GCLOUD_PROJECT || DEFAULT_PROJECT_ID,
        userId: null,
    };

    for (const argument of argv) {
        if (argument === '--dry-run') {
            options.dryRun = true;
        } else if (argument === '--emulator') {
            options.emulator = true;
        } else if (argument === '--require-backup') {
            options.requireBackup = true;
        } else if (argument.startsWith('--backup-dir=')) {
            options.backupDir = path.resolve(
                argument.slice('--backup-dir='.length),
            );
        } else if (argument.startsWith('--project-id=')) {
            options.projectId = argument.slice('--project-id='.length);
        } else if (argument.startsWith('--user-id=')) {
            options.userId = argument.slice('--user-id='.length);
        } else {
            throw new Error(`Unknown argument: ${argument}`);
        }
    }

    return options;
}

async function validateMigrationBackup(options) {
    if (options.backupDir == null) {
        if (options.requireBackup) {
            throw new Error(
                '--require-backup requires --backup-dir=<backup-directory>',
            );
        }
        return null;
    }

    const manifest = await verifyBackupDirectory(options.backupDir);
    const selection = await validateArchive(
        options.backupDir,
        manifest,
        {
            allowProjectMismatch: false,
            deleteMissing: false,
            input: options.backupDir,
            projectId: options.projectId,
            scope: 'transactions',
            userId: null,
        },
    );
    console.log(
        `${options.dryRun ? '[dry-run] ' : ''}Verified backup: `
        + `${selection.selectedDocumentCount} transaction documents, `
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
            'Set GOOGLE_APPLICATION_CREDENTIALS to a service-account JSON path before running against production.',
        );
    }

    const app = admin.initializeApp({
        credential: applicationDefault(),
        projectId: options.projectId,
    });
    return getFirestore(app);
}

function buildOperations(userReference, summaries, existingMonthIds) {
    const monthCollection = userReference.collection(MONTH_COLLECTION);
    const operations = [];

    for (const [monthKey, summary] of summaries) {
        const [year, month] = monthKey.split('-').map(Number);
        operations.push({
            type: 'set',
            reference: monthCollection.doc(monthKey),
            data: {
                monthKey,
                year,
                month,
                transactionCount: summary.transactionCount,
                categoryTotals: summary.categoryTotals,
            },
        });
    }

    for (const monthId of existingMonthIds) {
        if (monthId !== META_DOCUMENT && !summaries.has(monthId)) {
            operations.push({
                type: 'delete',
                reference: monthCollection.doc(monthId),
            });
        }
    }

    operations.push({
        type: 'set',
        reference: monthCollection.doc(META_DOCUMENT),
        data: {
            migrationVersion: 2,
            status: 'complete',
            timezone: TIME_ZONE,
            updatedAt: FieldValue.serverTimestamp(),
        },
    });

    return operations;
}

async function setMigrationStatus(db, userReference, status) {
    const reference = userReference.collection(MONTH_COLLECTION).doc(META_DOCUMENT);
    await db.batch().set(reference, {
        migrationVersion: 2,
        status,
        timezone: TIME_ZONE,
        updatedAt: FieldValue.serverTimestamp(),
    }).commit();
}

async function applyOperations(db, operations) {
    for (let index = 0; index < operations.length; index += MAX_BATCH_OPERATIONS) {
        const batch = db.batch();
        const chunk = operations.slice(index, index + MAX_BATCH_OPERATIONS);
        for (const operation of chunk) {
            if (operation.type === 'delete') {
                batch.delete(operation.reference);
            } else {
                batch.set(operation.reference, operation.data);
            }
        }
        await batch.commit();
    }
}

async function migrateUser(db, userReference, { dryRun, transactionRecords }) {
    let records = transactionRecords;
    if (records == null) {
        const transactionSnapshot = await userReference
            .collection('transactions')
            .select('dateTime', 'expenseNodeId', 'amount')
            .get();
        records = transactionSnapshot.docs.map((document) => ({
            dateTime: document.get('dateTime'),
            expenseNodeId: document.get('expenseNodeId'),
            amount: document.get('amount'),
        }));
    }

    const summaries = summarizeTransactions(records);
    const existingSnapshot = await userReference
        .collection(MONTH_COLLECTION)
        .get();
    const existingMonthIds = existingSnapshot.docs.map((document) => document.id);
    const operations = buildOperations(userReference, summaries, existingMonthIds);

    if (!dryRun) {
        await setMigrationStatus(db, userReference, 'running');
        await applyOperations(db, operations);
    }

    return {
        transactionCount: records.length,
        monthCount: summaries.size,
        staleMonthCount: existingMonthIds.filter(
            (monthId) => monthId !== META_DOCUMENT && !summaries.has(monthId),
        ).length,
        operationCount: operations.length,
    };
}

async function main(argv = process.argv.slice(2)) {
    const options = parseArguments(argv);
    await validateMigrationBackup(options);
    const db = initializeFirestore(options);
    const app = getApp();
    let processedUsers = 0;
    let scannedTransactions = 0;
    let writtenMonths = 0;
    let clearedMonths = 0;
    const failures = [];

    try {
        const userReferences = new Map();
        const transactionRecordsByUser = new Map();

        if (options.userId) {
            const userReference = db.collection('users').doc(options.userId);
            userReferences.set(userReference.path, userReference);
        } else {
            const usersSnapshot = await db.collection('users').get();
            for (const user of usersSnapshot.docs) {
                userReferences.set(user.ref.path, user.ref);
            }

            const transactionSnapshot = await db
                .collectionGroup('transactions')
                .select('dateTime', 'expenseNodeId', 'amount')
                .get();
            for (const document of transactionSnapshot.docs) {
                const userReference = document.ref.parent.parent;
                if (userReference == null) continue;

                userReferences.set(userReference.path, userReference);
                const records = transactionRecordsByUser.get(userReference.path) ?? [];
                records.push({
                    dateTime: document.get('dateTime'),
                    expenseNodeId: document.get('expenseNodeId'),
                    amount: document.get('amount'),
                });
                transactionRecordsByUser.set(userReference.path, records);
            }
        }

        for (const userReference of userReferences.values()) {
            const userId = userReference.id;

            try {
                const result = await migrateUser(db, userReference, {
                    ...options,
                    transactionRecords: transactionRecordsByUser.get(userReference.path),
                });
                processedUsers++;
                scannedTransactions += result.transactionCount;
                writtenMonths += result.monthCount;
                clearedMonths += result.staleMonthCount;
                console.log(
                    `${options.dryRun ? '[dry-run] ' : ''}${userId}: `
                    + `${result.transactionCount} transactions, `
                    + `${result.monthCount} months, `
                    + `${result.staleMonthCount} stale months`,
                );
            } catch (error) {
                failures.push(`${userId}: ${error.message}`);
                console.error(`Failed to migrate ${userId}:`, error);
            }
        }
    } finally {
        await app.delete();
    }

    console.log(
        `${options.dryRun ? '[dry-run] ' : ''}Processed ${processedUsers} users, `
        + `${scannedTransactions} transactions, ${writtenMonths} months, `
        + `${clearedMonths} stale months cleared.`,
    );

    if (failures.length > 0) {
        throw new Error(`Migration failed for ${failures.length} user(s).`);
    }
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exitCode = 1;
    });
}

module.exports = {
    MAX_BATCH_OPERATIONS,
    buildOperations,
    countMonthKeys,
    migrateUser,
    parseArguments,
    setMigrationStatus,
    validateMigrationBackup,
};