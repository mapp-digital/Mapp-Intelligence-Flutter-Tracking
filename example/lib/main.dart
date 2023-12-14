import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/tracking/mapp_analytics_observer.dart';
import 'package:plugin_mappintelligence/tracking/tracking_events.dart';
import 'package:plugin_mappintelligence_example/DeepLinkTracking.dart';
import 'package:plugin_mappintelligence_example/FormTracking.dart';
import 'package:plugin_mappintelligence_example/ProductStatuses.dart';

import 'ActionTracking.dart';
import 'Campaign.dart';
import 'Details.dart';
import 'Ecommerce.dart';
import 'ExceptionTracking.dart';
import 'Media.dart';
import 'PageTracking.dart';
import 'PageViewEvent.dart';
import 'Webview.dart';
import 'WebviewForAndroid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PluginMappintelligence.initialize(
      ["794940687426749"], 'http://tracker-int-01.webtrekk.net');

  await PluginMappintelligence.setLogLevel(LogLevel.all);
  await PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
  await PluginMappintelligence.setRequestInterval(1);
  await PluginMappintelligence.setEverId("0987654321");
  await PluginMappintelligence.setAnonymousTracking(false, [""]);
  await PluginMappintelligence.setUserMatchingEnabled(true);
  await PluginMappintelligence.enableCrashTracking(
      ExceptionType.allExceptionTypes);
  await PluginMappintelligence.setTemporarySessionId("user-xyz-1234");
  await PluginMappintelligence.build();

  // Initialize Mapp SDK plugin; It is required for user matching;
  //MappSdk.engage("183408d0cd3632.83592719", "", SERVER.L3, "206974", "5963");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("RUN MATERIAL APP");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFF00BAFF),
          primaryColorDark: Color(0xFF0592D7),
          cardColor: Color(0xFF888888),
          appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF00BAFF),
              titleTextStyle: TextStyle(color: Colors.white)),
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
    "URL Tracking",
    "Action",
    "Campaign",
    "Ecommerce",
    "Webview",
    "WebviewForAndroid",
    "Media",
    "Exception",
    "Page View Event",
    "FormTracking",
    "Product Statuses"
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        MappAnalyticsObserver([TrackingEvents.PUSH])
      ],
      theme: ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF00BAFF),
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Mapp Intelligence Demo'),
          ),
          body: _buildListView(context)),
    );
  }

  Widget _determineWidget(int index) {
    switch (index) {
      case 1:
        return PageTracking();
      case 2:
        return DeepLinkTracking();
      case 3:
        return ActionTracking();
      case 4:
        return Campaign();
      case 5:
        return Ecommerce();
      case 6:
        return WebviewApp();
      case 7:
        return WebviewForAndroid();
      case 8:
        return Media();
      case 9:
        return ExceptionTracking();
      case 10:
        return PageViewEventScreen();
      case 11:
        return FormTrackingScreen();
      case 12:
        return ProductStatuses();
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
              final widget = _determineWidget(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: widget.toString()),
                  builder: (context) => widget,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
