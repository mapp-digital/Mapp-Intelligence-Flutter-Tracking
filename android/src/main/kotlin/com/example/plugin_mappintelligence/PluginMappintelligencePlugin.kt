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
import java.lang.Exception
import java.util.*
import org.json.JSONObject
import webtrekk.android.sdk.ActiveConfig
import webtrekk.android.sdk.Config
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
import kotlin.collections.HashMap

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

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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

    var webtrekkConfigurations: WebtrekkConfiguration.Builder? = null

    var config: Config? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            FlutterFunctions.GET_PLATFORM_VERSION -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            FlutterFunctions.INITIALIZE -> {
                val trackIds = call.arguments<HashMap<String, ArrayList<String>>>()!!["trackIds"]
                val trackDomain: String? =
                    call.arguments<HashMap<String, String>>()!!["trackDomain"]
                if (trackIds != null && trackDomain != null) {
                    webtrekkConfigurations = WebtrekkConfiguration.Builder(
                        trackIds,
                        trackDomain
                    ).disableAutoTracking()
                        .enableCrashTracking(ExceptionType.NONE)

                    mContext?.let {
                        Webtrekk.getInstance().init(context = it, webtrekkConfigurations!!.build())
                    }
                }
                result.success("Ok")
            }

            FlutterFunctions.SET_LOG_LEVEL -> {
                val logLevel = call.arguments<ArrayList<Int>>()!![0]
                if (logLevel == 7) {
                    webtrekkConfigurations?.logLevel(Logger.Level.NONE)
                    Webtrekk.getInstance().setLogLevel(Logger.Level.NONE)
                } else {
                    webtrekkConfigurations?.logLevel(Logger.Level.BASIC)
                    Webtrekk.getInstance().setLogLevel(Logger.Level.BASIC)
                }
                result.success("Ok")
            }

            FlutterFunctions.SET_USER_MATCHING_ENABLED -> {
                val args = call.arguments<Map<String, Boolean>>()
                val enabled = args?.get("enabled")
                enabled?.let {
                    webtrekkConfigurations?.setUserMatchingEnabled(it)
                    Webtrekk.getInstance().setUserMatchingEnabled(it)
                }
                result.success("Ok")
            }

            FlutterFunctions.BATCH_SUPPORT -> {
                val enable = call.arguments<ArrayList<Boolean>>()!![0]
                val size = call.arguments<ArrayList<Int>>()!![1]
                webtrekkConfigurations?.setBatchSupport(enable, size)
                Webtrekk.getInstance().setBatchEnabled(enable)
                Webtrekk.getInstance().setRequestPerBatch(size)
                result.success("Ok")

            }

            FlutterFunctions.SET_REQUEST_INTERVAL -> {
                val requestInterval = call.arguments<ArrayList<Int>>()!![0]
                webtrekkConfigurations?.requestsInterval(interval = requestInterval.toLong())
                Webtrekk.getInstance().setRequestInterval(requestInterval.toLong())
                result.success("Ok")

            }

            FlutterFunctions.OPT_IN -> {
                Webtrekk.getInstance().optOut(false)
                result.success("Ok")

            }

            FlutterFunctions.OPT_OUT_WITH_DATA -> {
                val enable = call.arguments<ArrayList<Boolean>>()!![0]
                Webtrekk.getInstance().optOut(true, enable)
                result.success("Ok")
            }

            FlutterFunctions.BUILD -> {
                webtrekkConfigurations?.let {
                    config = it.build()
                    mContext?.let {
                        Webtrekk.getInstance().init(it.applicationContext, config!!)
                    }
                }

                result.success("Ok")
            }

            FlutterFunctions.TRACK_PAGE -> {
                val name = call.arguments<ArrayList<String>>()!![0]
                // val param = call.arguments<ArrayList<HashMap<String,String>>>()[1]
                Webtrekk.getInstance().trackCustomPage(name)
            }

            FlutterFunctions.TRACK_CUSTOM_PAGE -> {
                val name = call.arguments<ArrayList<String>>()!![0]
                val param = call.arguments<ArrayList<HashMap<String, String>>>()!![1]
                Webtrekk.getInstance().trackCustomPage(name, param)
            }

            FlutterFunctions.TRACK_OBJECT_PAGE_WITHOUT_DATA -> {
                val name = call.arguments<ArrayList<String>>()!![0]
                Webtrekk.getInstance().trackPage(PageViewEvent(name))

            }

            FlutterFunctions.TRACK_OBJECT_PAGE_WITH_DATA -> {
                val json = call.arguments<ArrayList<String>>()!![0]
                objectTrackingPage(json)
            }

            FlutterFunctions.TRACK_ACTION -> {
                val json = call.arguments<ArrayList<String>>()!![0]
                objectAction(json)
            }

            FlutterFunctions.TRACK_WITHOUT_MEDIA_CODE -> {
                val url = call.arguments<ArrayList<String>>()!![0]
                Webtrekk.getInstance().trackUrl(Uri.parse(url))
            }

            FlutterFunctions.TRACK_URL -> {
                val mediaCode = call.arguments<ArrayList<String>>()!![1]
                val url = call.arguments<ArrayList<String>>()!![0]
                Webtrekk.getInstance().trackUrl(Uri.parse(url), mediaCode)
            }

            FlutterFunctions.TRACK_MEDIA -> {
                val json = call.arguments<ArrayList<String>>()!![0]
                objectMedia(json)
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
                mContext?.let {
                    Webtrekk.reset(it)
                }
                result.success("Ok")
            }

            FlutterFunctions.SET_TRACK_IDS_AND_DOMAIN -> {
                val trackIds = call.arguments<HashMap<String, ArrayList<String>>>()!!["trackIds"]
                val trackDomain: String? =
                    call.arguments<HashMap<String, String>>()!!["trackDomain"]
                if (!trackIds.isNullOrEmpty() && !trackDomain.isNullOrBlank())
                    Webtrekk.getInstance().setIdsAndDomain(trackIds, trackDomain)
                result.success("Ok")
            }

            FlutterFunctions.GET_TRACK_IDS_AND_DOMAIN -> {
                val trackIds = Webtrekk.getInstance().getTrackIds()
                val trackDomain = Webtrekk.getInstance().getTrackDomain()
                val map = mutableMapOf<Any, Any>()
                map["trackIds"] = trackIds
                map["trackDomain"] = trackDomain
                result.success(map)
            }

            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING -> {
                val anonymousTracking: Boolean? =
                    call.arguments<HashMap<String, Boolean>>()!!["anonymousTracking"]
                val params =
                    call.arguments<HashMap<String, List<String>>>()!!["params"] ?: emptyList()
                val generateNewEverId: Boolean? =
                    call.arguments<HashMap<String, Boolean>>()!!["generateNewEverId"]

                Webtrekk.getInstance().anonymousTracking(
                    enabled = anonymousTracking!!,
                    suppressParams = params.toSet(),
                )

                Log.d(
                    this::class.java.name,
                    "Enable Anonymous tracking: anonymousTracking:${anonymousTracking}, params: ${params}, generateNewEverId:${generateNewEverId}"
                )
                result.success(anonymousTracking)
            }

            FlutterFunctions.ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS -> {
                result.success(iOS)
            }

            FlutterFunctions.IS_ANONYMOUS_TRACKING_ENABLE -> {
                result.success(iOS)
            }

            FlutterFunctions.GET_EVER_ID -> {
                val everId=Webtrekk.getInstance().getEverId()
                result.success(everId ?: "")
            }

            FlutterFunctions.GET_USER_AGENT -> {
                result.success(Webtrekk.getInstance().getUserAgent())
            }

            FlutterFunctions.SET_EVER_ID -> {
                val everId = call.arguments<List<String>>()!![0]
                Webtrekk.getInstance().setEverId(everId)
                result.success("Ok")
            }

            FlutterFunctions.SEND_AND_CLEAN_DATA -> {
                Webtrekk.getInstance().sendRequestsNowAndClean()
                result.success("Ok")
            }

            FlutterFunctions.SET_SEND_APP_VERSION_IN_EVERY_REQUEST -> {
                val sendAppVersion = call.arguments<ArrayList<Boolean>>()!![0]
                Webtrekk.getInstance().setVersionInEachRequest(sendAppVersion)
                result.success("Ok")
            }

            FlutterFunctions.GET_CURRENT_CONFIG -> {
                val activeConfig = Webtrekk.getInstance().getCurrentConfiguration()
                val map = activeConfig.toMap()
                result.success(map)
            }

            FlutterFunctions.UPDATE_CUSTOM_PARAMS -> {
                val flutterPluginVersion = call.arguments<List<String>>()!![0]
                updateCustomParams(flutterPluginVersion)
                result.success("Ok")
            }

            FlutterFunctions.ENABLE_CRASH_TRACKING -> {
                val logLevelIndex = call.arguments<List<Int>>()!![0]
                val validLogLevel =
                    ExceptionType.values().map { it.ordinal }.contains(logLevelIndex)
                val logLevel =
                    if (validLogLevel) ExceptionType.values()[logLevelIndex] else ExceptionType.ALL
                Webtrekk.getInstance().setExceptionLogLevel(logLevel)
                result.success("Ok")
            }

            FlutterFunctions.TRACK_EXCEPTION_WITH_NAME_AND_MESSAGE -> {
                val name = call.arguments<HashMap<String, String>>()!!["name"] ?: ""
                val message: String = call.arguments<HashMap<String, String>>()!!["message"] ?: ""
                if (name.isNotEmpty() && message.isNotEmpty()) {
                    Webtrekk.getInstance()
                        .trackException(name, message)
                }
            }

            FlutterFunctions.TRACK_EXCEPTION_WITH_TYPE -> {

            }

            FlutterFunctions.RAISE_UNCAUGHT_EXCEPTION -> {
                //Integer.parseInt("$$#@")
                throw Exception("CUSTOM UNCAUGHT EXCEPTION")
                result.success("ok")
            }

            FlutterFunctions.PRINT_USAGE_STATISTICS_CALCULATION_LOG->{
                val log=printUsageStatisticsCalculationLog()
                result.success(log)
            }

            FlutterFunctions.SET_TEMPORARY_SESSION_ID->{
                val sessionId=call.arguments<HashMap<String, String>>()?.get("temporarySessionId")
                if(sessionId.isNullOrEmpty()){
                    result.error("","Temporary session id should not be null or empty",null)
                }else{
                    Webtrekk.getInstance().setTemporarySessionId(sessionId)
                    result.success("ok")
                }
            }

            else -> result.notImplemented()
        }
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

    private fun objectTrackingPage(data: String) {
        val jsonObject = JSONObject(data)
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
        Webtrekk.getInstance().trackPage(pageViewEvent)
    }

    private fun objectAction(data: String) {
        val jsonObject = JSONObject(data)
        val name: String = jsonObject.getString("name")
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
        Webtrekk.getInstance().trackAction(pageViewEvent)
    }

    companion object {
        /**
         * Registers a plugin implementation that uses the stable `io.flutter.plugin.common`
         * package.
         *
         *
         * Calling this automatically initializes the plugin. However plugins initialized this way
         * won't react to changes in activity or context, unlike [CameraPlugin].
         */
        fun registerWith(registrar: PluginRegistry.Registrar) {
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    "plugin_mappintelligence/webview",
                    WebViewFactory(registrar.messenger(), registrar.view())
                )
            FlutterCookieManager(registrar.messenger())
        }
    }

    private fun objectMedia(data: String) {
        val jsonObject = JSONObject(data)
        val name: String = jsonObject.getString("name")
        val mediaParameters: MediaParameters? = toMediaParameters(jsonObject)
        if (mediaParameters != null) {
            val pageViewEvent = MediaEvent(name, mediaParameters)
            val sessionParameters: SessionParameters? = toSessionParameters(jsonObject)
            val eventParameters: EventParameters? = toEvenParam(jsonObject)
            val eCommerceParameters: ECommerceParameters? = toECommerceParameters(jsonObject)
            pageViewEvent.eventParameters = eventParameters
            pageViewEvent.sessionParameters = sessionParameters
            pageViewEvent.eCommerceParameters = eCommerceParameters
            Webtrekk.getInstance().trackMedia(pageViewEvent)
        }
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

    private fun printUsageStatisticsCalculationLog():String {
        val currentConfig = Webtrekk.getInstance().getCurrentConfiguration()
        val log=currentConfig.printUsageStatisticCalculation()
        return log
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

        //Only iOS
        const val SET_REQUEST_PER_QUEUE = "setRequestPerQueue"
        const val ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS =
            "enableAnonymousTrackingWithParameters"
        const val IS_ANONYMOUS_TRACKING_ENABLE = "isAnonymousTrackingEnabled"
        const val PRINT_USAGE_STATISTICS_CALCULATION_LOG = "printUsageStatisticsCalculationLog"
        const val SET_TEMPORARY_SESSION_ID="setTemporarySessionId"
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
