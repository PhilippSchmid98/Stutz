'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { Readable } = require('node:stream');
const test = require('node:test');
const admin = require('firebase-admin');
const { GeoPoint, getFirestore, Timestamp } = require('firebase-admin/firestore');
const {
    createBackup,
} = require('../scripts/firestore-backup');
const format = require('../scripts/firestore-backup-format');
const {
    restoreBackup,
    validateArchive,
} = require('../scripts/firestore-restore');

function temporaryDirectory() {
    return fs.mkdtempSync(path.join(os.tmpdir(), 'stutz-backup-test-'));
}

function backupOptions(output, overrides = {}) {
    return {
        dryRun: false,
        emulator: true,
        force: false,
        maxDocuments: null,
        output,
        projectId: 'test-project',
        scope: 'transactions',
        userId: null,
        ...overrides,
    };
}

function restoreOptions(input, overrides = {}) {
    return {
        allowProjectMismatch: false,
        confirm: true,
        deleteMissing: false,
        dryRun: false,
        emulator: true,
        input,
        journal: null,
        projectId: 'test-project',
        resume: false,
        scope: null,
        userId: null,
        ...overrides,
    };
}

function fakeBackupDb(documents) {
    const query = {
        stream: () => Readable.from(documents),
    };
    return {
        collectionGroup: () => ({
            orderBy: () => query,
        }),
    };
}

function fakeRestoreDb(existingTransactionPaths = []) {
    const commits = [];
    return {
        commits,
        doc: (documentPath) => ({ path: documentPath }),
        collection: () => ({
            doc: () => ({
                collection: () => ({
                    get: async () => ({
                        docs: existingTransactionPaths.map((documentPath) => ({
                            ref: { path: documentPath },
                        })),
                    }),
                }),
            }),
        }),
        batch: () => {
            const operations = [];
            return {
                set: (reference, data) => operations.push({ data, reference }),
                delete: (reference) => operations.push({ reference }),
                commit: async () => commits.push(operations),
            };
        },
    };
}

async function makeTransactionBackup(documents, overrides = {}) {
    const directory = temporaryDirectory();
    const output = path.join(directory, 'archive');
    await createBackup(
        fakeBackupDb(documents),
        backupOptions(output, overrides),
    );
    return output;
}

test('round-trips tagged Firestore values without losing precision', async () => {
    const app = admin.initializeApp(
        { projectId: 'backup-format-test' },
        `backup-format-${Date.now()}`,
    );
    try {
        const firestore = getFirestore(app);
        const original = {
            timestamp: new Timestamp(1234567890, 987654321),
            geoPoint: new GeoPoint(47.3769, 8.5417),
            reference: firestore.doc('users/u1/transactions/t1'),
            bytes: Buffer.from([0, 1, 254, 255]),
            array: [null, false, 'text', NaN, Infinity, -Infinity],
            map: { zulu: 2, alpha: 1, '__firestoreType': 'literal' },
            undefinedValue: undefined,
        };
        const encoded = format.encodeDocumentData(original);
        const decoded = format.decodeDocumentData(encoded, firestore);

        assert.equal(decoded.timestamp.seconds, 1234567890);
        assert.equal(decoded.timestamp.nanoseconds, 987654321);
        assert.equal(decoded.geoPoint.latitude, 47.3769);
        assert.equal(decoded.reference.path, 'users/u1/transactions/t1');
        assert.deepEqual([...decoded.bytes], [0, 1, 254, 255]);
        assert.equal(Number.isNaN(decoded.array[3]), true);
        assert.equal(decoded.array[4], Infinity);
        assert.equal(decoded.array[5], -Infinity);
        assert.equal(decoded.map.alpha, 1);
        assert.equal(decoded.map.zulu, 2);
        assert.equal(decoded.map.__firestoreType, 'literal');
        assert.equal(Object.hasOwn(decoded, 'undefinedValue'), true);
        assert.equal(decoded.undefinedValue, undefined);

        const mapKeys = encoded.value.find(([key]) => key === 'map')[1].value.map(
            ([key]) => key,
        );
        assert.deepEqual(mapKeys, ['__firestoreType', 'alpha', 'zulu']);
    } finally {
        await app.delete();
    }
});

