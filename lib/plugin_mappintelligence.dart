import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'object_tracking_classes.dart';

class PluginMappintelligence {
  static const MethodChannel _channel =
      const MethodChannel('plugin_mappintelligence');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> initialize(
      List<String> trackIds, String trackDomain) async {
    final String? version = await _channel.invokeMethod('initialize',
        <dynamic, dynamic>{'trackIds': trackIds, 'trackDomain': trackDomain});
    return 'successfull $version';
  }

  static Future<String?> setLogLevel(LogLevel logLevel) async {
    final String? version =
        await _channel.invokeMethod('setLogLevel', [logLevel.index + 1]);
    return '$version';
  }

  static Future<String?> setBatchSupportEnabledWithSize(
      bool isEnabled, int size) async {
    final String? version = await _channel
        .invokeMethod('setBatchSupportEnabledWithSize', [isEnabled, size]);
    return 'successfull $version';
  }

  static Future<String?> setRequestInterval(int intervalSize) async {
    final String? version =
        await _channel.invokeMethod('setRequestInterval', [intervalSize]);
    return 'successfull $version';
  }

  static Future<String?> setRequestPerQueue(int requestNumber) async {
    final String? version =
        await _channel.invokeMethod('setRequestPerQueue', [requestNumber]);
    return 'successfull $version';
  }

  static Future<String?> setSendAppVersionInEveryRequest(bool value) async {
    final String? version =
        await _channel.invokeMethod('setSendAppVersionInEveryRequest', [value]);
    return 'successfull $version';
  }

  static Future<String?> enableCrashTracking(ExceptionType value) async {
    final String? version =
        await _channel.invokeMethod('enableCrashTracking', [value.index]);
    return 'successfull $version';
  }

  static Future<void> optIn() async {
    await _channel.invokeMethod('OptIn');
  }

  static Future<void> optOutAndSendCurrentData(bool value) async {
    await _channel.invokeMethod('optOutAndSendCurrentData', [value]);
  }

  static Future<String> reset() async {
    return await _channel.invokeMethod('resetConfig');
  }

  static Future<void> trackPage(String customName,
      [Map<String, String>? trackingParameters]) async {
    if (trackingParameters == null) {
      await _channel.invokeMethod('trackPage', [customName]);
    } else {
      await _channel
          .invokeMethod('trackCustomPage', [customName, trackingParameters]);
    }
  }

  static Future<void> trackPageWithCustomData(PageViewEvent? pageViewEvent,
      [String? customName]) async {
    if (customName != null) {
      await _channel.invokeMethod(
          'trackPageWithCustomNameAndPageViewEvent', [customName]);
    } else if (pageViewEvent != null) {
      //debugPrint(jsonEncode(pageViewEvent.toJson()), wrapWidth: 1024);
      await _channel.invokeMethod(
          'trackPageWithCustomData', [jsonEncode(pageViewEvent.toJson())]);
    }
  }

  static Future<void> trackExceptionWithNameAndMessage(
      String exceptionName, String exceptionMessage) {
    return _channel.invokeMethod('trackExceptionWithNameAndMessage',
        <dynamic, dynamic>{"name": exceptionName, "message": exceptionMessage});
  }

  //This feature is iOS specific
  static Future<void> trackError(
      Map<String, String> userInfo, String domain, int code) async {
    await _channel.invokeMethod(
        'trackError', {"userInfo": userInfo, "domain": domain, "code": code});
  }

  //This feature is only for testing purpose. It produce exception which will crash the application on purpose.
  static Future<void> raiseUncaughtException() async {
    _channel.invokeMethod('raiseUncaughtException', []);
  }

  static Future<void> trackAction(ActionEvent actionEvent) async {
    debugPrint(jsonEncode(actionEvent.toJson()), wrapWidth: 1024);
    await _channel
        .invokeMethod('trackAction', [jsonEncode(actionEvent.toJson())]);
  }

  static Future<void> trackUrl(String urlString, String? mediaCode) async {
    if (mediaCode == null) {
      await _channel.invokeMethod('trackUrlWithoutMediaCode', [urlString]);
    } else {
      await _channel.invokeMethod('trackUrl', [urlString, mediaCode]);
    }
  }

  static Future<void> trackMedia(MediaEvent mediaEvent) async {
    //print(jsonEncode(mediaEvent.toJson()), wrapWidth: 1024);
    await _channel
        .invokeMethod('trackMedia', [jsonEncode(mediaEvent.toJson())]);
  }

  static Future<void> trackWebview(double? x, double? y, double? width,
      double? height, String urlString) async {
    //print("trackWebview is pressed");
    if (x != null && y != null && width != null && height != null) {
      await _channel
          .invokeMethod('trackWebview', [x, y, width, height, urlString]);
    } else {
      await _channel.invokeMethod('trackWebview', [urlString]);
    }
  }

//This method is only for iOS
  static Future<void> disposeWebview() async {
    await _channel.invokeMethod('disposeWebview');
  }

  //This method is only for android
  static Future<void> build() async {
    await updateCustomParams();
    await _channel.invokeMethod('build');
  }

  static Future<String> getEverID() async {
    final String everId = await _channel.invokeMethod('getEverId');
    return everId;
  }

  static Future<String> setEverId(String everId) async {
    String result = await _channel.invokeMethod("setEverId", [everId]);
    return result;
  }

  static Future<void> setIdsAndDomain(
      List<String> trackIds, String trackDomain) async {
    await _channel.invokeMethod("setIdsAndDomain",
        <dynamic, dynamic>{'trackIds': trackIds, 'trackDomain': trackDomain});
  }

  static Future<Map<dynamic, dynamic>?> getTrackIdsAndDomain() async {
    var data = await _channel.invokeMapMethod("getIdsAndDomain");
    return data;
  }

  static Future<void> setAnonymousTracking(
      bool anonymousTracking, List<String> params,
      [bool? generateNewEverId = false]) async {
    await _channel.invokeMethod('enableAnonymousTracking', <dynamic, dynamic>{
      'anonymousTracking': anonymousTracking,
      'params': params.isNotEmpty ? params : null,
    });
  }

  static Future<String> sendAndCleanData() async {
    return await _channel.invokeMethod("sendAndCleanData");
  }

  static Future<Map> getCurrentConfig() async {
    final currentConfig = await _channel.invokeMapMethod("getCurrentConfig");
    if (Platform.isAndroid) {
      debugPrint(jsonEncode(currentConfig));
    }
    return Future.value(currentConfig);
  }

// This method is only for Android
  static Future<bool> updateCustomParams() async {
    // !! IMPORTANT !! UPDATE THIS VERSION TO BE THE SAME AS 'version' in pucspec.yaml plugin file
    final flutterPluginVersion = "5.0.2";
    debugPrint("FLUTTER PLUGIN VERSION: $flutterPluginVersion");
    final result = await _channel
        .invokeMethod("updateCustomParams", [flutterPluginVersion]);
    return Future.value(result);
  }

  static Future<String> setUserMatchingEnabled(bool enabled) async {
    final args = <String, bool>{"enabled": enabled};
    final result = await _channel.invokeMethod("setUserMatchingEnabled", args);
    return result;
  }
}
