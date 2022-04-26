import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence_example/ActionTracking.dart';
import 'package:plugin_mappintelligence_example/Campaign.dart';
import 'package:plugin_mappintelligence_example/Details.dart';
import 'package:plugin_mappintelligence_example/Ecommerce.dart';
import 'package:plugin_mappintelligence_example/FormTracking.dart';
import 'package:plugin_mappintelligence_example/Media.dart';
import 'package:plugin_mappintelligence_example/PageTracking.dart';
import 'package:plugin_mappintelligence_example/Webview.dart';
import 'package:plugin_mappintelligence_example/WebviewForAndroid.dart';

import 'ExceptionTracking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNative();
  runApp(MyApp());
}

Future _initNative() async {
  await PluginMappintelligence.initialize(
      ["794940687426749"], 'http://tracker-int-01.webtrekk.net');
  await PluginMappintelligence.setLogLevel(LogLevel.all);
  await PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
  await PluginMappintelligence.setRequestInterval(1);
  await PluginMappintelligence.setRequestPerQueue(300);
  await PluginMappintelligence.setEverId("111111111");
  await PluginMappintelligence.setSendAppVersionInEveryRequest(true);
  await PluginMappintelligence.enableCrashTracking(
      ExceptionType.allExceptionTypes);
  await PluginMappintelligence.build();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFF00BAFF),
          primaryColorDark: Color(0xFF0592D7),
          accentColor: Color(0xFF58585A),
          cardColor: Color(0xFF888888)),
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
    "Form"
  ];

  StatelessWidget _determineWidget(int index) {
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
        return FormTrackingScreen();
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