test('creates a deterministic, checksum-verified transaction archive', async () => {
    const output = await makeTransactionBackup([
        { ref: { path: 'users/u1/transactions/t1' }, data: () => ({ amount: 1 }) },
        { ref: { path: 'users/u1/transactions/t2' }, data: () => ({ amount: 2 }) },
    ]);
    const manifest = await format.verifyBackupDirectory(output);
    const lines = fs.readFileSync(format.documentsPath(output), 'utf8')
        .trim()
        .split('\n');

    assert.equal(manifest.complete, true);
    assert.equal(manifest.scope, 'transactions');
    assert.equal(manifest.documentCount, 2);
    assert.equal(lines[0].includes('users/u1/transactions/t1'), true);
    assert.equal(lines[1].includes('users/u1/transactions/t2'), true);

    fs.appendFileSync(format.documentsPath(output), 'tampered\n');
    await assert.rejects(
        format.verifyBackupDirectory(output),
        /checksum or byte count/,
    );
});

test('filters a transaction restore by user and splits writes at 500 documents', async () => {
    const documents = Array.from({ length: 501 }, (_, index) => ({
        ref: { path: `users/u1/transactions/t${String(index).padStart(3, '0')}` },
        data: () => ({ amount: index }),
    }));
    documents.push({
        ref: { path: 'users/u2/transactions/other-user' },
        data: () => ({ amount: 999 }),
    });
    const output = await makeTransactionBackup(documents);
    const db = fakeRestoreDb();
    const result = await restoreBackup(
        db,
        restoreOptions(output, { userId: 'u1' }),
    );

    assert.equal(result.restoredDocumentCount, 501);
    assert.deepEqual(db.commits.map((batch) => batch.length), [500, 1]);
    assert.equal(db.commits[0][0].reference.path, 'users/u1/transactions/t000');
    assert.equal(db.commits[1][0].data.amount, 500);
    assert.equal(fs.existsSync(format.manifestPath(output)), true);
    assert.equal(fs.existsSync(path.join(output, format.JOURNAL_FILE)), false);
});

test('dry-run validates a matching archive without writing', async () => {
    const output = await makeTransactionBackup([
        { ref: { path: 'users/u1/transactions/t1' }, data: () => ({ amount: 1 }) },
    ]);
    const options = restoreOptions(output, { dryRun: true });
    const manifest = await format.verifyBackupDirectory(output);
    const selection = await validateArchive(output, manifest, options);
    const result = await restoreBackup(null, options);

    assert.equal(selection.selectedDocumentCount, 1);
    assert.equal(result.restoredDocumentCount, 1);
});

test('rejects project mismatches and invalid restore scope', async () => {
    const output = await makeTransactionBackup([
        { ref: { path: 'users/u1/transactions/t1' }, data: () => ({ amount: 1 }) },
    ]);
    const manifest = await format.verifyBackupDirectory(output);

    await assert.rejects(
        validateArchive(output, manifest, restoreOptions(output, {
            projectId: 'different-project',
        })),
        /does not match/,
    );
    await assert.rejects(
        validateArchive(output, manifest, restoreOptions(output, { scope: 'all' })),
        /cannot be restored as all data/,
    );
});

test('requires a user-scoped transaction restore for delete-missing', async () => {
    const output = await makeTransactionBackup([
        { ref: { path: 'users/u1/transactions/t1' }, data: () => ({ amount: 1 }) },
    ]);
    const manifest = await format.verifyBackupDirectory(output);

    await assert.rejects(
        validateArchive(output, manifest, restoreOptions(output, {
            deleteMissing: true,
        })),
        /requires --scope=transactions and --user-id/,
    );
});

test('delete-missing removes only stale transactions in the selected user scope', async () => {
    const output = await makeTransactionBackup([
        { ref: { path: 'users/u1/transactions/t1' }, data: () => ({ amount: 1 }) },
    ]);
    const db = fakeRestoreDb([
        'users/u1/transactions/t1',
        'users/u1/transactions/stale',
    ]);
    const result = await restoreBackup(
        db,
        restoreOptions(output, {
            deleteMissing: true,
            scope: 'transactions',
            userId: 'u1',
        }),
    );

    assert.equal(result.restoredDocumentCount, 1);
    assert.equal(result.deletedDocumentCount, 1);
    assert.equal(db.commits.length, 2);
    assert.equal(db.commits[1][0].reference.path, 'users/u1/transactions/stale');
});
