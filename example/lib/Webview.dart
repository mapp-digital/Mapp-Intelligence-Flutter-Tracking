import 'package:flutter/material.dart';

class Webview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webview'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(children: []),
    );
  }
}
