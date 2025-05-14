package com.example.plugin_mappintelligence

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.example.plugin_mappintelligence.Parser.toMap
import com.example.plugin_mappintelligence.webviewflutter.FlutterCookieManager
import com.example.plugin_mappintelligence.webviewflutter.WebViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import webtrekk.android.sdk.DefaultConfiguration
import webtrekk.android.sdk.ExceptionType
import webtrekk.android.sdk.Logger
import webtrekk.android.sdk.Webtrekk
import webtrekk.android.sdk.WebtrekkConfiguration
import webtrekk.android.sdk.events.ActionEvent
import webtrekk.android.sdk.events.MediaEvent
import webtrekk.android.sdk.events.PageViewEvent
import webtrekk.android.sdk.events.eventParams.CampaignParameters
import webtrekk.android.sdk.events.eventParams.ECommerceParameters
import webtrekk.android.sdk.events.eventParams.EventParameters
import webtrekk.android.sdk.events.eventParams.MediaParameters
import webtrekk.android.sdk.events.eventParams.PageParameters
import webtrekk.android.sdk.events.eventParams.ProductParameters
import webtrekk.android.sdk.events.eventParams.SessionParameters
import webtrekk.android.sdk.events.eventParams.UserCategories
import java.util.*
import java.util.concurrent.TimeUnit

