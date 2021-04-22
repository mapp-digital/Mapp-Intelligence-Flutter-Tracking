package com.example.plugin_mappintelligence

import android.content.Context
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import webtrekk.android.sdk.Logger
import webtrekk.android.sdk.MediaParam
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

/** PluginMappintelligencePlugin */
class PluginMappintelligencePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mContext: Context


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_mappintelligence")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
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
                webtrekkConfigurations.disableAutoTracking()
                result.success("Ok")

            }
            FlutterFunctions.SET_LOG_LEVEL -> {
                val logLevel = call.arguments<ArrayList<Int>>()[0]
                if (logLevel == 7) {
                    webtrekkConfigurations.logLevel(Logger.Level.NONE)
                } else {
                    webtrekkConfigurations.logLevel(Logger.Level.BASIC)
                }
                result.success("Ok")

            }
            FlutterFunctions.BATCH_SUPPORT -> {
                val enable = call.arguments<ArrayList<Boolean>>()[0]
                val interval = call.arguments<ArrayList<Int>>()[1]
                webtrekkConfigurations.setBatchSupport(enable, interval)
                result.success("Ok")

            }
            FlutterFunctions.SET_REQUEST_INTERVAL -> {
                val requestInterval = call.arguments<ArrayList<Int>>()[0]
                webtrekkConfigurations.requestsInterval(interval = requestInterval.toLong())
                result.success("Ok")

            }
            FlutterFunctions.OPT_IN -> {
                Webtrekk.getInstance().optOut(false)
                result.success("Ok")

            }
            FlutterFunctions.OPT_OUT_WITH_DATA -> {
                val enable = call.arguments<ArrayList<Boolean>>()[0]
                Webtrekk.getInstance().optOut(true, enable)
                result.success("Ok")

            }
            FlutterFunctions.BUILD -> {
//                val configBuild = webtrekkConfigurations.build()
//                Webtrekk.getInstance().init(mContext.applicationContext, configBuild)
//                result.success("Ok")

            }
            FlutterFunctions.TRACK_PAGE -> {
                val name = call.arguments<ArrayList<String>>()[0]
                // val param = call.arguments<ArrayList<HashMap<String,String>>>()[1]
                Webtrekk.getInstance().trackCustomPage(name)
            }
            FlutterFunctions.TRACK_CUSTOM_PAGE -> {
                val name = call.arguments<ArrayList<String>>()[0]
                val param = call.arguments<ArrayList<HashMap<String, String>>>()[1]
                Webtrekk.getInstance().trackCustomPage(name, param)
            }
            FlutterFunctions.TRACK_OBJECT_PAGE_WITHOUT_DATA -> {
                val name = call.arguments<ArrayList<String>>()[0]
                Webtrekk.getInstance().trackPage(PageViewEvent(name))

            }
            FlutterFunctions.TRACK_OBJECT_PAGE_WITH_DATA -> {
                val json = call.arguments<ArrayList<String>>()[0]
                objectTrackingPage(json)
            }
            FlutterFunctions.TRACK_ACTION -> {
                val json = call.arguments<ArrayList<String>>()[0]
                objectAction(json)
            }
            FlutterFunctions.TRACK_WITHOUT_MEDIA_CODE -> {
                val url = call.arguments<ArrayList<String>>()[0]
                Webtrekk.getInstance().trackUrl(Uri.parse(url))
            }
            FlutterFunctions.TRACK_URL -> {
                val mediaCode = call.arguments<ArrayList<String>>()[1]
                val url = call.arguments<ArrayList<String>>()[0]
                Webtrekk.getInstance().trackUrl(Uri.parse(url), mediaCode)
            }
            FlutterFunctions.TRACK_MEDIA -> {
                val json = call.arguments<ArrayList<String>>()[0]
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
            pageParameters = MediaParameters(name, action, position, duration)
            pageParameters.bandwith = jsonOb.optDouble("name")
            pageParameters.soundIsMuted = jsonOb.optBoolean("soundIsMuted")
            pageParameters.soundVolume = jsonOb.optInt("soundVolume")
            val category: Map<Int, String> = jsonOb.optJSONObject("customCategories").toMap()
            pageParameters.customCategories = category
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
            pageParameters.search = search
            pageParameters.pageCategory = pageCategory
            pageParameters
        }

    }

    private fun toEvenParam(json: JSONObject): EventParameters? {
        val pageParameters: EventParameters
        val jsonOb = json.optJSONObject("")
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

    private fun toUserCategories(json: JSONObject): UserCategories? {
        val param: UserCategories
        val jsonOb = json.optJSONObject("userCategories")
        return if (jsonOb == null) {
            null
        } else {
            param = UserCategories()
            param.gender = UserCategories.Gender.values()[jsonOb.optInt("gender")]
            param.birthday = toBirthday(jsonOb)
            param.city = jsonOb.optString("city")
            param.country = jsonOb.optString("country")
            param.emailAddress = jsonOb.optString("emailAddress")
            param.emailReceiverId = jsonOb.optString("emailReceiverId")
            param.firstName = jsonOb.optString("firstName")
            param.customerId = jsonOb.optString("customerId")
            param.lastName = jsonOb.optString("lastName")
            param.phoneNumber = jsonOb.optString("phoneNumber")
            param.street = jsonOb.optString("street")
            param.streetNumber = jsonOb.optString("streetNumber")
            param.zipCode = jsonOb.optString("zipCode")
            param.newsletterSubscribed = jsonOb.optBoolean("newsletterSubscribed")
            param.customCategories = jsonOb.optJSONObject("customCategories").toMap()
            param
        }

    }

    private fun toBirthday(json: JSONObject): UserCategories.Birthday? {
        val param: UserCategories.Birthday
        val jsonOb = json.optJSONObject("birthday")
        return if (jsonOb == null) {
            null
        } else {
            param = UserCategories.Birthday(
                jsonOb.optInt("day"),
                jsonOb.optInt("month"),
                jsonOb.optInt("year")
            )
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
                product.cost = objectInArray.optDouble("cost")
                product.quantity = objectInArray.optInt("quantity")
                product.categories = objectInArray.optJSONObject("categories").toMap()
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
            param.status = ECommerceParameters.Status.values()[jsonOb.optInt("status")]
            param.orderID = jsonOb.optString("status")
            param.orderValue = jsonOb.optInt("orderValue")
            param.returningOrNewCustomer = jsonOb.optString("returningOrNewCustomer")
            param.returnValue = jsonOb.optDouble("returnValue")
            param.cancellationValue = jsonOb.optDouble("cancellationValue")
            param.couponValue = jsonOb.optDouble("couponValue")
            param.productAdvertiseID = jsonOb.optDouble("productAdvertiseID")
            param.productSoldOut = jsonOb.optDouble("productSoldOut")
            param.paymentMethod = jsonOb.optString("paymentMethod")
            param.shippingServiceProvider = jsonOb.optString("shippingServiceProvider")
            param.shippingSpeed = jsonOb.optString("shippingSpeed")
            param.shippingCost = jsonOb.optDouble("shippingCost")
            param.productVariant = jsonOb.optString("productVariant")
            param.customParameters = jsonOb.optJSONObject("customParameters").toMap()
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
            param.campaignId = jsonOb.optString("campaignId")
            param.action = CampaignParameters.CampaignAction.values()[jsonOb.optInt("action")]
            param.mediaCode = jsonOb.optString("mediaCode", "wt_mc")
            param.oncePerSession = jsonOb.optBoolean("oncePerSession")
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

        //Only iOS
        const val SET_REQUEST_PER_QUEUE = "setRequestPerQueue"
        const val RESET = "reset"
        const val ENABLE_ANONYMOUS_TRACKING = "enableAnonymousTracking"
        const val ENABLE_ANONYMOUS_TRACKING_WITH_PARAMETERS =
            "enableAnonymousTrackingWithParameters"
        const val IS_ANONYMOUS_TRACKING_ENABLE = "isAnonymousTrackingEnabled"
    }
}
