'use strict';

const assert = require('node:assert/strict');
const path = require('node:path');
const test = require('node:test');
const {
    buildUserPlan,
    parseArguments,
    validateMigrationBackup,
} = require('../scripts/migrate-money-minor-units');

function records({ canonical = false } = {}) {
    const amountData = canonical ? { amountMinor: 1205 } : { amount: 12.05 };
    const plannedData = canonical
        ? { plannedAmountMinor: 10000 }
        : { plannedAmount: 100 };
    const incomeData = canonical ? { amountMinor: 500000 } : { amount: 5000 };
    const monthData = canonical
        ? {
            categoryTotalsMinor: { food: 1205 },
            month: 6,
            monthKey: '2026-06',
            transactionCount: 1,
            year: 2026,
        }
        : { categoryTotals: { food: 12.05 }, transactionCount: 1 };
    return {
        expense_nodes: [{
            data: plannedData,
            path: 'users/u1/expense_nodes/food',
        }],
        incomes: [{ data: incomeData, path: 'users/u1/incomes/salary' }],
        transactionMonths: [
            { data: monthData, path: 'users/u1/transactionMonths/2026-06' },
            {
                data: canonical
                    ? {
                        migrationVersion: 3,
                        moneyMigrationStatus: 'complete',
                        moneyMigrationVersion: 1,
                        status: 'complete',
                        timezone: 'Europe/Zurich',
                    }
                    : { migrationVersion: 2, status: 'complete' },
                path: 'users/u1/transactionMonths/_meta',
            },
        ],
        transactions: [{
            data: {
                ...amountData,
                dateTime: '2026-06-15T12:00:00.000Z',
                expenseNodeId: 'food',
            },
            path: 'users/u1/transactions/t1',
        }],
    };
}

test('builds source conversion, exact summaries, and reconciliation', () => {
    const plan = buildUserPlan('u1', records());

    assert.equal(plan.report.sourceTotalMinor, 1205);
    assert.equal(plan.report.summaryTotalMinor, 1205);
    assert.equal(plan.report.roundingAdjustments.length, 0);
    assert.equal(plan.operations.length, 5);
    const transaction = plan.operations.find((operation) =>
        operation.path.endsWith('/transactions/t1'),
    );
    assert.deepEqual(transaction.data, { amountMinor: 1205 });
    assert.deepEqual(transaction.deleteFields, ['amount']);
    const month = plan.operations.find((operation) =>
        operation.path.endsWith('/transactionMonths/2026-06'),
    );
    assert.deepEqual(month.data.categoryTotalsMinor, { food: 1205 });
    assert.deepEqual(month.deleteFields, ['categoryTotals']);
});

test('a repeated plan against canonical data has an empty delta', () => {
    const plan = buildUserPlan('u1', records({ canonical: true }));
    assert.deepEqual(plan.operations, []);
    assert.equal(plan.report.operationCount, 0);
});

test('reports legacy rounding adjustments without hiding them', () => {
    const input = records();
    input.transactions[0].data.amount = 1.999;
    const plan = buildUserPlan('u1', input);

    assert.deepEqual(plan.report.roundingAdjustments, [{
        adjustmentMajor: 0.001,
        path: 'users/u1/transactions/t1',
    }]);
    assert.equal(plan.report.sourceTotalMinor, 200);
    assert.equal(plan.report.summaryTotalMinor, 200);
});

test('apply mode requires a verified all-scope backup', async () => {
    await assert.rejects(
        validateMigrationBackup(parseArguments(['--apply'])),
        /requires --backup-dir/,
    );

    const transactionBackup = path.resolve(
        'backups/firestore-transactions-2026-08-25',
    );
    await assert.rejects(
        validateMigrationBackup(parseArguments([
            '--apply',
            `--backup-dir=${transactionBackup}`,
        ])),
        /scope=all/,
    );
});