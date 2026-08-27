'use strict';

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const {
    DocumentReference,
    GeoPoint,
    Timestamp,
} = require('firebase-admin/firestore');

const BACKUP_SCHEMA_VERSION = 1;
const DOCUMENTS_FILE = 'documents.ndjson';
const MANIFEST_FILE = 'manifest.json';
const PARTIAL_SUFFIX = '.partial';
const JOURNAL_FILE = 'restore.journal.json';

function encodeValue(value) {
    if (value === null) return null;
    if (value === undefined) return { __firestoreType: 'undefined' };
    if (value instanceof Timestamp) {
        return {
            __firestoreType: 'timestamp',
            seconds: value.seconds,
            nanoseconds: value.nanoseconds,
        };
    }
    if (value instanceof GeoPoint) {
        return {
            __firestoreType: 'geoPoint',
            latitude: value.latitude,
            longitude: value.longitude,
        };
    }
    if (value instanceof DocumentReference) {
        return {
            __firestoreType: 'documentReference',
            path: value.path,
        };
    }
    if (typeof value === 'number') {
        if (Number.isNaN(value)) {
            return { __firestoreType: 'number', value: 'NaN' };
        }
        if (value === Infinity) {
            return { __firestoreType: 'number', value: 'Infinity' };
        }
        if (value === -Infinity) {
            return { __firestoreType: 'number', value: '-Infinity' };
        }
        return value;
    }
    if (typeof value === 'boolean' || typeof value === 'string') return value;
    if (Buffer.isBuffer(value) || value instanceof Uint8Array) {
        return {
            __firestoreType: 'bytes',
            value: Buffer.from(value).toString('base64'),
        };
    }
    if (Array.isArray(value)) {
        return {
            __firestoreType: 'array',
            value: value.map(encodeValue),
        };
    }
    if (typeof value === 'object') {
        return {
            __firestoreType: 'map',
            value: Object.entries(value)
                .sort(([left], [right]) => left.localeCompare(right))
                .map(([key, entry]) => [key, encodeValue(entry)]),
        };
    }

    throw new TypeError(`Unsupported Firestore value type: ${typeof value}`);
}

function decodeValue(value, db) {
    if (value === null || typeof value === 'boolean' || typeof value === 'string') {
        return value;
    }
    if (typeof value === 'number') return value;
    if (Array.isArray(value)) {
        throw new TypeError('Backup values must use tagged arrays');
    }
    if (typeof value !== 'object' || value.__firestoreType == null) {
        throw new TypeError('Invalid tagged Firestore value');
    }

    switch (value.__firestoreType) {
        case 'undefined':
            return undefined;
        case 'timestamp':
            if (!Number.isInteger(value.seconds) || !Number.isInteger(value.nanoseconds)) {
                throw new TypeError('Invalid timestamp value');
            }
            return new Timestamp(value.seconds, value.nanoseconds);
        case 'geoPoint':
            return new GeoPoint(value.latitude, value.longitude);
        case 'documentReference':
            if (db == null) {
                throw new Error('A Firestore instance is required for references');
            }
            return db.doc(validateDocumentPath(value.path));
        case 'bytes':
            return Buffer.from(value.value, 'base64');
        case 'number':
            if (value.value === 'NaN') return Number.NaN;
            if (value.value === 'Infinity') return Infinity;
            if (value.value === '-Infinity') return -Infinity;
            throw new TypeError(`Invalid special number: ${value.value}`);
        case 'array':
            if (!Array.isArray(value.value)) {
                throw new TypeError('Invalid tagged array');
            }
            return value.value.map((entry) => decodeValue(entry, db));
        case 'map':
            if (!Array.isArray(value.value)) {
                throw new TypeError('Invalid tagged map');
            }
            return Object.fromEntries(
                value.value.map(([key, entry]) => {
                    if (typeof key !== 'string') {
                        throw new TypeError('Firestore map keys must be strings');
                    }
                    return [key, decodeValue(entry, db)];
                }),
            );
        default:
            throw new TypeError(
                `Unknown Firestore value type: ${value.__firestoreType}`,
            );
    }
}

function encodeDocumentData(data) {
    return encodeValue(data);
}

