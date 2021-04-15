import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'object_tracking_classes.dart';

class PluginMappintelligence {
  static const MethodChannel _channel =
      const MethodChannel('plugin_mappintelligence');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> initialize(
      List<int> trackIds, String trackDomain) async {
    final String? version = await _channel.invokeMethod('initialize',
        <dynamic, dynamic>{'trackIds': trackIds, 'trackDomain': trackDomain});
    return 'successfull $version';
  }

  static Future<String?> setLogLevel(LogLevel logLevel) async {
    final String? version =
        await _channel.invokeMethod('setLogLevel', [logLevel.index + 1]);
    return '$version';
  }

  static Future<String?> setBatchSupportEnabled(bool isEnabled) async {
    final String? version =
        await _channel.invokeMethod('setBatchSupportEnabled', [isEnabled]);
    return 'successfull $version';
  }

  static Future<String?> setBatchSupportSize(int size) async {
    final String? version =
        await _channel.invokeMethod('setBatchSupportSize', [size]);
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

  static Future<void> optIn() async {
    await _channel.invokeMethod('OptIn');
  }

  static Future<void> optOutAndSendCurrentData(bool value) async {
    await _channel.invokeMethod('optOutAndSendCurrentData', [value]);
  }

  static Future<void> reset() async {
    await _channel.invokeMethod('reset');
  }

  static Future<void> enableAnonymousTracking(bool status) async {
    await _channel.invokeMethod('enableAnonymousTracking', [status]);
  }

  static Future<void> enableAnonymousTrackingWithParameters(
      List<String> suppressedParameters) async {
    await _channel.invokeMethod(
        'enableAnonymousTrackingWithParameters', [suppressedParameters]);
  }

  static Future<bool> isAnonymousTrackingEnabled() async {
    return _channel
        .invokeMethod<bool>('isAnonymousTrackingEnabled')
        .then<bool>((bool? value) => value ?? false);
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
      debugPrint(jsonEncode(pageViewEvent.toJson()), wrapWidth: 1024);
      await _channel.invokeMethod(
          'trackPageWithCustomData', [jsonEncode(pageViewEvent.toJson())]);
    }
  }

  static Future<void> trackAction(ActionEvent actionEvent) async {
    debugPrint(jsonEncode(actionEvent.toJson()), wrapWidth: 1024);
    await _channel
        .invokeMethod('trackAction', [jsonEncode(actionEvent.toJson())]);
  }

  static Future<void> trackUrl(String urlString, String? mediaCode) async {
    if (mediaCode == null) {
      await _channel.invokeMethod('trackUrlWitouthMediaCode', [urlString]);
    } else {
      await _channel.invokeMethod('trackUrl', [urlString, mediaCode]);
    }
  }

  static Future<void> trackMedia(MediaEvent mediaEvent) async {
    debugPrint(jsonEncode(mediaEvent.toJson()), wrapWidth: 1024);
    await _channel
        .invokeMethod('trackMedia', [jsonEncode(mediaEvent.toJson())]);
  }

  static Future<void> trackWebview(double? x, double? y, double? width,
      double? height, String urlString) async {
    debugPrint("trackWebview is pressed");
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
}
