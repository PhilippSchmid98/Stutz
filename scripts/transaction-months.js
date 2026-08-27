'use strict';

const TIME_ZONE = 'Europe/Zurich';

function asDate(value) {
    if (value && typeof value.toDate === 'function') {
        return value.toDate();
    }

    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) {
        throw new Error(`Invalid transaction date: ${String(value)}`);
    }
    return date;
}

function monthKeyFromDate(value) {
    const date = asDate(value);
    const parts = new Intl.DateTimeFormat('en-CA', {
        timeZone: TIME_ZONE,
        year: 'numeric',
        month: '2-digit',
    }).formatToParts(date);
    const year = parts.find((part) => part.type === 'year')?.value;
    const month = parts.find((part) => part.type === 'month')?.value;

    if (!year || !month) {
        throw new Error(`Could not derive month from date: ${date.toISOString()}`);
    }
    return `${year}-${month}`;
}

function countMonthKeys(values) {
    const counts = new Map();
    for (const value of values) {
        const key = monthKeyFromDate(value);
        counts.set(key, (counts.get(key) ?? 0) + 1);
    }
    return new Map([...counts.entries()].sort(([left], [right]) =>
        left.localeCompare(right),
    ));
}

function summarizeTransactions(transactions) {
    const summaries = new Map();
    for (const transaction of transactions) {
        const monthKey = monthKeyFromDate(transaction.dateTime);
        if (typeof transaction.expenseNodeId !== 'string'
            || transaction.expenseNodeId.length === 0) {
            throw new Error(`Invalid expense node ID for month ${monthKey}`);
        }
        if (typeof transaction.amount !== 'number'
            || !Number.isFinite(transaction.amount)) {
            throw new Error(`Invalid transaction amount for month ${monthKey}`);
        }

        const summary = summaries.get(monthKey) ?? {
            transactionCount: 0,
            categoryTotals: {},
        };
        summary.transactionCount += 1;
        summary.categoryTotals[transaction.expenseNodeId] = (
            summary.categoryTotals[transaction.expenseNodeId] ?? 0
        ) + transaction.amount;
        summaries.set(monthKey, summary);
    }

    return new Map([...summaries.entries()].sort(([left], [right]) =>
        left.localeCompare(right),
    ));
}

module.exports = {
    TIME_ZONE,
    countMonthKeys,
    monthKeyFromDate,
    summarizeTransactions,
};