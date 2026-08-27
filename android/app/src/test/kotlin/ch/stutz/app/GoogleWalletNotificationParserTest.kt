package ch.stutz.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test

class GoogleWalletNotificationParserTest {
    @Test
    fun parsesObservedWalletPaymentWithNonBreakingSpace() {
        val draft = parse(
            title = "LS miro Passage Sihlqu",
            text = "CHF\u00A05.50 mit Platin MasterCard",
            notificationKey = "0|com.google.android.apps.walletnfcrel|1001|27841691|10274",
        )

        requireNotNull(draft)
        assertEquals("LS miro Passage Sihlqu", draft.merchant)
        assertEquals("ls miro passage sihlqu", draft.normalizedMerchant)
        assertEquals(550L, draft.amountMinor)
        assertEquals("CHF", draft.currencyCode)
    }

    @Test
    fun parsesSecondObservedWalletPayment() {
        val draft = parse(
            title = "Migros M EX Sihlpassag",
            text = "CHF 1.10 mit Platin MasterCard",
            notificationKey = "0|com.google.android.apps.walletnfcrel|1001|1440834488|10274",
        )

        requireNotNull(draft)
        assertEquals(110L, draft.amountMinor)
    }

    @Test
    fun fallsBackToBigTextAndNormalizesMerchantWhitespace() {
        val draft = parse(
            title = "  COOP\n  Pronto  ",
            text = null,
            bigText = "CHF 12,40 mit Platin MasterCard",
            notificationKey = "wallet-key",
        )

        requireNotNull(draft)
        assertEquals("COOP Pronto", draft.merchant)
        assertEquals("coop pronto", draft.normalizedMerchant)
        assertEquals(1240L, draft.amountMinor)
    }

    @Test
    fun rejectsUnsupportedOrMalformedPaymentText() {
        assertNull(parse(title = "Merchant", text = "EUR 5.50 mit Card"))
        assertNull(parse(title = "Merchant", text = "CHF 0.00 mit Card"))
        assertNull(parse(title = "Merchant", text = "CHF 5.555 mit Card"))
        assertNull(parse(title = "Merchant", text = "Kauf abgeschlossen"))
        assertNull(parse(title = null, text = "CHF 5.50 mit Card"))
        assertNull(parse(title = "Merchant", text = "CHF 5.50 mit Card", notificationKey = " "))
        assertNull(parse(title = "Merchant", text = "CHF 5.50 mit Card", isGroupSummary = true))
    }

    @Test
    fun createsStableDistinctFirestoreSafeIds() {
        val first = parse(title = "Merchant", text = "CHF 5.50 mit Card", notificationKey = "first")
        val same = parse(title = "Merchant", text = "CHF 5.50 mit Card", notificationKey = "first")
        val second = parse(title = "Merchant", text = "CHF 5.50 mit Card", notificationKey = "second")

        requireNotNull(first)
        requireNotNull(same)
        requireNotNull(second)
        assertEquals(first.id, same.id)
        assertNotEquals(first.id, second.id)
        assertEquals(-1, first.id.indexOf('/'))
    }

    private fun parse(
        title: String?,
        text: String?,
        bigText: String? = null,
        notificationKey: String = "test-key",
        isGroupSummary: Boolean = false,
    ): CapturedTransactionDraft? {
        return GoogleWalletNotificationParser.parseFields(
            title = title,
            text = text,
            bigText = bigText,
            notificationKey = notificationKey,
            postedAtMillis = 1_756_000_000_000,
            isGroupSummary = isGroupSummary,
        )
    }
}