/** PluginMappintelligencePlugin */
class PluginMappintelligencePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null
    private var mContext: Context? = null
    private var activity: Activity? = null
    private var flutterCookieManager: FlutterCookieManager? = null

    private lateinit var instance: Webtrekk
    private val configAdapter = ConfigAdapter()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_mappintelligence")
        channel?.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
        val messenger = flutterPluginBinding.binaryMessenger
        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory(
                "plugin_mappintelligence/webview",
                WebViewFactory(messenger,  /*containerView=*/null)
            )
        flutterCookieManager = FlutterCookieManager(messenger)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            FlutterFunctions.GET_PLATFORM_VERSION -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            FlutterFunctions.INITIALIZE -> {
                init(call, result)
            }

            FlutterFunctions.SET_LOG_LEVEL -> {
                setLogLevel(call, result)
            }

            FlutterFunctions.SET_USER_MATCHING_ENABLED -> {
                setUserMatching(call, result)
            }

            FlutterFunctions.BATCH_SUPPORT -> {
                setBatchSupport(call, result)
            }

            FlutterFunctions.SET_REQUEST_INTERVAL -> {
                setRequestInterval(call, result)
            }

            FlutterFunctions.OPT_IN -> {
                setOptIn(result)
            }

            FlutterFunctions.OPT_OUT_WITH_DATA -> {
                setOptOut(call, result)
            }

            FlutterFunctions.BUILD -> {
                build(result)
            }

            FlutterFunctions.TRACK_PAGE -> {
                trackPage(call, result)
            }

            FlutterFunctions.TRACK_CUSTOM_PAGE -> {
                trackCustomPage(call, result)
            }

            FlutterFunctions.TRACK_OBJECT_PAGE_WITHOUT_DATA -> {
                trackObjectPage(call, result)
            }

            FlutterFunctions.TRACK_OBJECT_PAGE_WITH_DATA -> {
                trackObjectPageWithData(call, result)
            }

            FlutterFunctions.TRACK_ACTION -> {
                trackAction(call, result)
            }

            FlutterFunctions.TRACK_WITHOUT_MEDIA_CODE -> {
                trackUrl(call, result)
            }

            FlutterFunctions.TRACK_URL -> {
                trackUrl(call, result)
            }

            FlutterFunctions.TRACK_MEDIA -> {
                trackMedia(call, result)
            }

            FlutterFunctions.TRACK_WEB_VIEW -> {
            }

            FlutterFunctions.DISPOSE_WEB_VIEW -> {
            }
            //only iOS
            FlutterFunctions.SET_REQUEST_PER_QUEUE -> {
                result.success(iOS)
            }

            FlutterFunctions.RESET_CONFIG -> {
                reset(call, result)
            }

            FlutterFunctions.SET_TRACK_IDS_AND_DOMAIN -> {
                setTrackIdsAndDomain(call, result)
            }

            FlutterFunctions.GET_TRACK_IDS_AND_DOMAIN -> {
                getTrackIdsAndDomain(call, result)
            }

            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING -> {
                setAnonymousTracking(call, result)
            }

            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS -> {
                result.success(iOS)
            }

            FlutterFunctions.IS_ANONYMOUS_TRACKING_ENABLE -> {
                result.success(iOS)
            }

            FlutterFunctions.GET_EVER_ID -> {
                getEverId(call, result)
            }

            FlutterFunctions.GET_USER_AGENT -> {
                getUserAgent(call, result)
            }

            FlutterFunctions.SET_EVER_ID -> {
                setEverId(call, result)
            }

            FlutterFunctions.SEND_AND_CLEAN_DATA -> {
                sendAndCleanData(call, result)
            }

            FlutterFunctions.SET_SEND_APP_VERSION_IN_EVERY_REQUEST -> {
                setSendAppVersion(call, result)
            }

            FlutterFunctions.GET_CURRENT_CONFIG -> {
                getCurrentConfig(call, result)
            }

            FlutterFunctions.UPDATE_CUSTOM_PARAMS -> {
                call.arguments<List<String>>()?.get(0)?.let { flutterPluginVersion ->
                    updateCustomParams(flutterPluginVersion)
                }
                result.success("Ok")
            }

            FlutterFunctions.ENABLE_CRASH_TRACKING -> {
                enableCrashTracking(call, result)
            }

            FlutterFunctions.TRACK_EXCEPTION_WITH_NAME_AND_MESSAGE -> {
                trackExceptionWithNameAndMessage(call, result)
            }

            FlutterFunctions.TRACK_EXCEPTION_WITH_TYPE -> {

            }

            FlutterFunctions.RAISE_UNCAUGHT_EXCEPTION -> {
                result.success("ok")
                //Integer.parseInt("$$#@")
                throw Exception("CUSTOM UNCAUGHT EXCEPTION")
            }

            FlutterFunctions.PRINT_USAGE_STATISTICS_CALCULATION_LOG -> {
                printUsageStatisticsCalculationLog(call, result)
            }

            FlutterFunctions.SET_TEMPORARY_SESSION_ID -> {
                setTemporarySessionId(call, result)
            }

            FlutterFunctions.SET_BACKGROUND_SENDOUT -> {
                result.success("ok")
            }

            FlutterFunctions.DISABLE_AUTO_TRACKING -> {
                val disabled = call.arguments<Boolean>() == true
                disableAutoTracking(disabled, result)
            }

            FlutterFunctions.DISABLE_ACTIVITY_TRACKING -> {
                val disabled = call.arguments<Boolean>() == true
                disableActivityTracking(disabled, result)
            }

            FlutterFunctions.DISABLE_FRAGMENT_TRACKING -> {
                val disabled = call.arguments<Boolean>() == true
                disableFragmentTracking(disabled, result)
            }

            else -> result.notImplemented()
        }
    }

    private fun init(call: MethodCall, result: MethodChannel.Result) {
        val trackIds = call.arguments<HashMap<String, ArrayList<String>>>()
            ?.getOrElse("trackIds") { emptyList() }
        val trackDomain: String? =
            call.arguments<HashMap<String, String>>()?.getOrElse("trackDomain") { null }

        if (!trackIds.isNullOrEmpty() && !trackDomain.isNullOrBlank()) {
            runOnPlugin(whenInitialized = {
                instance.setIdsAndDomain(trackIds, trackDomain)
            }, whenNotInitialized = {
                configAdapter.trackDomain = trackDomain
                configAdapter.trackIds = trackIds
            })
        }
        result.success("Ok")
    }

    private fun setLogLevel(call: MethodCall, result: MethodChannel.Result) {
        val logLevel = call.arguments<ArrayList<Int>>()?.getOrElse(0) { 7 }
        val nativeLogLevel = if (logLevel == 7) Logger.Level.NONE else Logger.Level.BASIC
        runOnPlugin(whenInitialized = {
            instance.setLogLevel(nativeLogLevel)
        }, whenNotInitialized = {
            configAdapter.logLevel = nativeLogLevel
        })
        result.success("Ok")
    }

    private fun setUserMatching(call: MethodCall, result: MethodChannel.Result) {
        val enabled =
            call.arguments<Map<String, Boolean>>()?.get("enabled") ?: false
        runOnPlugin(whenInitialized = {
            instance.setUserMatchingEnabled(enabled)
        }, whenNotInitialized = {
            configAdapter.userMatchingEnabled = enabled
        })
        result.success("Ok")
    }

    private fun setBatchSupport(call: MethodCall, result: MethodChannel.Result) {
        val enabled = call.arguments<ArrayList<Boolean>>()?.getOrNull(0) ?: false
        val size = call.arguments<ArrayList<Int>>()?.getOrNull(1) ?: 50
        runOnPlugin(whenInitialized = {
            instance.setBatchEnabled(enabled)
            instance.setRequestPerBatch(size)
        }, whenNotInitialized = {
            configAdapter.batchSupport = enabled
            configAdapter.requestPerBatch = size
        })
        result.success("Ok")
    }

    private fun setRequestInterval(call: MethodCall, result: MethodChannel.Result) {
        val requestInterval = call.arguments<ArrayList<Int>>()?.getOrNull(0) ?: 15
        runOnPlugin(whenInitialized = {
            instance.setRequestInterval(requestInterval.toLong())
        }, whenNotInitialized = {
            configAdapter.requestsIntervalMinutes = requestInterval
        })
        result.success("Ok")
    }

    private fun setOptOut(call: MethodCall, result: MethodChannel.Result) {
        val enable = call.arguments<ArrayList<Boolean>>()?.getOrNull(0) ?: false
        runOnPlugin(whenInitialized = {
            instance.optOut(true, enable)
        })
        result.success("Ok")
    }

    private fun setOptIn(result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            instance.optOut(false)
        })
        result.success("Ok")
    }

    private fun trackPage(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { name ->
            runOnPlugin(whenInitialized = {
                instance.trackCustomPage(name)
            })
        }

        result.success("Ok")
    }

    private fun trackCustomPage(call: MethodCall, result: MethodChannel.Result) {
        val param = call.arguments<ArrayList<Map<String, String>>>()?.getOrNull(1) ?: emptyMap()
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { name ->
            runOnPlugin(whenInitialized = {
                instance.trackCustomPage(name, param)
            })
        }
        result.success("Ok")
    }

    private fun trackObjectPage(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { name ->
            runOnPlugin(whenInitialized = {
                instance.trackPage(PageViewEvent(name))
            })
        }
        result.success("Ok")
    }

    private fun trackObjectPageWithData(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { json ->
            runOnPlugin(whenInitialized = {
                val jsonObject = JSONObject(json)
                val name: String = jsonObject.getString("name")
                val pageViewEvent = PageViewEvent(name)
                val pageParameters: PageParameters? = toPageParams(jsonObject)
                val sessionParameters: SessionParameters? = toSessionParameters(jsonObject)
                val userCategories: UserCategories? = toUserCategories(jsonObject)
                val eCommerceParameters: ECommerceParameters? = toECommerceParameters(jsonObject)
                val campaignParameters: CampaignParameters? = toCampaignParameters(jsonObject)
                pageViewEvent.campaignParameters = campaignParameters
                pageViewEvent.pageParameters = pageParameters
                pageViewEvent.sessionParameters = sessionParameters
                pageViewEvent.userCategories = userCategories
                pageViewEvent.eCommerceParameters = eCommerceParameters
                instance.trackPage(pageViewEvent)
            })
        }
        result.success(true)
    }

    private fun trackAction(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { json ->
            runOnPlugin(whenInitialized = {
                val jsonObject = JSONObject(json)
                val name: String = jsonObject.optString("name")
                val pageViewEvent = ActionEvent(name)
                val sessionParameters: SessionParameters? = toSessionParameters(jsonObject)
                val eventParameters: EventParameters? = toEvenParam(jsonObject)
                val userCategories: UserCategories? = toUserCategories(jsonObject)
                val eCommerceParameters: ECommerceParameters? = toECommerceParameters(jsonObject)
                val campaignParameters: CampaignParameters? = toCampaignParameters(jsonObject)
                pageViewEvent.eventParameters = eventParameters
                pageViewEvent.campaignParameters = campaignParameters
                pageViewEvent.sessionParameters = sessionParameters
                pageViewEvent.userCategories = userCategories
                pageViewEvent.eCommerceParameters = eCommerceParameters
                instance.trackAction(pageViewEvent)
            })
        }
        result.success("Ok")
    }

    private fun trackUrl(call: MethodCall, result: MethodChannel.Result) {
        val mediaCode = call.arguments<ArrayList<String>>()?.getOrNull(1)
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { url ->
            runOnPlugin(whenInitialized = {
                if (mediaCode == null)
                    instance.trackUrl(Uri.parse(url))
                else
                    instance.trackUrl(Uri.parse(url), mediaCode)
            })
        }
        result.success("Ok")
    }

    private fun trackMedia(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<ArrayList<String>>()?.getOrNull(0)?.let { json ->
            runOnPlugin(whenInitialized = {
                val jsonObject = JSONObject(json)
                val name: String = jsonObject.getString("name")
                val mediaParameters: MediaParameters? = toMediaParameters(jsonObject)
                if (mediaParameters != null) {
                    val pageViewEvent = MediaEvent(name, mediaParameters)
                    val sessionParameters: SessionParameters? = toSessionParameters(jsonObject)
                    val eventParameters: EventParameters? = toEvenParam(jsonObject)
                    val eCommerceParameters: ECommerceParameters? =
                        toECommerceParameters(jsonObject)
                    pageViewEvent.eventParameters = eventParameters
                    pageViewEvent.sessionParameters = sessionParameters
                    pageViewEvent.eCommerceParameters = eCommerceParameters
                    Webtrekk.getInstance().trackMedia(pageViewEvent)
                }
            })
        }
        result.success("Ok")
    }

    private fun setTrackIdsAndDomain(call: MethodCall, result: MethodChannel.Result) {
        val trackIds = call.arguments<HashMap<String, ArrayList<String>>>()
            ?.getOrElse("trackIds") { emptyList() }
        val trackDomain: String? =
            call.arguments<HashMap<String, String>>()?.getOrElse("trackDomain") { null }
        if (!trackIds.isNullOrEmpty() && !trackDomain.isNullOrEmpty()) {
            runOnPlugin(whenInitialized = {
                instance.setIdsAndDomain(trackIds, trackDomain)
            }, whenNotInitialized = {
                configAdapter.trackDomain = trackDomain
                configAdapter.trackIds = trackIds
            })
        }
        result.success("Ok")
    }

    private fun getTrackIdsAndDomain(call: MethodCall, result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            val trackIds = Webtrekk.getInstance().getTrackIds()
            val trackDomain = Webtrekk.getInstance().getTrackDomain()
            val map = mutableMapOf<Any, Any>()
            map["trackIds"] = trackIds
            map["trackDomain"] = trackDomain
            result.success(map)
        }, whenNotInitialized = {
            result.error("Not Initialized", "Mapp SDK not initialized", null)
        })
    }

    private fun setAnonymousTracking(call: MethodCall, result: MethodChannel.Result) {
        val anonymousTracking: Boolean =
            call.arguments<HashMap<String, Boolean>>()?.getOrElse("anonymousTracking") { null }
                ?: false
        val params =
            call.arguments<HashMap<String, List<String>>>()?.getOrElse("params") { null }
                ?: emptySet()
        Log.d(
            this::class.java.name,
            "Enable Anonymous tracking: anonymousTracking:${anonymousTracking}, params: $params"
        )
        runOnPlugin(whenInitialized = {
            instance.anonymousTracking(
                enabled = anonymousTracking,
                suppressParams = params.toSet(),
            )
        }, whenNotInitialized = {
            configAdapter.anonymousTracking = anonymousTracking
            configAdapter.suppressParams = params.toSet()
        })
        result.success(true)
    }

    private fun getEverId(call: MethodCall, result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            val everId = instance.getEverId()
            result.success(everId ?: "")
        }, whenNotInitialized = {
            result.error("Not Initialized", "Mapp SDK not initialized!", null)
        })
    }

    private fun setEverId(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<List<String>>()?.getOrNull(0)?.let { everId ->
            runOnPlugin(whenInitialized = {
                instance.setEverId(everId)
            }, whenNotInitialized = {
                configAdapter.everId = everId
            })
        }
        result.success("Ok")
    }

    private fun getUserAgent(call: MethodCall, result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            val userAgent = instance.getUserAgent()
            result.success(userAgent ?: "")
        }, whenNotInitialized = {
            result.error("Not Initialized", "Mapp SDK not initialized!", null)
        })
    }

    private fun sendAndCleanData(call: MethodCall, result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            instance.sendRequestsNowAndClean()
            result.success("Ok")
        })
    }

    private fun setSendAppVersion(call: MethodCall, result: MethodChannel.Result) {
        val sendAppVersion = call.arguments<List<Boolean>>()?.getOrNull(0) ?: false
        runOnPlugin(whenInitialized = {
            instance.setVersionInEachRequest(sendAppVersion)
            result.success("Ok")
        }, whenNotInitialized = {
            configAdapter.versionInEachRequest = sendAppVersion
            result.success("Ok")
        })
    }

    private fun getCurrentConfig(call: MethodCall, result: MethodChannel.Result) {
        runOnPlugin(whenInitialized = {
            val activeConfig = instance.getCurrentConfiguration()
            val map = activeConfig.toMap()
            result.success(map)
        }, whenNotInitialized = {
            result.error("Not Initialized", "Mapp SDK not initialized!", null)
        })
    }

    private fun enableCrashTracking(call: MethodCall, result: MethodChannel.Result) {
        val logLevelIndex = call.arguments<List<Int>>()?.getOrNull(0)
        val level = ExceptionType.entries.firstOrNull { it.ordinal == logLevelIndex }
            ?: ExceptionType.ALL
        runOnPlugin(whenInitialized = {
            instance.setExceptionLogLevel(level)
        }, whenNotInitialized = {
            configAdapter.exceptionLogLevel = level
        })
        result.success("Ok")
    }

    private fun trackExceptionWithNameAndMessage(call: MethodCall, result: MethodChannel.Result) {
        val name = call.arguments<HashMap<String, String>>()?.getOrElse("name") { null } ?: ""
        val message: String =
            call.arguments<HashMap<String, String>>()?.getOrElse("message") { null } ?: ""
        if (name.isNotEmpty() && message.isNotEmpty()) {
            runOnPlugin(whenInitialized = {
                instance.trackException(name, message)
            }, whenNotInitialized = {
                result.error("Not Initialized", "Mapp SDK not initialized!", null)
            })
        }
    }

    private fun printUsageStatisticsCalculationLog(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        runOnPlugin(whenInitialized = {
            val currentConfig = instance.getCurrentConfiguration()
            val log = currentConfig.printUsageStatisticCalculation()
            result.success(log)
        }, whenNotInitialized = {
            result.error("Not Initialized", "Mapp SDK not initialized!", null)
        })
    }

    private fun setTemporarySessionId(call: MethodCall, result: MethodChannel.Result) {
        call.arguments<HashMap<String, String>>()?.getOrElse("temporarySessionId") { null }
            ?.let { sessionId ->
                runOnPlugin(whenInitialized = {
                    instance.setTemporarySessionId(sessionId)
                }, whenNotInitialized = {
                    configAdapter.temporarySessionId = sessionId
                })
            }

        result.success("ok")
    }

    private fun disableAutoTracking(disabled: Boolean, result: MethodChannel.Result) {
        configAdapter.autoTracking = !disabled
        result.success("ok")
    }

    private fun disableActivityTracking(disabled: Boolean, result: MethodChannel.Result) {
        configAdapter.activityAutoTracking = !disabled
        result.success("ok")
    }

    private fun disableFragmentTracking(disabled: Boolean, result: MethodChannel.Result) {
        configAdapter.fragmentsAutoTracking = !disabled
        result.success("ok")
    }

    private fun build(result: MethodChannel.Result) {
        runOnPlugin(whenNotInitialized = {
            val builder =
                WebtrekkConfiguration.Builder(configAdapter.trackIds, configAdapter.trackDomain)
                    .logLevel(configAdapter.logLevel)
                    .enableCrashTracking(configAdapter.exceptionLogLevel)
                    .setBatchSupport(configAdapter.batchSupport, configAdapter.requestPerBatch)
                    .requestsInterval(
                        TimeUnit.MINUTES,
                        configAdapter.requestsIntervalMinutes.toLong()
                    )
                    .setEverId(configAdapter.everId)
                    .sendAppVersionInEveryRequest(configAdapter.versionInEachRequest)
                    .setUserMatchingEnabled(configAdapter.userMatchingEnabled)

            if (configAdapter.shouldMigrate) builder.enableMigration()

            if (!configAdapter.autoTracking) builder.disableAutoTracking()

            if (!configAdapter.activityAutoTracking) builder.disableActivityAutoTracking()

            if (!configAdapter.fragmentsAutoTracking) builder.disableFragmentsAutoTracking()

            mContext?.let {
                Webtrekk.getInstance().init(it, builder.build())
                instance = Webtrekk.getInstance().apply {
                    this.anonymousTracking(
                        configAdapter.anonymousTracking,
                        configAdapter.suppressParams
                    )
                    this.setTemporarySessionId(configAdapter.temporarySessionId)
                }
            }
        }, whenInitialized = {})
        result.success("Ok")
    }

    private fun reset(call: MethodCall, result: MethodChannel.Result) {
        mContext?.let {
            runOnPlugin(whenInitialized = {
                Webtrekk.reset(it)
                instance = Webtrekk.getInstance()
                instance.setIdsAndDomain(configAdapter.trackIds, configAdapter.trackDomain)
            })
        }
        result.success("Ok")
    }

    /**
     * Helper function to execute actions based on Webtrekk instance state
     * Provide two functions as input parameters to be executed if instance is initialized or not
     */
    private fun runOnPlugin(whenInitialized: () -> Unit, whenNotInitialized: (() -> Unit)? = null) {
        if (::instance.isInitialized) whenInitialized.invoke()
        else whenNotInitialized?.invoke()
    }

    private fun updateCustomParams(flutterPluginVersion: String) {
        val defaultConfig = DefaultConfiguration::class
        val exactSdkVersionField = defaultConfig.java.getDeclaredField("exactSdkVersion")
        exactSdkVersionField.isAccessible = true
        exactSdkVersionField.set(this, flutterPluginVersion)
        exactSdkVersionField.isAccessible = false

        val platformField = defaultConfig.java.getDeclaredField("platform")
        platformField.isAccessible = true
        platformField.set(this, "Flutter")
        platformField.isAccessible = false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        if (flutterCookieManager == null) {
            return
        }
        flutterCookieManager!!.dispose()
        flutterCookieManager = null
    }


    private fun toMediaParameters(json: JSONObject): MediaParameters? {
        val pageParameters: MediaParameters
        val jsonOb = json.optJSONObject("mediaParameters")
        return if (jsonOb == null) {
            null
        } else {
            val name: String = jsonOb.optString("name")
            val action: String = jsonOb.optString("action")
            val position: Number = jsonOb.optDouble("position")
            val duration: Number = jsonOb.optDouble("duration")
            if (jsonOb.isNotNull("name") && jsonOb.isNotNull("action") && jsonOb.isNotNull("position") && jsonOb.isNotNull(
                    "duration"
                ) && !jsonOb.getDouble(
                    "duration"
                ).isNaN() && !jsonOb.optDouble("position").isNaN()
            ) {
                pageParameters = MediaParameters(name, action, position, duration)
                if (jsonOb.isNotNull("bandwith") && !jsonOb.optDouble("bandwith")
                        .isNaN()
                ) pageParameters.bandwith = jsonOb.optDouble("bandwith")
                if (jsonOb.isNotNull("soundIsMuted")) pageParameters.soundIsMuted =
                    jsonOb.optBoolean("soundIsMuted")
                if (jsonOb.isNotNull("soundVolume")) pageParameters.soundVolume =
                    jsonOb.optInt("soundVolume")
                val category: Map<Int, String> = jsonOb.optJSONObject("customCategories").toMap()
                pageParameters.customCategories = category
            } else {
                return null
            }
            pageParameters
        }
    }

    private fun toPageParams(json: JSONObject): PageParameters? {
        val pageParameters: PageParameters
        val jsonOb = json.optJSONObject("pageParameters")
        return if (jsonOb == null) {
            null
        } else {
            pageParameters = PageParameters()
            val parameters: Map<Int, String> = jsonOb.optJSONObject("params").toMap()
            val search: String = jsonOb.optString("searchTerm")
            val pageCategory: Map<Int, String> = jsonOb.optJSONObject("categories").toMap()
            pageParameters.parameters = parameters
            if (jsonOb.isNotNull("searchTerm")) pageParameters.search = search
            pageParameters.pageCategory = pageCategory
            pageParameters
        }

    }

    private fun toEvenParam(json: JSONObject): EventParameters? {
        val pageParameters: EventParameters
        val jsonOb = json.optJSONObject("eventParameters")
        return if (jsonOb == null) {
            null
        } else {
            pageParameters = EventParameters()
            pageParameters.customParameters = jsonOb.optJSONObject("parameters").toMap()
            pageParameters
        }

    }

    private fun toSessionParameters(json: JSONObject): SessionParameters? {
        val param: SessionParameters
        val jsonOb = json.optJSONObject("sessionParameters")
        return if (jsonOb == null) {
            null
        } else {
            param = SessionParameters()
            param.parameters = jsonOb.optJSONObject("parameters").toMap()
            param
        }
    }

    private fun JSONObject.isNotNull(key: String): Boolean {
        return this.has(key) && !this.optString(key).equals("null") && this.opt(key) != null
    }

    private fun toUserCategories(json: JSONObject): UserCategories? {
        val param: UserCategories
        val jsonOb = json.optJSONObject("userCategories")
        return if (jsonOb == null) {
            null
        } else {
            param = UserCategories()
            param.birthday = toBirthday(jsonOb)
            if (jsonOb.isNotNull("city")) param.city = jsonOb.optString("city")
            if (jsonOb.isNotNull("country")) param.country = jsonOb.optString("country")
            if (jsonOb.isNotNull("emailAddress")) param.emailAddress =
                jsonOb.optString("emailAddress")
            if (jsonOb.isNotNull("emailReceiverId")) param.emailReceiverId =
                jsonOb.optString("emailReceiverId")
            if (jsonOb.isNotNull("firstName")) param.firstName = jsonOb.optString("firstName")
            if (jsonOb.isNotNull("gender"))
                param.gender = UserCategories.Gender.values()[jsonOb.optInt("gender")]
            if (jsonOb.isNotNull("customerId")) param.customerId = jsonOb.optString("customerId")
            if (jsonOb.isNotNull("lastName")) param.lastName = jsonOb.optString("lastName")
            if (jsonOb.isNotNull("newsletterSubscribed")) param.newsletterSubscribed =
                jsonOb.optBoolean("newsletterSubscribed")
            if (jsonOb.isNotNull("phoneNumber")) param.phoneNumber = jsonOb.optString("phoneNumber")
            if (jsonOb.isNotNull("street")) param.street = jsonOb.optString("street")
            if (jsonOb.isNotNull("streetNumber")) param.streetNumber =
                jsonOb.optString("streetNumber")
            if (jsonOb.isNotNull("zipCode")) param.zipCode = jsonOb.optString("zipCode")
            if (jsonOb.isNotNull("customCategories")) param.customCategories =
                jsonOb.optJSONObject("customCategories").toMap()
            param
        }

    }

    private fun toBirthday(json: JSONObject): UserCategories.Birthday? {
        val param: UserCategories.Birthday
        val jsonOb = json.optJSONObject("birthday")
        return if (jsonOb == null) {
            null
        } else {
            if (jsonOb.isNotNull("day") && jsonOb.isNotNull("month") && jsonOb.isNotNull("year"))
                param = UserCategories.Birthday(
                    jsonOb.optInt("day"),
                    jsonOb.optInt("month"),
                    jsonOb.optInt("year")
                ) else {
                return null
            }
            param
        }

    }

    private fun toProduct(json: JSONObject): List<ProductParameters> {
        val param: MutableList<ProductParameters> = mutableListOf()
        val jsonOb = json.optJSONArray("products")
        return if (jsonOb == null) {
            param
        } else {
            for (i in 0 until jsonOb.length()) {
                val product = ProductParameters()
                val objectInArray: JSONObject = jsonOb.getJSONObject(i)
                product.name = objectInArray.optString("name")
                if (objectInArray.isNotNull("cost") && !objectInArray.optDouble("cost")
                        .isNaN()
                ) product.cost = objectInArray.optDouble("cost")
                if (objectInArray.isNotNull("quantity")) product.quantity =
                    objectInArray.optInt("quantity")
                if (objectInArray.isNotNull("productAdvertiseID")) product.productAdvertiseID =
                    objectInArray.optDouble("productAdvertiseID")
                if (objectInArray.isNotNull("productSoldOut")
                ) {
                    product.productSoldOut = objectInArray.optBoolean("productSoldOut")
                }
                if (objectInArray.isNotNull("productVariant")) product.productVariant =
                    objectInArray.optString("productVariant")
                product.categories = objectInArray.optJSONObject("categories").toMap()
                product.ecommerceParameters =
                    objectInArray.optJSONObject("ecommerceParameters").toMap()
                param.add(product)
            }
            param
        }

    }

    private fun toECommerceParameters(json: JSONObject): ECommerceParameters? {
        val param: ECommerceParameters
        val jsonOb = json.optJSONObject("ecommerceParameters")
        return if (jsonOb == null) {
            null
        } else {
            param = ECommerceParameters()
            param.products = toProduct(jsonOb)
            if (jsonOb.isNotNull("status")) param.status =
                ECommerceParameters.Status.values()[jsonOb.optInt("status")]
            if (jsonOb.isNotNull("currency")) param.currency = jsonOb.optString("currency")
            if (jsonOb.isNotNull("orderID")) param.orderID = jsonOb.optString("orderID")
            if (jsonOb.isNotNull("orderValue")) param.orderValue = jsonOb.optDouble("orderValue")
            if (jsonOb.isNotNull("returningOrNewCustomer")) param.returningOrNewCustomer =
                jsonOb.optString("returningOrNewCustomer")
            if (jsonOb.isNotNull("returnValue") && !jsonOb.optDouble("returnValue")
                    .isNaN()
            ) param.returnValue = jsonOb.optDouble("returnValue")
            if (jsonOb.isNotNull("cancellationValue")) param.cancellationValue =
                jsonOb.optDouble("cancellationValue")
            if (jsonOb.isNotNull("couponValue") && !jsonOb.optDouble("couponValue")
                    .isNaN()
            ) param.couponValue = jsonOb.optDouble("couponValue")

            if (jsonOb.isNotNull("paymentMethod")) param.paymentMethod =
                jsonOb.optString("paymentMethod")
            if (jsonOb.isNotNull("shippingServiceProvider")) param.shippingServiceProvider =
                jsonOb.optString("shippingServiceProvider")
            if (jsonOb.isNotNull("shippingSpeed")) param.shippingSpeed =
                jsonOb.optString("shippingSpeed")
            if (jsonOb.isNotNull("shippingCost") && !jsonOb.optDouble("shippingCost")
                    .isNaN()
            ) param.shippingCost = jsonOb.optDouble("shippingCost")

            if (jsonOb.isNotNull("markUp")) param.markUp = jsonOb.optDouble("markUp")
            if (jsonOb.isNotNull("orderStatus")) param.orderStatus = jsonOb.optString("orderStatus")
            if (jsonOb.isNotNull("customParameters")) param.customParameters =
                jsonOb.optJSONObject("customParameters").toMap()
            param
        }
    }

    private fun toCampaignParameters(json: JSONObject): CampaignParameters? {
        val param: CampaignParameters
        val jsonOb = json.optJSONObject("campaignParameters")
        return if (jsonOb == null) {
            null
        } else {
            param = CampaignParameters()
            if (jsonOb.isNotNull("campaignId")) param.campaignId = jsonOb.optString("campaignId")
            if (jsonOb.isNotNull("action")) param.action =
                CampaignParameters.CampaignAction.values()[jsonOb.optInt("action")]
            param.mediaCode = jsonOb.optString("mediaCode", "wt_mc")
            if (jsonOb.isNotNull("oncePerSession")) param.oncePerSession =
                jsonOb.optBoolean("oncePerSession")
            param.customParameters = jsonOb.optJSONObject("campaignId").toMap()
            param
        }
    }

    private fun JSONObject?.toMap(): MutableMap<Int, String> {
        if (this == null) {
            return emptyMap<Int, String>().toMutableMap()
        }
        val keys: Iterator<String> = keys()
        val mapp = mutableMapOf<Int, String>()
        while (keys.hasNext()) {
            val key: String = keys.next()
            val value: String = getString(key)
            mapp[key.toInt()] = value
        }
        return mapp
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
        const val TRACK_MEDIA = "trackMedia"
        const val TRACK_WEB_VIEW = "trackWebview"
        const val DISPOSE_WEB_VIEW = "disposeWebview"
        const val BUILD = "build"
        const val GET_EVER_ID = "getEverId"
        const val GET_USER_AGENT = "getUserAgent"
        const val UPDATE_CUSTOM_PARAMS = "updateCustomParams"

        const val SET_EVER_ID = "setEverId"
        const val RESET_CONFIG = "resetConfig"
        const val SEND_AND_CLEAN_DATA = "sendAndCleanData"
        const val SET_TRACK_IDS_AND_DOMAIN = "setIdsAndDomain"
        const val GET_TRACK_IDS_AND_DOMAIN = "getIdsAndDomain"
        const val SET_SEND_APP_VERSION_IN_EVERY_REQUEST = "setSendAppVersionInEveryRequest"
        const val ENABLE_CRASH_TRACKING = "enableCrashTracking"
        const val ENABLE_ANONYMOUS_TRACKING = "enableAnonymousTracking"
        const val SET_USER_MATCHING_ENABLED = "setUserMatchingEnabled"

        const val TRACK_EXCEPTION_WITH_NAME_AND_MESSAGE = "trackExceptionWithNameAndMessage"
        const val TRACK_EXCEPTION_WITH_TYPE = "trackExceptionWithType"
        const val TRACK_ERROR = "trackError"
        const val RAISE_UNCAUGHT_EXCEPTION = "raiseUncaughtException"
        const val GET_CURRENT_CONFIG = "getCurrentConfig"
        const val DISABLE_AUTO_TRACKING = "disableAutoTracking"
        const val DISABLE_FRAGMENT_TRACKING = "disableFragmentTracking"
        const val DISABLE_ACTIVITY_TRACKING = "disableActivityTracking"

        //Only iOS
        const val SET_REQUEST_PER_QUEUE = "setRequestPerQueue"
        const val ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS =
            "enableAnonymousTrackingWithParameters"
        const val IS_ANONYMOUS_TRACKING_ENABLE = "isAnonymousTrackingEnabled"
        const val PRINT_USAGE_STATISTICS_CALCULATION_LOG = "printUsageStatisticsCalculationLog"
        const val SET_TEMPORARY_SESSION_ID = "setTemporarySessionId"
        const val SET_BACKGROUND_SENDOUT = "setEnableBackgroundSendout"
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        channel?.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
        channel?.setMethodCallHandler(null)
    }
}
