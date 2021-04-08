import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webview extends StatelessWidget {
  void initState() {
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    PluginMappintelligence.trackWebview();
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return Scaffold(
      appBar: AppBar(
        title: Text('Webview'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebView(
        initialUrl: 'https://flutter.dev',
      ),
    );
  }
}
