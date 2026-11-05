package ch.stutz.app

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val captureQueue by lazy { NotificationCaptureQueue(this) }

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			NOTIFICATION_CAPTURE_CHANNEL,
		).setMethodCallHandler { call, result -> handleNotificationCaptureCall(call, result) }
		EventChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			NOTIFICATION_CAPTURE_EVENTS_CHANNEL,
		).setStreamHandler(object : EventChannel.StreamHandler {
			override fun onListen(
				arguments: Any?,
				events: EventChannel.EventSink,
			) {
				GoogleWalletNotificationListener.setOnDraftCapturedListener {
					runOnUiThread { events.success("captured") }
				}
			}

			override fun onCancel(arguments: Any?) {
				GoogleWalletNotificationListener.setOnDraftCapturedListener(null)
			}
		})
	}

	override fun onDestroy() {
		GoogleWalletNotificationListener.setOnDraftCapturedListener(null)
		super.onDestroy()
	}

	private fun handleNotificationCaptureCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"acknowledgeSyncedDrafts" -> {
				val draftIds = call.argument<List<String>>("draftIds")
				if (draftIds == null || draftIds.any { it.isBlank() }) {
					result.error("invalid_arguments", "draftIds must contain non-empty IDs", null)
					return
				}
				captureQueue.acknowledgeSyncedDrafts(draftIds)
				result.success(null)
			}
			"clearActiveOwner" -> {
				captureQueue.clearActiveOwner()
				result.success(null)
			}
			"captureActiveNotifications" -> {
				GoogleWalletNotificationListener.captureActiveNotifications()
				result.success(null)
			}
			"getNotificationAccessGranted" -> result.success(hasNotificationAccess())
			"listUnsyncedDrafts" -> result.success(
				captureQueue.listUnsyncedDrafts().map { draft ->
					mapOf(
						"id" to draft.id,
						"sourcePackage" to draft.sourcePackage,
						"sourceDedupeKey" to draft.sourceDedupeKey,
						"capturedAt" to draft.capturedAtMillis,
						"occurredAt" to draft.occurredAtMillis,
						"merchant" to draft.merchant,
						"normalizedMerchant" to draft.normalizedMerchant,
						"amountMinor" to draft.amountMinor,
						"currencyCode" to draft.currencyCode,
						"parserVersion" to draft.parserVersion,
						"status" to "pending",
					)
				},
			)
			"openNotificationAccessSettings" -> {
				startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
				result.success(null)
			}
			"setActiveOwner" -> {
				val userId = call.argument<String>("userId")
				if (userId.isNullOrBlank() || userId.contains('/')) {
					result.error("invalid_arguments", "userId must be a non-empty path segment", null)
					return
				}
				captureQueue.setActiveOwner(userId)
				result.success(null)
			}
			else -> result.notImplemented()
		}
	}

	private fun hasNotificationAccess(): Boolean {
		val component = ComponentName(this, GoogleWalletNotificationListener::class.java)
			.flattenToString()
		val enabledListeners = Settings.Secure.getString(
			contentResolver,
			"enabled_notification_listeners",
		) ?: return false
		return enabledListeners.split(':').contains(component)
	}

	private companion object {
		const val NOTIFICATION_CAPTURE_CHANNEL = "ch.stutz.app/notification_capture"
		const val NOTIFICATION_CAPTURE_EVENTS_CHANNEL =
			"ch.stutz.app/notification_capture_events"
	}
}
