'use strict';

const admin = require('firebase-admin');
const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, getApp } = require('firebase-admin/app');
const { FieldPath, getFirestore } = require('firebase-admin/firestore');
const {
    createManifest,
    documentsPath,
    encodeDocumentData,
    hashFile,
    manifestPath,
    partialDirectory,
    validateBackupScope,
    validateDocumentPath,
} = require('./firestore-backup-format');

const DEFAULT_PROJECT_ID = 'stutz-7ed90';
const DEFAULT_EMULATOR_HOST = '127.0.0.1:8080';

function parseArguments(argv) {
    const options = {
        dryRun: false,
        emulator: false,
        force: false,
        maxDocuments: null,
        output: null,
        projectId: process.env.GCLOUD_PROJECT || DEFAULT_PROJECT_ID,
        scope: 'transactions',
        userId: null,
    };

    for (const argument of argv) {
        if (argument === '--dry-run') {
            options.dryRun = true;
        } else if (argument === '--emulator') {
            options.emulator = true;
        } else if (argument === '--force') {
            options.force = true;
        } else if (argument.startsWith('--max-documents=')) {
            const value = argument.slice('--max-documents='.length);
            if (!/^\d+$/.test(value) || Number(value) < 1) {
                throw new Error('--max-documents must be a positive integer');
            }
            options.maxDocuments = Number(value);
        } else if (argument.startsWith('--output=')) {
            options.output = path.resolve(argument.slice('--output='.length));
        } else if (argument.startsWith('--project-id=')) {
            options.projectId = argument.slice('--project-id='.length);
        } else if (argument.startsWith('--scope=')) {
            options.scope = validateBackupScope(
                argument.slice('--scope='.length),
            );
        } else if (argument.startsWith('--user-id=')) {
            const userId = argument.slice('--user-id='.length);
            if (userId.length === 0 || userId.includes('/')) {
                throw new Error('--user-id must be a single non-empty path segment');
            }
            options.userId = userId;
        } else {
            throw new Error(`Unknown argument: ${argument}`);
        }
    }

    if (options.output == null) {
        throw new Error('Pass --output=<backup-directory>');
    }

    return options;
}

function initializeFirestore(options) {
    if (options.emulator) {
        process.env.FIRESTORE_EMULATOR_HOST ??= DEFAULT_EMULATOR_HOST;
        const app = admin.initializeApp({ projectId: options.projectId });
        return getFirestore(app);
    }

    if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        throw new Error(
            'Set GOOGLE_APPLICATION_CREDENTIALS to a service-account JSON path before running against production.',
        );
    }

    const app = admin.initializeApp({
        credential: applicationDefault(),
        projectId: options.projectId,
    });
    return getFirestore(app);
}

function comparePaths(left, right) {
    return left.localeCompare(right);
}

function belongsToUser(documentReference, userId) {
    if (userId == null) return true;
    const segments = documentReference.path.split('/');
    return segments.length >= 2
        && segments[0] === 'users'
        && segments[1] === userId;
}

function isTransactionDocument(documentReference) {
    const segments = documentReference.path.split('/');
    return segments.length === 4
        && segments[0] === 'users'
        && segments[2] === 'transactions';
}

async function* walkCollection(collectionReference, userId) {
    const query = collectionReference.orderBy(FieldPath.documentId());
    for await (const document of queryDocuments(query)) {
        if (belongsToUser(document.ref, userId)) {
            yield document;
        }

        const subcollections = await document.ref.listCollections();
        subcollections.sort((left, right) =>
            left.id.localeCompare(right.id),
        );
        for (const subcollection of subcollections) {
            yield* walkCollection(subcollection, userId);
        }
    }
}

async function* queryDocuments(query) {
    if (typeof query.stream === 'function') {
        for await (const document of query.stream()) yield document;
        return;
    }

    const snapshot = await query.get();
    const documents = [...snapshot.docs].sort((left, right) =>
        comparePaths(left.ref.path, right.ref.path),
    );
    yield* documents;
}

