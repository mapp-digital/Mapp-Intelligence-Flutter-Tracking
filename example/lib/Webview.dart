import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/WebTrackingController.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
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
  //VideoPlayerScreen({Key key}) : super(key: key);

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
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    // PluginMappintelligence.disposeWebview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // if (isInitialized) {
    //   //find wkwebview for iOS
    //   PluginMappintelligence.trackWebviewConfiguration(_controller);
    // }
    super.didChangeDependencies();
  }
}
