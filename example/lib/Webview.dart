import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/WebTrackingController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WebView'),
        ),
        body: WebviewScreen());
  }
}

class WebviewScreen extends StatefulWidget {
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  bool isInitialized = false;
  late final WebViewController _controller;

  @override
  void initState() {
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    WebTrackingController(controller: _controller);

    _controller.loadRequest(
        Uri.parse('https://demoshop.webtrekk.com/media/web2app/index.html'));

    isInitialized = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
