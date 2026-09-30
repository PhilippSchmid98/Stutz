package ch.stutz.app

import android.app.Notification
import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.UserHandle
import android.service.notification.StatusBarNotification
import androidx.annotation.XmlRes
import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog
import org.xmlpull.v1.XmlPullParser

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class NotificationPrivacyTest {
    private lateinit var context: Context

    @Before
    fun setUp() {
        context = RuntimeEnvironment.getApplication()
        clearStorage()
        ShadowLog.clear()
    }

    @After
    fun tearDown() {
        GoogleWalletNotificationListener.setOnDraftCapturedListener(null)
        clearStorage()
        ShadowLog.clear()
    }

    @Test
    fun disablesBackupAndExcludesNotificationStorageFromTransferRules() {
        val applicationInfo = context.applicationInfo
        val application = DocumentBuilderFactory.newInstance()
            .apply { isNamespaceAware = true }
            .newDocumentBuilder()
            .parse(
                File(
                    checkNotNull(System.getProperty("stutz.androidAppDir")),
                    "src/main/AndroidManifest.xml",
                ),
            )
            .getElementsByTagName("application")
            .item(0)

        assertEquals(0, applicationInfo.flags and ApplicationInfo.FLAG_ALLOW_BACKUP)
        assertEquals("false", application.attributes.getNamedItemNS(androidNamespace, "allowBackup").nodeValue)
        assertEquals(
            "@xml/backup_rules",
            application.attributes.getNamedItemNS(androidNamespace, "fullBackupContent").nodeValue,
        )
        assertEquals(
            "@xml/data_extraction_rules",
            application.attributes.getNamedItemNS(androidNamespace, "dataExtractionRules").nodeValue,
        )

        val legacyExclusions = readExclusions(R.xml.backup_rules)
        assertEquals(1, legacyExclusions.count { it == queueDatabase })
        assertEquals(1, legacyExclusions.count { it == ownerPreferences })

        val extractionExclusions = readExclusions(R.xml.data_extraction_rules)
        assertEquals(2, extractionExclusions.count { it == queueDatabase })
        assertEquals(2, extractionExclusions.count { it == ownerPreferences })
    }

    @Test
    fun captureDoesNotWritePaymentDetailsToAndroidLogs() {
        val merchant = "PRIVATE_MERCHANT_SENTINEL"
        val paymentText = "CHF 9876.54 mit PRIVATE_CARD_SENTINEL"
        val notificationTag = "PRIVATE_NOTIFICATION_KEY_SENTINEL"
        val service = Robolectric
            .buildService(GoogleWalletNotificationListener::class.java)
            .create()
            .get()
        NotificationCaptureQueue(service).setActiveOwner("privacy-test-owner")
        val notification = Notification.Builder(service)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(merchant)
            .setContentText(paymentText)
            .build()
        val statusBarNotification = StatusBarNotification(
            "com.google.android.apps.walletnfcrel",
            "com.google.android.apps.walletnfcrel",
            1,
            notificationTag,
            1000,
            1000,
            0,
            notification,
            UserHandle.getUserHandleForUid(1000),
            1_756_000_000_000,
        )

        ShadowLog.clear()
        service.onNotificationPosted(statusBarNotification)

        val logs = ShadowLog.getLogs().joinToString("\n") { log ->
            "${log.tag} ${log.msg} ${log.throwable}"
        }
        assertFalse(logs.contains(merchant))
        assertFalse(logs.contains(paymentText))
        assertFalse(logs.contains(notificationTag))
        assertFalse(logs.contains(statusBarNotification.key))
        assertFalse(logs.contains("9876.54"))
        service.onDestroy()
    }

    private fun readExclusions(@XmlRes resourceId: Int): List<Pair<String, String>> {
        val parser = context.resources.getXml(resourceId)
        val exclusions = mutableListOf<Pair<String, String>>()
        try {
            while (parser.eventType != XmlPullParser.END_DOCUMENT) {
                if (parser.eventType == XmlPullParser.START_TAG && parser.name == "exclude") {
                    exclusions += parser.getAttributeValue(null, "domain") to
                        parser.getAttributeValue(null, "path")
                }
                parser.next()
            }
        } finally {
            parser.close()
        }
        return exclusions
    }

    private fun clearStorage() {
        context.deleteDatabase("notification_capture.db")
        context.getSharedPreferences("notification_capture", Context.MODE_PRIVATE)
            .edit()
            .clear()
            .commit()
    }

    private companion object {
        const val androidNamespace = "http://schemas.android.com/apk/res/android"
        val queueDatabase = "database" to "notification_capture.db"
        val ownerPreferences = "sharedpref" to "notification_capture.xml"
    }
}