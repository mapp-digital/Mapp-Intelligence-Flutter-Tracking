import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence_example/DeutcheBank.dart';
import 'ActionTracking.dart';
import 'Campaign.dart';
import 'Details.dart';
import 'Ecommerce.dart';
import 'Media.dart';
import 'PageTracking.dart';
import 'Webview.dart';
import 'WebviewForAndroid.dart';

import 'ExceptionTracking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PluginMappintelligence.initialize(
      ["165126124990956"], 'https://mit.db.com');
  PluginMappintelligence.setLogLevel(LogLevel.all);
  PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
  PluginMappintelligence.setRequestInterval(1);
  PluginMappintelligence.setAnonymousTracking(true, [""], true);
  PluginMappintelligence.build();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFF00BAFF),
          primaryColorDark: Color(0xFF0592D7),
          cardColor: Color(0xFF888888),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF58585A))),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  final List<String> _screens = const [
    "Configuration",
    "Page Tracking",
    "Action",
    "Campaign",
    "Ecommerce",
    "Webview",
    "WebviewForAndroid",
    "Media",
    "Exception",
    "Deutche Bank"
  ];

  Widget _determineWidget(int index) {
    switch (index) {
      case 0:
        return DetailsView(index);
      case 1:
        return PageTracking();
      case 2:
        return ActionTracking();
      case 3:
        return Campaign();
      case 4:
        return Ecommerce();
      case 5:
        return WebviewApp();
      case 6:
        return WebviewForAndroid();
      case 7:
        return Media();
      case 8:
        return ExceptionTracking();
      case 9:
        return DeutcheBank();
      default:
        return DetailsView(index);
    }
  }

  ListView _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: _screens.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(
              _screens[index],
              style: TextStyle(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _determineWidget(index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Mapp Intelligence Demo'),
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          body: _buildListView(context)),
    );
  }
}
