'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { Readable } = require('node:stream');
const test = require('node:test');
const { createBackup } = require('../scripts/firestore-backup');
const {
    countMonthKeys,
    monthKeyFromDate,
} = require('../scripts/transaction-months');
const {
    buildOperations: buildMigrationOperations,
    parseArguments,
    validateMigrationBackup,
} = require('../scripts/migrate-transaction-months');

test('groups transaction dates by Europe/Zurich month', () => {
    const counts = countMonthKeys([
        '2026-01-31T23:30:00.000Z',
        '2026-02-01T00:30:00.000Z',
        '2026-03-31T22:30:00.000Z',
        '2026-03-15T12:00:00.000Z',
    ]);

    assert.deepEqual([...counts.entries()], [
        ['2026-02', 2],
        ['2026-03', 1],
        ['2026-04', 1],
    ]);
});

test('accepts Firestore-like timestamps', () => {
    assert.equal(
        monthKeyFromDate({
            toDate: () => new Date('2026-08-20T12:00:00.000Z'),
        }),
        '2026-08',
    );
});

test('builds deterministic month writes and puts completion last', () => {
    const userReference = {
        collection: () => ({
            doc: (id) => ({ id }),
        }),
    };
    const operations = buildMigrationOperations(
        userReference,
        new Map([['2026-01', 2], ['2026-03', 1]]),
        ['2026-01', '2025-12', '_meta'],
    );

    assert.deepEqual(
        operations.map((operation) => operation.type),
        ['set', 'set', 'delete', 'set'],
    );
    assert.equal(operations[0].reference.id, '2026-01');
    assert.equal(operations[1].reference.id, '2026-03');
    assert.equal(operations[2].reference.id, '2025-12');
    assert.equal(operations[3].reference.id, '_meta');
    assert.equal(operations[3].data.status, 'complete');
});

test('requires and validates a transaction backup before migration writes', async () => {
    await assert.rejects(
        validateMigrationBackup(parseArguments(['--require-backup', '--dry-run'])),
        /requires --backup-dir/,
    );

    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'stutz-migration-test-'));
    const backupDir = path.join(root, 'backup');
    await createBackup(
        {
            collectionGroup: () => ({
                orderBy: () => ({
                    stream: () => Readable.from([{
                        ref: { path: 'users/u1/transactions/t1' },
                        data: () => ({ amount: 1 }),
                    }]),
                }),
            }),
        },
        {
            dryRun: false,
            emulator: true,
            force: false,
            maxDocuments: null,
            output: backupDir,
            projectId: 'test-project',
            scope: 'transactions',
            userId: null,
        },
    );

    const options = parseArguments([
        '--dry-run',
        '--require-backup',
        `--backup-dir=${backupDir}`,
        '--project-id=test-project',
    ]);
    const manifest = await validateMigrationBackup(options);
    assert.equal(manifest.projectId, 'test-project');

    await assert.rejects(
        validateMigrationBackup({
            ...options,
            projectId: 'different-project',
        }),
        /does not match/,
    );
});