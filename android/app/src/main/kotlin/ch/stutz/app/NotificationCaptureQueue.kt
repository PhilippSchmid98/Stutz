package ch.stutz.app

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class CapturedTransactionDraft(
    val id: String,
    val sourcePackage: String,
    val sourceDedupeKey: String,
    val capturedAtMillis: Long,
    val occurredAtMillis: Long,
    val merchant: String,
    val normalizedMerchant: String,
    val amountMinor: Long,
    val currencyCode: String,
    val parserVersion: Int,
)

class NotificationCaptureQueue(context: Context) {
    private val database = QueueDatabase(context.applicationContext)
    private val preferences = context.applicationContext.getSharedPreferences(
        PREFERENCES_NAME,
        Context.MODE_PRIVATE,
    )

    fun setActiveOwner(userId: String) {
        preferences.edit().putString(ACTIVE_OWNER_KEY, userId).apply()
    }

    fun clearActiveOwner() {
        preferences.edit().remove(ACTIVE_OWNER_KEY).apply()
    }

    fun enqueue(draft: CapturedTransactionDraft): Boolean {
        val ownerId = preferences.getString(ACTIVE_OWNER_KEY, null) ?: return false
        val values = ContentValues().apply {
            put("draft_id", draft.id)
            put("owner_id", ownerId)
            put("source_package", draft.sourcePackage)
            put("source_dedupe_key", draft.sourceDedupeKey)
            put("captured_at", draft.capturedAtMillis)
            put("occurred_at", draft.occurredAtMillis)
            put("merchant", draft.merchant)
            put("normalized_merchant", draft.normalizedMerchant)
            put("amount_minor", draft.amountMinor)
            put("currency_code", draft.currencyCode)
            put("parser_version", draft.parserVersion)
        }
        return database.writableDatabase.insertWithOnConflict(
            TABLE_DRAFTS,
            null,
            values,
            SQLiteDatabase.CONFLICT_IGNORE,
        ) != -1L
    }

    fun listUnsyncedDrafts(): List<CapturedTransactionDraft> {
        val ownerId = preferences.getString(ACTIVE_OWNER_KEY, null) ?: return emptyList()
        val drafts = mutableListOf<CapturedTransactionDraft>()
        database.readableDatabase.query(
            TABLE_DRAFTS,
            null,
            "owner_id = ? AND synced_at IS NULL",
            arrayOf(ownerId),
            null,
            null,
            "occurred_at ASC",
        ).use { cursor ->
            while (cursor.moveToNext()) {
                drafts += CapturedTransactionDraft(
                    id = cursor.getString(cursor.getColumnIndexOrThrow("draft_id")),
                    sourcePackage = cursor.getString(cursor.getColumnIndexOrThrow("source_package")),
                    sourceDedupeKey = cursor.getString(cursor.getColumnIndexOrThrow("source_dedupe_key")),
                    capturedAtMillis = cursor.getLong(cursor.getColumnIndexOrThrow("captured_at")),
                    occurredAtMillis = cursor.getLong(cursor.getColumnIndexOrThrow("occurred_at")),
                    merchant = cursor.getString(cursor.getColumnIndexOrThrow("merchant")),
                    normalizedMerchant = cursor.getString(cursor.getColumnIndexOrThrow("normalized_merchant")),
                    amountMinor = cursor.getLong(cursor.getColumnIndexOrThrow("amount_minor")),
                    currencyCode = cursor.getString(cursor.getColumnIndexOrThrow("currency_code")),
                    parserVersion = cursor.getInt(cursor.getColumnIndexOrThrow("parser_version")),
                )
            }
        }
        return drafts
    }

    fun acknowledgeSyncedDrafts(draftIds: List<String>) {
        val ownerId = preferences.getString(ACTIVE_OWNER_KEY, null) ?: return
        if (draftIds.isEmpty()) return

        val placeholders = draftIds.joinToString(",") { "?" }
        val values = ContentValues().apply {
            put("synced_at", System.currentTimeMillis())
        }
        database.writableDatabase.update(
            TABLE_DRAFTS,
            values,
            "owner_id = ? AND draft_id IN ($placeholders)",
            arrayOf(ownerId, *draftIds.toTypedArray()),
        )
    }

    private class QueueDatabase(context: Context) :
        SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
        override fun onCreate(db: SQLiteDatabase) {
            db.execSQL(
                """
                CREATE TABLE $TABLE_DRAFTS (
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
        }

        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
            if (oldVersion < 2) {
                db.execSQL("ALTER TABLE $TABLE_DRAFTS RENAME TO ${TABLE_DRAFTS}_old")
                onCreate(db)
                db.execSQL(
                    """
                    INSERT OR IGNORE INTO $TABLE_DRAFTS (
                        draft_id, owner_id, source_package, source_dedupe_key,
                        captured_at, occurred_at, merchant, normalized_merchant,
                        amount_minor, currency_code, parser_version, synced_at
                    )
                    SELECT draft_id, owner_id, source_package, source_dedupe_key,
                        captured_at, occurred_at, merchant, normalized_merchant,
                        amount_minor, currency_code, parser_version, synced_at
                    FROM ${TABLE_DRAFTS}_old
                    """.trimIndent(),
                )
                db.execSQL("DROP TABLE ${TABLE_DRAFTS}_old")
            }
        }
    }

    private companion object {
        const val ACTIVE_OWNER_KEY = "active_owner_id"
        const val DATABASE_NAME = "notification_capture.db"
        const val DATABASE_VERSION = 2
        const val PREFERENCES_NAME = "notification_capture"
        const val TABLE_DRAFTS = "captured_transaction_drafts"
    }
}