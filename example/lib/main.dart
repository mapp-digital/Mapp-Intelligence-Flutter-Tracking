import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'ActionTracking.dart';
import 'Campaign.dart';
import 'Details.dart';
import 'Ecommerce.dart';
import 'FormTracking.dart';
import 'Media.dart';
import 'PageTracking.dart';
import 'Webview.dart';
import 'WebviewForAndroid.dart';

import 'ExceptionTracking.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initNative();
    runApp(MyApp());
  }, (Object error, StackTrace stack) {
    if (error is PlatformException) {
      PluginMappintelligence.trackExceptionWithNameAndMessage(
          "PLATFORM EXCEPTION", error.message ?? "Unknown exception details");
      print("PLATFORM EXCEPTION: " + error.message!);
    } else if(error is MissingPluginException) {
      print("PLUGIN EXCEPTION: " + error.message!);
    }
  });
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
  PluginMappintelligence.build();
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
    "Exception"
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
