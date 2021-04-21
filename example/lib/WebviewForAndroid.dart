import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewForAndroid extends StatelessWidget {
  void initState() {
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    //PluginMappintelligence.trackWebview();TODO try to mapp it here
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return Scaffold(
      appBar: AppBar(
        title: Text('WebviewForAndroid'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebView(
          initialUrl: 'http://demoshop.webtrekk.com/web2app/index.html',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async {
//            NOT WORKING HERE:
//             await webViewController.evaluateJavascript(injectScript);
          }),
    );
  }
}
