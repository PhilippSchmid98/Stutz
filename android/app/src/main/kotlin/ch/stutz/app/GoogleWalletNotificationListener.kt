package ch.stutz.app

import android.app.Notification
import android.content.pm.ApplicationInfo
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.math.BigDecimal
import java.math.RoundingMode
import java.security.MessageDigest
import java.util.Locale

private const val GOOGLE_WALLET_PACKAGE = "com.google.android.apps.walletnfcrel"

class GoogleWalletNotificationListener : NotificationListenerService() {
    private lateinit var queue: NotificationCaptureQueue

    override fun onCreate() {
        super.onCreate()
        queue = NotificationCaptureQueue(this)
        activeInstance = this
    }

    override fun onDestroy() {
        if (activeInstance === this) activeInstance = null
        super.onDestroy()
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        captureActiveNotificationsInternal()
    }

    override fun onNotificationPosted(notification: StatusBarNotification) {
        captureNotification(notification)
    }

    private fun captureActiveNotificationsInternal() {
        getActiveNotifications()?.forEach(::captureNotification)
    }

    private fun captureNotification(notification: StatusBarNotification) {
        if (notification.packageName != GOOGLE_WALLET_PACKAGE) return

        logDebugNotification(notification)
        val draft = GoogleWalletNotificationParser.parse(
            notification = notification.notification,
            notificationKey = notification.key,
            postedAtMillis = notification.postTime,
        ) ?: return
        queue.enqueue(draft)
    }

    private fun logDebugNotification(notification: StatusBarNotification) {
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return

        val extras = notification.notification.extras
        Log.d(
            DIAGNOSTIC_TAG,
            """
            Google Wallet notification received
            key=${notification.key}
            postedAt=${notification.postTime}
            title=${extras.getCharSequence(Notification.EXTRA_TITLE)}
            text=${extras.getCharSequence(Notification.EXTRA_TEXT)}
            bigText=${extras.getCharSequence(Notification.EXTRA_BIG_TEXT)}
            subText=${extras.getCharSequence(Notification.EXTRA_SUB_TEXT)}
            summaryText=${extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)}
            """.trimIndent(),
        )
    }

    companion object {
        private var activeInstance: GoogleWalletNotificationListener? = null

        private const val DIAGNOSTIC_TAG = "StutzWalletDiagnostic"

        fun captureActiveNotifications() {
            activeInstance?.captureActiveNotificationsInternal()
        }
    }
}

object GoogleWalletNotificationParser {
    private val paymentPattern = Regex(
        "^CHF\\s+(\\d+(?:[.,]\\d{1,2})?)\\s+mit\\s+\\S.*$",
        setOf(RegexOption.IGNORE_CASE),
    )

    fun parse(
        notification: Notification,
        notificationKey: String,
        postedAtMillis: Long,
    ): CapturedTransactionDraft? {
        val extras = notification.extras
        return parseFields(
            title = extras.getCharSequence(Notification.EXTRA_TITLE),
            text = extras.getCharSequence(Notification.EXTRA_TEXT),
            bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT),
            notificationKey = notificationKey,
            postedAtMillis = postedAtMillis,
            isGroupSummary = notification.flags and Notification.FLAG_GROUP_SUMMARY != 0,
        )
    }

    internal fun parseFields(
        title: CharSequence?,
        text: CharSequence?,
        bigText: CharSequence?,
        notificationKey: String,
        postedAtMillis: Long,
        isGroupSummary: Boolean = false,
    ): CapturedTransactionDraft? {
        if (isGroupSummary) return null
        val merchant = normalizeText(title) ?: return null
        val dedupeKey = notificationKey.trim()
        if (dedupeKey.isEmpty() || postedAtMillis <= 0) return null

        val amountMinor = sequenceOf(text, bigText)
            .mapNotNull(::normalizeText)
            .mapNotNull(::parseAmountMinor)
            .firstOrNull() ?: return null

        return CapturedTransactionDraft(
            id = stableDraftId(dedupeKey),
            sourcePackage = GOOGLE_WALLET_PACKAGE,
            sourceDedupeKey = dedupeKey,
            capturedAtMillis = postedAtMillis,
            occurredAtMillis = postedAtMillis,
            merchant = merchant,
            normalizedMerchant = merchant.lowercase(Locale.ROOT),
            amountMinor = amountMinor,
            currencyCode = "CHF",
            parserVersion = 1,
        )
    }

    private fun normalizeText(value: CharSequence?): String? {
        val normalized = value
            ?.toString()
            ?.replace('\u00A0', ' ')
            ?.replace('\u202F', ' ')
            ?.replace(Regex("\\s+"), " ")
            ?.trim()
        return normalized?.takeIf { it.isNotEmpty() }
    }

    private fun parseAmountMinor(paymentText: String): Long? {
        val amountText = paymentPattern.matchEntire(paymentText)
            ?.groupValues
            ?.getOrNull(1) ?: return null

        return try {
            val amount = BigDecimal(amountText.replace(',', '.'))
                .setScale(2, RoundingMode.UNNECESSARY)
            if (amount <= BigDecimal.ZERO) return null
            amount.movePointRight(2).longValueExact()
        } catch (_: ArithmeticException) {
            null
        } catch (_: NumberFormatException) {
            null
        }
    }

    private fun stableDraftId(notificationKey: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
            .digest(notificationKey.toByteArray(Charsets.UTF_8))
        val hash = digest.joinToString("") { byteValue ->
            "%02x".format(Locale.ROOT, byteValue.toInt() and 0xFF)
        }
        return "wallet_$hash"
    }
}