'use strict';

const admin = require('firebase-admin');
const fs = require('node:fs');
const path = require('node:path');
const readline = require('node:readline');
const { applicationDefault, getApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const {
    assertCompleteManifest,
    decodeDocumentData,
    documentsPath,
    JOURNAL_FILE,
    validateBackupScope,
    validateDocumentPath,
    verifyBackupDirectory,
} = require('./firestore-backup-format');

const DEFAULT_PROJECT_ID = 'stutz-7ed90';
const DEFAULT_EMULATOR_HOST = '127.0.0.1:8080';
const MAX_BATCH_OPERATIONS = 500;

function parseArguments(argv) {
    const options = {
        allowProjectMismatch: false,
        confirm: false,
        deleteMissing: false,
        dryRun: false,
        emulator: false,
        input: null,
        journal: null,
        projectId: process.env.GCLOUD_PROJECT || DEFAULT_PROJECT_ID,
        resume: false,
        scope: null,
        userId: null,
    };

    for (const argument of argv) {
        if (argument === '--allow-project-mismatch') {
            options.allowProjectMismatch = true;
        } else if (argument === '--confirm') {
            options.confirm = true;
        } else if (argument === '--delete-missing') {
            options.deleteMissing = true;
        } else if (argument === '--dry-run') {
            options.dryRun = true;
        } else if (argument === '--emulator') {
            options.emulator = true;
        } else if (argument === '--resume') {
            options.resume = true;
        } else if (argument.startsWith('--input=')) {
            options.input = path.resolve(argument.slice('--input='.length));
        } else if (argument.startsWith('--journal=')) {
            options.journal = path.resolve(argument.slice('--journal='.length));
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

    if (options.input == null) {
        throw new Error('Pass --input=<backup-directory>');
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
            'Set GOOGLE_APPLICATION_CREDENTIALS to a service-account JSON path before restoring production data.',
        );
    }

    const app = admin.initializeApp({
        credential: applicationDefault(),
        projectId: options.projectId,
    });
    return getFirestore(app);
}

function transactionDocumentPath(documentPath) {
    const segments = documentPath.split('/');
    return segments.length === 4
        && segments[0] === 'users'
        && segments[2] === 'transactions';
}

function pathBelongsToUser(documentPath, userId) {
    if (userId == null) return true;
    const segments = documentPath.split('/');
    return segments.length >= 2
        && segments[0] === 'users'
        && segments[1] === userId;
}

function pathMatchesScope(documentPath, scope, userId) {
    if (!pathBelongsToUser(documentPath, userId)) return false;
    if (scope === 'transactions') {
        return transactionDocumentPath(documentPath);
    }
    return documentPath.split('/').length % 2 === 0;
}

function selectedScope(manifest, requestedScope) {
    const scope = requestedScope ?? manifest.scope;
    if (manifest.scope === 'transactions' && scope === 'all') {
        throw new Error('A transaction-scope backup cannot be restored as all data');
    }
    return scope;
}

function parseRecord(line, lineNumber) {
    let record;
    try {
        record = JSON.parse(line);
    } catch (error) {
        throw new Error(`Invalid JSON on backup line ${lineNumber}: ${error.message}`);
    }
    if (record == null || typeof record !== 'object' || Array.isArray(record)) {
        throw new Error(`Invalid backup record on line ${lineNumber}`);
    }
    return record;
}

async function* readRecords(backupDirectory) {
    const input = fs.createReadStream(documentsPath(backupDirectory), {
        encoding: 'utf8',
    });
    const lines = readline.createInterface({
        crlfDelay: Infinity,
        input,
    });
    let lineNumber = 0;

    try {
        for await (const line of lines) {
            lineNumber++;
            if (line.trim().length === 0) {
                throw new Error(`Empty backup record on line ${lineNumber}`);
            }
            yield { lineNumber, record: parseRecord(line, lineNumber) };
        }
    } finally {
        lines.close();
        input.destroy();
    }
}

function validateRecord(record, lineNumber, manifestScope, scope, userId, db) {
    const documentPath = validateDocumentPath(record.path);
    if (!pathMatchesScope(documentPath, manifestScope, null)) {
        throw new Error(
            `Backup line ${lineNumber} contains a path outside its ${manifestScope} scope: ${documentPath}`,
        );
    }
    if (!Object.hasOwn(record, 'data')) {
        throw new Error(`Backup line ${lineNumber} has no document data`);
    }
    const data = decodeDocumentData(record.data, db);
    return {
        data,
        path: documentPath,
        selected: pathMatchesScope(documentPath, scope, userId),
    };
}

async function validateArchive(backupDirectory, manifest, options, db) {
    assertCompleteManifest(manifest);
    if (manifest.databaseId !== '(default)') {
        throw new Error(`Unsupported Firestore database: ${manifest.databaseId}`);
    }
    if (!options.allowProjectMismatch && manifest.projectId !== options.projectId) {
        throw new Error(
            `Backup project ${manifest.projectId} does not match ${options.projectId}. `
            + 'Use --allow-project-mismatch only for an intentional restore.',
        );
    }

    const scope = selectedScope(manifest, options.scope);
    if (options.deleteMissing && (scope !== 'transactions' || options.userId == null)) {
        throw new Error(
            '--delete-missing requires --scope=transactions and --user-id=<user-id>',
        );
    }

    const decoderDb = db ?? { doc: (documentPath) => ({ path: documentPath }) };
    const paths = new Set();
    let documentCount = 0;
    let selectedDocumentCount = 0;

    for await (const { lineNumber, record } of readRecords(backupDirectory)) {
        documentCount++;
        if (documentCount > manifest.documentCount) {
            throw new Error('Backup contains more documents than its manifest');
        }
        const validated = validateRecord(
            record,
            lineNumber,
            manifest.scope,
            scope,
            options.userId,
            decoderDb,
        );
        if (paths.has(validated.path)) {
            throw new Error(`Backup contains duplicate document path: ${validated.path}`);
        }
        paths.add(validated.path);
        if (validated.selected) selectedDocumentCount++;
    }

    if (documentCount !== manifest.documentCount) {
        throw new Error(
            `Backup contains ${documentCount} documents, manifest declares ${manifest.documentCount}`,
        );
    }

    return { paths, scope, selectedDocumentCount };
}

function defaultJournalPath(backupDirectory) {
    return path.join(backupDirectory, JOURNAL_FILE);
}

async function readJournal(journalFile, manifest, options, selectedDocumentCount) {
    if (!options.resume) {
        if (fs.existsSync(journalFile)) {
            throw new Error(
                `An unfinished restore journal exists at ${journalFile}; use --resume or remove it.`,
            );
        }
        return 0;
    }

    let journal;
    try {
        journal = JSON.parse(await fs.promises.readFile(journalFile, 'utf8'));
    } catch (error) {
        throw new Error(`Could not read restore journal: ${error.message}`);
    }
    if (journal.checksum !== manifest.checksum
        || journal.projectId !== options.projectId
        || journal.scope !== options.scope
        || journal.userId !== options.userId
        || !Number.isInteger(journal.committedDocuments)
        || journal.committedDocuments < 0
        || journal.committedDocuments > selectedDocumentCount) {
        throw new Error('Restore journal does not match this restore selection');
    }
    return journal.committedDocuments;
}

async function writeJournal(journalFile, manifest, options, committedDocuments, selectedDocumentCount) {
    const temporaryFile = `${journalFile}.tmp`;
    const journal = {
        checksum: manifest.checksum,
        committedDocuments,
        projectId: options.projectId,
        scope: options.scope,
        selectedDocumentCount,
        updatedAt: new Date().toISOString(),
        userId: options.userId,
    };
    await fs.promises.writeFile(
        temporaryFile,
        `${JSON.stringify(journal, null, 2)}\n`,
        'utf8',
    );
    await fs.promises.rm(journalFile, { force: true });
    await fs.promises.rename(temporaryFile, journalFile);
}

async function applyRestore(db, backupDirectory, manifest, selection, options) {
    const journalFile = options.journal ?? defaultJournalPath(backupDirectory);
    const committedBeforeResume = await readJournal(
        journalFile,
        manifest,
        { ...options, scope: options.scope ?? manifest.scope },
        selection.selectedDocumentCount,
    );
    let selectedIndex = 0;
    let committedDocuments = committedBeforeResume;
    let batch = [];

    const commitBatch = async () => {
        if (batch.length === 0) return;
        const firestoreBatch = db.batch();
        for (const operation of batch) {
            firestoreBatch.set(operation.reference, operation.data);
        }
        await firestoreBatch.commit();
        committedDocuments = batch.at(-1).selectedIndex;
        await writeJournal(
            journalFile,
            manifest,
            { ...options, scope: options.scope ?? manifest.scope },
            committedDocuments,
            selection.selectedDocumentCount,
        );
        console.log(`Restored ${committedDocuments}/${selection.selectedDocumentCount} documents...`);
        batch = [];
    };

    for await (const { lineNumber, record } of readRecords(backupDirectory)) {
        const validated = validateRecord(
            record,
            lineNumber,
            manifest.scope,
            selection.scope,
            options.userId,
            db,
        );
        if (!validated.selected) continue;
        selectedIndex++;
        if (selectedIndex <= committedBeforeResume) continue;
        batch.push({
            data: validated.data,
            reference: db.doc(validated.path),
            selectedIndex,
        });
        if (batch.length === MAX_BATCH_OPERATIONS) await commitBatch();
    }
    await commitBatch();

    let deletedDocumentCount = 0;
    if (options.deleteMissing) {
        const transactionReference = db
            .collection('users')
            .doc(options.userId)
            .collection('transactions');
        const existing = await transactionReference.get();
        const stale = existing.docs.filter((document) => !selection.paths.has(document.ref.path));
        for (let index = 0; index < stale.length; index += MAX_BATCH_OPERATIONS) {
            const firestoreBatch = db.batch();
            for (const document of stale.slice(index, index + MAX_BATCH_OPERATIONS)) {
                firestoreBatch.delete(document.ref);
            }
            await firestoreBatch.commit();
            deletedDocumentCount += Math.min(
                MAX_BATCH_OPERATIONS,
                stale.length - index,
            );
        }
    }

    await fs.promises.rm(journalFile, { force: true });
    return {
        deletedDocumentCount,
        restoredDocumentCount: selection.selectedDocumentCount,
    };
}

async function restoreBackup(db, options) {
    const manifest = await verifyBackupDirectory(options.input);
    const selection = await validateArchive(
        options.input,
        manifest,
        options,
        db,
    );
    if (options.dryRun) {
        return {
            deletedDocumentCount: 0,
            manifest,
            restoredDocumentCount: selection.selectedDocumentCount,
            scope: selection.scope,
        };
    }
    if (db == null) throw new Error('A Firestore instance is required to restore');
    if (!options.emulator && !options.confirm) {
        throw new Error(
            'Production restore requires --confirm. Use --dry-run to inspect an archive first.',
        );
    }
    const result = await applyRestore(
        db,
        options.input,
        manifest,
        selection,
        options,
    );
    return { ...result, manifest, scope: selection.scope };
}

async function main(argv = process.argv.slice(2)) {
    const options = parseArguments(argv);
    const manifest = await verifyBackupDirectory(options.input);
    const selection = await validateArchive(options.input, manifest, options);

    if (options.dryRun) {
        console.log(
            `[dry-run] Would restore ${selection.selectedDocumentCount} documents `
            + `from the ${selection.scope} scope.`,
        );
        return;
    }
    if (!options.emulator && !options.confirm) {
        throw new Error(
            'Production restore requires --confirm. Use --dry-run to inspect an archive first.',
        );
    }

    const db = initializeFirestore(options);
    const app = getApp();
    try {
        const result = await applyRestore(
            db,
            options.input,
            manifest,
            selection,
            options,
        );
        console.log(
            `Restored ${result.restoredDocumentCount} documents`
            + (result.deletedDocumentCount > 0
                ? ` and deleted ${result.deletedDocumentCount} missing transactions.`
                : '.'),
        );
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
    MAX_BATCH_OPERATIONS,
    applyRestore,
    defaultJournalPath,
    initializeFirestore,
    main,
    parseArguments,
    pathBelongsToUser,
    pathMatchesScope,
    readRecords,
    restoreBackup,
    selectedScope,
    transactionDocumentPath,
    validateArchive,
    validateRecord,
};
