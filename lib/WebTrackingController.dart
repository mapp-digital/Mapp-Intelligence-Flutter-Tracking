import 'dart:convert';
import 'dart:io';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTrackingController {
  final WebViewController controller;
  final void Function(String data)? onMessage;
  final void Function()? onLoad;
  final NavigationDelegate? navigationDelegate;

  WebTrackingController({
    required this.controller,
    this.onMessage,
    this.onLoad,
    this.navigationDelegate,
  }) {
    _setupChannels();
  }

  // Injected scripts
  static const String _runOnce = """
    var meta = document.createElement('meta');
    meta.setAttribute('name', 'viewport');
    meta.setAttribute('content', 'width=device-width, height=device-height, initial-scale=0.85, maximum-scale=1.0, user-scalable=no');
    document.getElementsByTagName('head')[0].appendChild(meta);
  """;

  Future<void> handleLoad() async {
    try {
      final everId = await PluginMappintelligence.getEverID();
      final injectEverIdScript =
          "window.webtrekkApplicationEverId = '$everId'; true;";
      await controller.runJavaScript(_runOnce + injectEverIdScript);
      onLoad?.call();
    } catch (error, stack) {
      print('Error: $error');
      PluginMappintelligence.trackExceptionWithNameAndMessage(error.runtimeType.toString(), stack.toString());
    }
  }

  void _setupChannels() {
    if (Platform.isIOS) {
      PluginMappintelligence.trackWebviewConfiguration();
    }

    controller.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: navigationDelegate?.onNavigationRequest,
      onPageStarted: navigationDelegate?.onPageStarted,
      onProgress: navigationDelegate?.onProgress,
      onWebResourceError: navigationDelegate?.onWebResourceError,
      onPageFinished: (String url) {
        print('Page finished loading: $url');
        handleLoad().then((_) => navigationDelegate?.onPageFinished?.call(url));
      },
    ));

    controller.addJavaScriptChannel(
      'ReactNativeWebView',
      onMessageReceived: (message) {
        try {
          final data = jsonDecode(message.message);
          final method = data['method'];
          final name = data['name'];
          final params = data['params'];
          print('Method: $method, Name: $name, Params: $params');

          if (method == null || name == null) return;

          if (method == 'trackCustomPage') {
            PluginMappintelligence.trackWebPage(name, params);
          } else if (method == 'trackCustomEvent') {
            PluginMappintelligence.trackWebEvent(name, params);
          }
        } catch (e) {
          print('Error parsing message from WebView: $e');
        }

        onMessage?.call(message.message);
      },
    );
  }
}