async function* enumerateDocuments(db, { scope, userId }) {
    if (scope === 'transactions') {
        const query = db
            .collectionGroup('transactions')
            .orderBy(FieldPath.documentId());
        for await (const document of queryDocuments(query)) {
            if (isTransactionDocument(document.ref)
                && belongsToUser(document.ref, userId)) {
                yield document;
            }
        }
        return;
    }

    const collections = await db.listCollections();
    collections.sort((left, right) => left.id.localeCompare(right.id));
    for (const collection of collections) {
        yield* walkCollection(collection, userId);
    }
}

function writeLine(stream, line) {
    return new Promise((resolve, reject) => {
        const onError = (error) => {
            stream.off('drain', onDrain);
            reject(error);
        };
        const onDrain = () => {
            stream.off('error', onError);
            resolve();
        };
        stream.once('error', onError);
        if (stream.write(line)) {
            stream.off('error', onError);
            resolve();
        } else {
            stream.once('drain', onDrain);
        }
    });
}

async function closeStream(stream) {
    await new Promise((resolve, reject) => {
        stream.once('error', reject);
        stream.once('close', resolve);
        stream.end();
    });
}

async function prepareOutputDirectory(outputDirectory, force) {
    const partial = partialDirectory(outputDirectory);
    const finalExists = fs.existsSync(outputDirectory);
    const partialExists = fs.existsSync(partial);
    if ((finalExists || partialExists) && !force) {
        throw new Error(
            `Backup output already exists: ${finalExists ? outputDirectory : partial}. Use --force to replace it.`,
        );
    }
    if (force) {
        await fs.promises.rm(outputDirectory, { recursive: true, force: true });
        await fs.promises.rm(partial, { recursive: true, force: true });
    }
    await fs.promises.mkdir(partial, { recursive: true });
    return partial;
}

async function createBackup(db, options) {
    if (options.dryRun) {
        let documentCount = 0;
        for await (const document of enumerateDocuments(db, options)) {
            documentCount++;
            if (options.maxDocuments != null && documentCount > options.maxDocuments) {
                throw new Error(
                    `Backup exceeds --max-documents=${options.maxDocuments}`,
                );
            }
        }
        return { documentCount, dryRun: true };
    }

    const partial = await prepareOutputDirectory(options.output, options.force);
    const outputFile = documentsPath(partial);
    const stream = fs.createWriteStream(outputFile, { encoding: 'utf8' });
    let documentCount = 0;

    try {
        for await (const document of enumerateDocuments(db, options)) {
            documentCount++;
            if (options.maxDocuments != null && documentCount > options.maxDocuments) {
                throw new Error(
                    `Backup exceeds --max-documents=${options.maxDocuments}`,
                );
            }
            const record = {
                path: validateDocumentPath(document.ref.path),
                data: encodeDocumentData(document.data()),
            };
            await writeLine(stream, `${JSON.stringify(record)}\n`);
            if (documentCount % 100 === 0) {
                console.log(`Backed up ${documentCount} documents...`);
            }
        }
        await closeStream(stream);
    } catch (error) {
        stream.destroy();
        throw error;
    }

    const { byteCount, checksum } = await hashFile(outputFile);
    const manifest = createManifest({
        projectId: options.projectId,
        scope: options.scope,
        documentCount,
        byteCount,
        checksum,
    });
    await fs.promises.writeFile(
        manifestPath(partial),
        `${JSON.stringify(manifest, null, 2)}\n`,
        'utf8',
    );
    await fs.promises.rename(partial, options.output);

    return { documentCount, manifest, output: options.output };
}

async function main(argv = process.argv.slice(2)) {
    const options = parseArguments(argv);
    const db = initializeFirestore(options);
    const app = getApp();

    try {
        const result = await createBackup(db, options);
        if (result.dryRun) {
            console.log(
                `[dry-run] Would back up ${result.documentCount} documents `
                + `from the ${options.scope} scope.`,
            );
        } else {
            console.log(
                `Backed up ${result.documentCount} documents to ${result.output}`,
            );
            console.log(`SHA-256: ${result.manifest.checksum}`);
        }
    } finally {
        await app.delete();
    }
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exitCode = 1;
    });
}

module.exports = {
    belongsToUser,
    closeStream,
    comparePaths,
    createBackup,
    enumerateDocuments,
    initializeFirestore,
    isTransactionDocument,
    main,
    parseArguments,
    prepareOutputDirectory,
    walkCollection,
    writeLine,
};
