package com.example.plugin_mappintelligence

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** PluginMappintelligencePlugin */
class PluginMappintelligencePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_mappintelligence")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            FlutterFunctions.GET_PLATFORM_VERSION -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    object FlutterFunctions {
        const val GET_PLATFORM_VERSION = "getPlatformVersion"
        const val INITIALIZE = "initialize"
        const val SET_LOG_LEVEL = "setLogLevel"
        const val BATCH_SUPPORT = "setBatchSupportEnabledWithSize"
        const val SET_REQUEST_INTERVAL = "setRequestInterval"
        const val OPT_IN = "OptIn"
        const val OPT_OUT_WITH_DATA = "optOutAndSendCurrentData"
        const val TRACK_PAGE = "trackPage"
        const val TRACK_CUSTOM_PAGE = "trackCustomPage"
        const val TRACK_OBJECT_PAGE_WITHOUT_DATA = "trackPageWithCustomNameAndPageViewEvent"
        const val TRACK_OBJECT_PAGE_WITH_DATA = "trackPageWithCustomData"
        const val TRACK_ACTION = "trackAction"
        const val TRACK_WITHOUT_MEDIA_CODE = "trackUrlWithoutMediaCode"
        const val TRACK_URL = "trackUrl"
        const val TRACK_WEB_VIEW = "trackWebview"
        const val DISPOSE_WEB_VIEW = "disposeWebview"

        //Only iOS
        const val SET_REQUEST_PER_QUEUE = "setRequestPerQueue"
        const val RESET = "reset"
        const val ENABLE_ANONYMOUS_TRACKING = "enableAnonymousTracking"
        const val ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS = "enableAnonymousTrackingWithParameters"
        const val IS_ANONYMOUS_TRACKING_ENABLE = "isAnonymousTrackingEnabled"
    }
}
