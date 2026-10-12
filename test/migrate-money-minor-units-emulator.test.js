'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const admin = require('firebase-admin');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { createBackup } = require('../scripts/firestore-backup');
const {
    applyOperations,
    buildUserPlan,
    loadUserRecords,
    validateMigrationBackup,
} = require('../scripts/migrate-money-minor-units');

const PROJECT_ID = 'stutz-money-migration-emulator';

test('migrates all money fields and rebuilds exact summaries', async () => {
    const app = admin.initializeApp(
        { projectId: PROJECT_ID },
        `money-migration-${Date.now()}`,
    );
    const db = getFirestore(app);
    const user = db.doc('users/u1');
    const backupDirectory = path.join(
        fs.mkdtempSync(path.join(os.tmpdir(), 'stutz-money-migration-')),
        'backup',
    );

    try {
        await user.set({ createdForTest: true });
        await user.collection('transactions').doc('t1').set({
            amount: 12.05,
            dateTime: Timestamp.fromDate(new Date('2026-06-15T12:00:00Z')),
            expenseNodeId: 'food',
        });
        await user.collection('transactions').doc('t2').set({
            amountMinor: 200,
            dateTime: Timestamp.fromDate(new Date('2026-06-16T12:00:00Z')),
            expenseNodeId: 'tech',
        });
        await user.collection('expense_nodes').doc('food').set({
            name: 'Food',
            plannedAmount: 100,
        });
        await user.collection('expense_nodes').doc('group').set({
            name: 'Group',
        });
        await user.collection('incomes').doc('salary').set({
            amount: 5000,
            name: 'Salary',
        });
        await user.collection('transactionMonths').doc('2026-06').set({
            categoryTotals: { food: 999 },
            transactionCount: 99,
        });
        await user.collection('transactionMonths').doc('2025-01').set({
            categoryTotals: { stale: 1 },
            transactionCount: 1,
        });

        const backup = await createBackup(db, {
            dryRun: false,
            emulator: true,
            force: false,
            maxDocuments: null,
            output: backupDirectory,
            projectId: PROJECT_ID,
            scope: 'all',
            userId: null,
        });
        assert.equal(backup.manifest.scope, 'all');
        await validateMigrationBackup({
            apply: true,
            backupDir: backupDirectory,
            projectId: PROJECT_ID,
            userId: null,
        });

        const dryRun = buildUserPlan('u1', await loadUserRecords(user));
        assert.equal(dryRun.report.sourceTotalMinor, 1405);
        assert.equal(dryRun.report.summaryTotalMinor, 1405);
        assert.ok(dryRun.operations.length > 0);

        await applyOperations(db, dryRun.operations);

        const transaction = (
            await user.collection('transactions').doc('t1').get()
        );
        const transactionData = transaction.data();
        assert.equal(transactionData.amountMinor, 1205);
        assert.equal(Number.isInteger(transactionData.amountMinor), true);
        assert.ok(transaction.protoField('amountMinor').integerValue != null);
        assert.equal(Object.hasOwn(transactionData, 'amount'), false);

        const expense = (
            await user.collection('expense_nodes').doc('food').get()
        );
        const expenseData = expense.data();
        assert.equal(expenseData.plannedAmountMinor, 10000);
        assert.ok(expense.protoField('plannedAmountMinor').integerValue != null);
        assert.equal(Object.hasOwn(expenseData, 'plannedAmount'), false);

        const income = (
            await user.collection('incomes').doc('salary').get()
        );
        const incomeData = income.data();
        assert.equal(incomeData.amountMinor, 500000);
        assert.ok(income.protoField('amountMinor').integerValue != null);
        assert.equal(Object.hasOwn(incomeData, 'amount'), false);

        const month = (
            await user.collection('transactionMonths').doc('2026-06').get()
        );
        const monthData = month.data();
        assert.deepEqual(monthData.categoryTotalsMinor, { food: 1205, tech: 200 });
        assert.ok(
            month.protoField('categoryTotalsMinor')
                .mapValue.fields.food.integerValue != null,
        );
        assert.ok(
            month.protoField('categoryTotalsMinor')
                .mapValue.fields.tech.integerValue != null,
        );
        assert.equal(monthData.transactionCount, 2);
        assert.equal(Object.hasOwn(monthData, 'categoryTotals'), false);
        assert.equal(
            (await user.collection('transactionMonths').doc('2025-01').get()).exists,
            false,
        );

        const repeated = buildUserPlan('u1', await loadUserRecords(user));
        assert.deepEqual(repeated.operations, []);
    } finally {
        await app.delete();
        fs.rmSync(path.dirname(backupDirectory), { recursive: true, force: true });
    }
});