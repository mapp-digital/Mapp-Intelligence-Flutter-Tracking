import 'package:flutter/material.dart';
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
    _controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse('https://demoshop.webtrekk.com/media/web2app/index.html'));
  isInitialized = true;
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    //PluginMappintelligence.disposeWebview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: WebViewWidget(controller: _controller),
  );
  }

  @override
  void didChangeDependencies() {
    if (isInitialized) {
      
        //find wkwebview for iOS 
        PluginMappintelligence.trackWebviewConfiguration();
    }
    super.didChangeDependencies();
  }
}
