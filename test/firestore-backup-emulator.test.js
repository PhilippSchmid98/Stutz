'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const admin = require('firebase-admin');
const {
    GeoPoint,
    getFirestore,
    Timestamp,
} = require('firebase-admin/firestore');
const { createBackup } = require('../scripts/firestore-backup');
const format = require('../scripts/firestore-backup-format');
const { restoreBackup } = require('../scripts/firestore-restore');

const PROJECT_ID = 'stutz-backup-emulator';

function temporaryDirectory() {
    return fs.mkdtempSync(path.join(os.tmpdir(), 'stutz-backup-emulator-'));
}

test('backs up and restores typed transaction documents on the emulator', async () => {
    const app = admin.initializeApp(
        { projectId: PROJECT_ID },
        `backup-emulator-${Date.now()}`,
    );
    const db = getFirestore(app);
    const output = path.join(temporaryDirectory(), 'archive');
    const transaction = db.doc('users/u1/transactions/t1');

    try {
        await transaction.set({
            amount: 42,
            attachment: Buffer.from([1, 2, 3]),
            createdAt: new Timestamp(123, 456789000),
            location: new GeoPoint(47.3769, 8.5417),
            related: db.doc('users/u1/transactions/t2'),
        });
        await db.doc('users/u1/transactions/t2').set({ amount: 7 });

        const backup = await createBackup(db, {
            dryRun: false,
            emulator: true,
            force: false,
            maxDocuments: null,
            output,
            projectId: PROJECT_ID,
            scope: 'transactions',
            userId: null,
        });
        assert.equal(backup.manifest.documentCount, 2);
        await transaction.delete();

        const result = await restoreBackup(db, {
            allowProjectMismatch: false,
            confirm: false,
            deleteMissing: false,
            dryRun: false,
            emulator: true,
            input: output,
            journal: null,
            projectId: PROJECT_ID,
            resume: false,
            scope: null,
            userId: null,
        });
        assert.equal(result.restoredDocumentCount, 2);

        const restored = await transaction.get();
        const data = restored.data();
        assert.equal(data.amount, 42);
        assert.equal(data.createdAt.seconds, 123);
        assert.equal(data.createdAt.nanoseconds, 456789000);
        assert.deepEqual([...data.attachment], [1, 2, 3]);
        assert.equal(data.related.path, 'users/u1/transactions/t2');
    } finally {
        await app.delete();
    }
});
