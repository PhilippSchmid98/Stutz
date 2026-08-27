const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
    doc,
    getDoc,
    setDoc,
} = require('firebase/firestore');

const projectId = 'stutz-rules-tests';
const rules = fs.readFileSync(
    path.join(__dirname, '..', 'firestore.rules'),
    'utf8',
);

let testEnv;

async function main() {
    testEnv = await initializeTestEnvironment({
        projectId,
        firestore: { rules },
    });

    await testEnv.clearFirestore();

    const alice = testEnv.authenticatedContext('alice');
    const bob = testEnv.authenticatedContext('bob');
    const unauthenticated = testEnv.unauthenticatedContext();

    const aliceBudget = doc(alice.firestore(), 'users/alice/budgets/main');
    const bobBudget = doc(bob.firestore(), 'users/bob/budgets/main');
    const aliceFromBobContext = doc(
        bob.firestore(),
        'users/alice/budgets/main',
    );
    const publicDocument = doc(
        unauthenticated.firestore(),
        'users/alice/budgets/main',
    );

    await assertSucceeds(setDoc(aliceBudget, { amount: 100 }));
    await assertSucceeds(getDoc(aliceBudget));
    await assertSucceeds(setDoc(bobBudget, { amount: 200 }));
    await assertSucceeds(getDoc(bobBudget));

    await assertFails(getDoc(aliceFromBobContext));
    await assertFails(setDoc(aliceFromBobContext, { amount: 999 }));
    await assertFails(getDoc(publicDocument));
    await assertFails(setDoc(publicDocument, { amount: 999 }));

    const aliceSnapshot = await getDoc(aliceBudget);
    assert.equal(aliceSnapshot.data().amount, 100);

    console.log('Firestore Rules tests passed.');
}

main()
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    })
    .finally(async () => {
        if (testEnv) await testEnv.cleanup();
    });
