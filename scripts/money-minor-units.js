'use strict';

const MAX_MONEY_MINOR_UNITS = 99999999999;

function assertMinorUnits(value, { allowZero = false, label = 'money value' } = {}) {
    if (!Number.isSafeInteger(value)
        || value < 0
        || (!allowZero && value === 0)
        || value > MAX_MONEY_MINOR_UNITS) {
        throw new Error(`${label} must be a valid integer minor-unit value`);
    }
    return value;
}

function legacyMajorToMinorUnits(
    value,
    { allowZero = false, label = 'legacy money value' } = {},
) {
    if (typeof value !== 'number'
        || !Number.isFinite(value)
        || value < 0
        || (!allowZero && value === 0)) {
        throw new Error(`${label} must be a finite positive major-unit value`);
    }

    const minor = Math.round((value + Number.EPSILON) * 100);
    assertMinorUnits(minor, { allowZero, label });
    return {
        adjustmentMajor: Number((minor / 100 - value).toFixed(12)),
        minor,
    };
}

function storedMinorUnits(
    data,
    {
        allowZero = false,
        label = 'money value',
        legacyField,
        minorField,
        required = true,
    },
) {
    const hasMinor = Object.hasOwn(data, minorField);
    const hasLegacy = Object.hasOwn(data, legacyField);

    if (!required && !hasMinor && !hasLegacy) return null;

    if (!required
        && (!hasMinor || data[minorField] == null)
        && (!hasLegacy || data[legacyField] == null)) {
        return {
            adjustmentMajor: 0,
            minor: null,
            needsWrite: hasLegacy,
            source: hasMinor ? 'minor' : 'empty',
        };
    }

    if (hasMinor) {
        return {
            adjustmentMajor: 0,
            minor: assertMinorUnits(data[minorField], { allowZero, label }),
            needsWrite: hasLegacy,
            source: 'minor',
        };
    }
    if (hasLegacy) {
        const converted = legacyMajorToMinorUnits(data[legacyField], {
            allowZero,
            label,
        });
        return {
            ...converted,
            needsWrite: true,
            source: 'legacy',
        };
    }
    if (!required) return null;
    throw new Error(`${label} is missing ${minorField}`);
}

module.exports = {
    MAX_MONEY_MINOR_UNITS,
    assertMinorUnits,
    legacyMajorToMinorUnits,
    storedMinorUnits,
};