'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const {
    legacyMajorToMinorUnits,
    storedMinorUnits,
} = require('../scripts/money-minor-units');

test('converts legacy CHF values to integer minor units', () => {
    assert.deepEqual(legacyMajorToMinorUnits(12.05), {
        adjustmentMajor: 0,
        minor: 1205,
    });
    assert.deepEqual(legacyMajorToMinorUnits(1.999), {
        adjustmentMajor: 0.001,
        minor: 200,
    });
});

test('prefers canonical minor units and marks legacy fields for removal', () => {
    assert.deepEqual(
        storedMinorUnits(
            { amountMinor: 1205, amount: 99 },
            { legacyField: 'amount', minorField: 'amountMinor' },
        ),
        {
            adjustmentMajor: 0,
            minor: 1205,
            needsWrite: true,
            source: 'minor',
        },
    );
});

test('accepts an optional missing amount for group categories', () => {
    assert.equal(
        storedMinorUnits(
            {},
            {
                legacyField: 'plannedAmount',
                minorField: 'plannedAmountMinor',
                required: false,
            },
        ),
        null,
    );
    assert.deepEqual(
        storedMinorUnits(
            { plannedAmount: null },
            {
                legacyField: 'plannedAmount',
                minorField: 'plannedAmountMinor',
                required: false,
            },
        ),
        {
            adjustmentMajor: 0,
            minor: null,
            needsWrite: true,
            source: 'empty',
        },
    );
});

test('rejects invalid canonical and legacy values', () => {
    assert.throws(
        () => storedMinorUnits(
            { amountMinor: 12.5 },
            { legacyField: 'amount', minorField: 'amountMinor' },
        ),
        /integer minor-unit/,
    );
    assert.throws(() => legacyMajorToMinorUnits(Number.NaN), /finite positive/);
    assert.throws(() => legacyMajorToMinorUnits(-1), /finite positive/);
});