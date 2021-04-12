import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class WebviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WebView'),
          backgroundColor: Theme.of(context).primaryColor,
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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    PluginMappintelligence.disposeWebview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  @override
  void didChangeDependencies() {
    if (!isInitialized) {
      PluginMappintelligence.trackWebview(
          0.0,
          Scaffold.of(context).appBarMaxHeight ??
              MediaQuery.of(context).padding.top + kToolbarHeight,
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight ??
                  MediaQuery.of(context).padding.top + kToolbarHeight),
          'http://demoshop.webtrekk.com/web2app/index.html');
      isInitialized = true;
    }
    super.didChangeDependencies();
  }
}
