import 'dart:async';

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

  static Future<String?> setLogLevel(int logLevel) async {
    final String? version =
        await _channel.invokeMethod('setLogLevel', [logLevel]);
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

  static Future<void> trackPage(String currentWidgetName) async {
    await _channel.invokeMethod('trackPage', [currentWidgetName]);
  }

  static Future<void> trackCustomPage(
      String customName, Map<String, String> trackingParameters) async {
    await _channel
        .invokeMethod('trackCustomPage', [customName, trackingParameters]);
  }

  static Future<void> trackPageWithCustomData(
      MIPageViewEvent pageViewEvent) async {
    var pageProperties = pageViewEvent.pageParameters;
    var searchTerm = pageProperties.searchTerm;
    var categories = pageProperties.categories;
    var params = pageProperties.params;
    await _channel.invokeMethod(
        'trackPageWithCustomData', [searchTerm, categories, params]);
  }
}
