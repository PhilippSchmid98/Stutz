package ch.stutz.app

import android.content.Context
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class NotificationCaptureQueueTest {
    private lateinit var context: Context

    @Before
    fun setUp() {
        context = RuntimeEnvironment.getApplication()
        clearStorage()
    }

    @After
    fun tearDown() {
        clearStorage()
    }

    @Test
    fun ignoresCaptureWithoutAnActiveOwner() {
        val queue = NotificationCaptureQueue(context)

        assertFalse(queue.enqueue(draft()))
        assertTrue(queue.listUnsyncedDrafts().isEmpty())
    }

    @Test
    fun clearingOwnerPurgesTheirQueueAndPreventsFurtherCapture() {
        val queue = NotificationCaptureQueue(context)
        queue.setActiveOwner("owner-a")
        assertTrue(queue.enqueue(draft()))

        queue.clearActiveOwner()

        assertTrue(queue.listUnsyncedDrafts().isEmpty())
        assertFalse(queue.enqueue(draft(id = "after-sign-out")))
    }

    @Test
    fun allowsTheSameSourceKeyForDifferentOwners() {
        val queue = NotificationCaptureQueue(context)
        queue.setActiveOwner("owner-a")
        assertTrue(queue.enqueue(draft(id = "owner-a-draft", sourceDedupeKey = "shared-key")))

        queue.setActiveOwner("owner-b")
        assertTrue(queue.enqueue(draft(id = "owner-b-draft", sourceDedupeKey = "shared-key")))

        assertEquals(listOf("owner-b-draft"), queue.listUnsyncedDrafts().map { it.id })
    }

    @Test
    fun migratesVersionTwoQueueToOwnerScopedDeduplication() {
        val database = context.openOrCreateDatabase(
            "notification_capture.db",
            Context.MODE_PRIVATE,
            null,
        )
        database.execSQL(
            """
            CREATE TABLE captured_transaction_drafts (
                draft_id TEXT NOT NULL,
                owner_id TEXT NOT NULL,
                source_package TEXT NOT NULL,
                source_dedupe_key TEXT NOT NULL UNIQUE,
                captured_at INTEGER NOT NULL,
                occurred_at INTEGER NOT NULL,
                merchant TEXT NOT NULL,
                normalized_merchant TEXT NOT NULL,
                amount_minor INTEGER NOT NULL,
                currency_code TEXT NOT NULL,
                parser_version INTEGER NOT NULL,
                synced_at INTEGER,
                PRIMARY KEY (owner_id, draft_id),
                UNIQUE (owner_id, source_dedupe_key)
            )
            """.trimIndent(),
        )
        database.execSQL(
            """
            INSERT INTO captured_transaction_drafts VALUES (
                'owner-a-draft', 'owner-a', 'com.google.android.apps.walletnfcrel',
                'shared-key', 1, 1, 'Merchant', 'merchant', 550, 'CHF', 1, NULL
            )
            """.trimIndent(),
        )
        database.version = 2
        database.close()

        val queue = NotificationCaptureQueue(context)
        queue.setActiveOwner("owner-b")

        assertTrue(queue.enqueue(draft(id = "owner-b-draft", sourceDedupeKey = "shared-key")))
    }

    private fun clearStorage() {
        context.deleteDatabase("notification_capture.db")
        context.getSharedPreferences("notification_capture", Context.MODE_PRIVATE)
            .edit()
            .clear()
            .commit()
    }

    private fun draft(
        id: String = "draft",
        sourceDedupeKey: String = "source-key",
    ) = CapturedTransactionDraft(
        id = id,
        sourcePackage = "com.google.android.apps.walletnfcrel",
        sourceDedupeKey = sourceDedupeKey,
        capturedAtMillis = 1_756_000_000_000,
        occurredAtMillis = 1_756_000_000_000,
        merchant = "Merchant",
        normalizedMerchant = "merchant",
        amountMinor = 550,
        currencyCode = "CHF",
        parserVersion = 1,
    )
}