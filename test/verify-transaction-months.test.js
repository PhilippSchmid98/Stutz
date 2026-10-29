'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const { reconcileUser } = require('../scripts/verify-transaction-months');

function transaction({
    amountMinor = 2500,
    categoryId = 'groceries',
    id = 'transaction-1',
    month = 6,
} = {}) {
    return {
        data: {
            amountMinor,
            dateTime: `2026-${String(month).padStart(2, '0')}-15T12:00:00.000Z`,
            expenseNodeId: categoryId,
        },
        path: `users/user-1/transactions/${id}`,
    };
}

function summary({
    categoryTotalsMinor = { groceries: 2500 },
    month = 6,
    transactionCount = 1,
} = {}) {
    const monthKey = `2026-${String(month).padStart(2, '0')}`;
    return {
        data: {
            categoryTotalsMinor,
            month,
            monthKey,
            transactionCount,
            year: 2026,
        },
        path: `users/user-1/transactionMonths/${monthKey}`,
    };
}

test('accepts matching transaction-month totals', () => {
    const result = reconcileUser(
        'user-1',
        [transaction()],
        [summary()],
    );

    assert.equal(result.issueCount, 0);
});

test('reports the stale category total left after recategorizing', () => {
    const result = reconcileUser(
        'user-1',
        [transaction({ categoryId: 'leisure' })],
        [summary({
            categoryTotalsMinor: { leisure: 2500, wellness: 40000 },
        })],
    );

    assert.deepEqual(result.issues, [{
        actual: { leisure: 2500, wellness: 40000 },
        expected: { leisure: 2500 },
        monthKey: '2026-06',
        path: 'users/user-1/transactionMonths/2026-06',
        type: 'category-totals-mismatch',
        userId: 'user-1',
    }]);
});

test('reports missing and unexpected month summaries', () => {
    const result = reconcileUser(
        'user-1',
        [transaction({ month: 6 })],
        [summary({ month: 7 })],
    );

    assert.deepEqual(
        result.issues.map((issue) => [issue.type, issue.monthKey]),
        [
            ['missing-summary', '2026-06'],
            ['unexpected-summary', '2026-07'],
        ],
    );
});