function decodeDocumentData(data, db) {
    const decoded = decodeValue(data, db);
    if (decoded == null || Array.isArray(decoded) || typeof decoded !== 'object') {
        throw new TypeError('Document data must be a map');
    }
    return decoded;
}

function validateDocumentPath(documentPath) {
    if (typeof documentPath !== 'string' || documentPath.length === 0) {
        throw new Error('Document path must be a non-empty string');
    }
    const segments = documentPath.split('/');
    if (segments.length === 0 || segments.length % 2 !== 0) {
        throw new Error(`Invalid document path: ${documentPath}`);
    }
    if (segments.some((segment) => segment.length === 0 || segment === '.' || segment === '..')) {
        throw new Error(`Invalid document path: ${documentPath}`);
    }
    return documentPath;
}

function validateBackupScope(scope) {
    if (scope !== 'transactions' && scope !== 'all') {
        throw new Error(`Invalid backup scope: ${scope}`);
    }
    return scope;
}

function hashFile(filePath) {
    return new Promise((resolve, reject) => {
        const hash = crypto.createHash('sha256');
        let byteCount = 0;
        const stream = fs.createReadStream(filePath);
        stream.on('data', (chunk) => {
            byteCount += chunk.length;
            hash.update(chunk);
        });
        stream.on('error', reject);
        stream.on('end', () => resolve({
            byteCount,
            checksum: hash.digest('hex'),
        }));
    });
}

function manifestPath(backupDirectory) {
    return path.join(backupDirectory, MANIFEST_FILE);
}

function documentsPath(backupDirectory) {
    return path.join(backupDirectory, DOCUMENTS_FILE);
}

function partialDirectory(outputDirectory) {
    return `${outputDirectory}${PARTIAL_SUFFIX}`;
}

function createManifest({
    projectId,
    databaseId = '(default)',
    scope,
    documentCount,
    byteCount,
    checksum,
    createdAt = new Date().toISOString(),
}) {
    return {
        schemaVersion: BACKUP_SCHEMA_VERSION,
        projectId,
        databaseId,
        scope: validateBackupScope(scope),
        createdAt,
        documentCount,
        byteCount,
        checksum,
        complete: true,
    };
}

function assertCompleteManifest(manifest) {
    if (manifest == null || manifest.complete !== true) {
        throw new Error('Backup manifest is not complete');
    }
    if (manifest.schemaVersion !== BACKUP_SCHEMA_VERSION) {
        throw new Error(`Unsupported backup schema: ${manifest.schemaVersion}`);
    }
    validateBackupScope(manifest.scope);
    if (typeof manifest.projectId !== 'string' || manifest.projectId.length === 0) {
        throw new Error('Backup manifest has no project ID');
    }
    if (!Number.isInteger(manifest.documentCount) || manifest.documentCount < 0) {
        throw new Error('Backup manifest has an invalid document count');
    }
    if (!Number.isInteger(manifest.byteCount) || manifest.byteCount < 0) {
        throw new Error('Backup manifest has an invalid byte count');
    }
    if (!/^[a-f0-9]{64}$/.test(manifest.checksum)) {
        throw new Error('Backup manifest has an invalid checksum');
    }
    return manifest;
}

async function verifyBackupDirectory(backupDirectory) {
    const manifest = JSON.parse(
        await fs.promises.readFile(manifestPath(backupDirectory), 'utf8'),
    );
    assertCompleteManifest(manifest);
    const actual = await hashFile(documentsPath(backupDirectory));
    if (actual.byteCount !== manifest.byteCount || actual.checksum !== manifest.checksum) {
        throw new Error('Backup checksum or byte count does not match the manifest');
    }
    return manifest;
}

module.exports = {
    BACKUP_SCHEMA_VERSION,
    DOCUMENTS_FILE,
    JOURNAL_FILE,
    MANIFEST_FILE,
    PARTIAL_SUFFIX,
    assertCompleteManifest,
    createManifest,
    decodeDocumentData,
    decodeValue,
    documentsPath,
    encodeDocumentData,
    encodeValue,
    hashFile,
    manifestPath,
    partialDirectory,
    validateBackupScope,
    validateDocumentPath,
    verifyBackupDirectory,
};
