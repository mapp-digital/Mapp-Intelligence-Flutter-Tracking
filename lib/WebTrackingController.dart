import 'dart:convert';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTrackingController {
  final WebViewController controller;
  final void Function(String data)? onMessage;
  final void Function()? onLoad;

  WebTrackingController({
    required this.controller,
    this.onMessage,
    this.onLoad,
  }) {
    _setupChannels();
  }

  // Injected scripts
  final String _runOnce = """
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
    } catch (error, stack) {
      print('Error: $error');
      PluginMappintelligence.trackExceptionWithNameAndMessage(error.runtimeType.toString(), stack.toString());
    }

    if (onLoad != null) onLoad!();
  }

  void _setupChannels() {
    controller.setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
      print('Page finished loading: $url');
      handleLoad();
    }));
    
    controller.addJavaScriptChannel(
      'ReactNativeWebView',
      onMessageReceived: (message) {
        try {
          final data = jsonDecode(message.message);
          final method = data['method'];
          final name = data['name'];
          final params = data['params'];
          print('Method: $method, Name: $name, Params: $params');

          if (method == 'trackCustomPage') {
            PluginMappintelligence.trackWebPage(name,  params);
          } else if (method == 'trackCustomEvent') {
            PluginMappintelligence.trackWebEvent(name,params);
          }
        } catch (e) {
          print('Error parsing message from WebView: $e');
        }

        if (onMessage != null) onMessage!(message.message);
      },
    );
  }
}
