package com.example.plugin_mappintelligence

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import webtrekk.android.sdk.Logger
import webtrekk.android.sdk.Webtrekk
import webtrekk.android.sdk.WebtrekkConfiguration

/** PluginMappintelligencePlugin */
class PluginMappintelligencePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mContext: Context


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_mappintelligence")
        channel.setMethodCallHandler(this)
    }

    var webtrekkConfigurations = WebtrekkConfiguration.Builder(
        listOf("1"),
        "1"
    )

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            FlutterFunctions.GET_PLATFORM_VERSION -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            FlutterFunctions.INITIALIZE -> {
                val trackIds = call.arguments<HashMap<String, ArrayList<String>>>()["trackIds"]
                val trackDomain: String? = call.arguments<HashMap<String, String>>()["trackDomain"]
                if (trackIds != null && trackDomain != null) {
                    webtrekkConfigurations = WebtrekkConfiguration.Builder(
                        trackIds.toList(),
                        trackDomain
                    )
                }
                  webtrekkConfigurations.disableActivityAutoTracking()
            }
            FlutterFunctions.SET_LOG_LEVEL -> {
                val logLevel = call.arguments<ArrayList<Int>>()[0]
                if (logLevel == 7) {
                    webtrekkConfigurations.logLevel(Logger.Level.NONE)
                } else {
                    webtrekkConfigurations.logLevel(Logger.Level.BASIC)
                }
            }
            FlutterFunctions.BATCH_SUPPORT -> {
                val enable = call.arguments<ArrayList<Boolean>>()[0]
                val interval = call.arguments<ArrayList<Int>>()[1]
                webtrekkConfigurations.setBatchSupport(enable, interval)
            }
            FlutterFunctions.SET_REQUEST_INTERVAL -> {
                val requestInterval = call.arguments<ArrayList<Int>>()[0]
                webtrekkConfigurations.requestsInterval(interval = requestInterval.toLong())
            }
            FlutterFunctions.OPT_IN -> {
                Webtrekk.getInstance().optOut(false)
            }
            FlutterFunctions.OPT_OUT_WITH_DATA -> {
                val enable = call.arguments<ArrayList<Boolean>>()[0]
                Webtrekk.getInstance().optOut(true, enable)
            }
            FlutterFunctions.BUILD -> {
                val configBuild = webtrekkConfigurations.build()
                Webtrekk.getInstance().init(mContext, configBuild)

            }
            FlutterFunctions.TRACK_PAGE -> {
            }
            FlutterFunctions.TRACK_CUSTOM_PAGE -> {
            }
            FlutterFunctions.TRACK_OBJECT_PAGE_WITHOUT_DATA -> {
            }
            FlutterFunctions.TRACK_OBJECT_PAGE_WITH_DATA -> {
            }
            FlutterFunctions.TRACK_ACTION -> {
            }
            FlutterFunctions.TRACK_WITHOUT_MEDIA_CODE -> {
            }
            FlutterFunctions.TRACK_URL -> {
            }
            FlutterFunctions.TRACK_WEB_VIEW -> {
            }
            FlutterFunctions.DISPOSE_WEB_VIEW -> {
            }
            //only iOS
            FlutterFunctions.SET_REQUEST_PER_QUEUE -> {
                result.success(iOS)
            }
            FlutterFunctions.RESET -> {
                result.success(iOS)
            }
            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING -> {
                result.success(iOS)
            }
            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS -> {
                result.success(iOS)
            }
            FlutterFunctions.IS_ANONYMOUS_TRACKING_ENABLE -> {
                result.success(iOS)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

     val iOS: String = "Only iOS function"

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
        const val BUILD = "build"

        //Only iOS
        const val SET_REQUEST_PER_QUEUE = "setRequestPerQueue"
        const val RESET = "reset"
        const val ENABLE_ANONYMOUS_TRACKING = "enableAnonymousTracking"
        const val ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS =
            "enableAnonymousTrackingWithParameters"
        const val IS_ANONYMOUS_TRACKING_ENABLE = "isAnonymousTrackingEnabled"
    }
}
