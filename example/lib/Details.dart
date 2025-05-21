import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'NativeBridge.dart';

// ignore: must_be_immutable
class DetailsView extends StatelessWidget {
  int index;

  DetailsView(this.index);

  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        await PluginMappintelligence.optOutAndSendCurrentData(true);
      },
      child: Text('Opt out'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.optIn();
      },
      child: Text('Opt in'),
    ));

    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.initialize(
            ["794940687426749"], 'http://tracker-int-01.webtrekk.net');
        PluginMappintelligence.setLogLevel(LogLevel.all);
        PluginMappintelligence.setBatchSupportEnabledWithSize(true, 150);
        PluginMappintelligence.setRequestInterval(1);
        PluginMappintelligence.setRequestPerQueue(300);
        PluginMappintelligence.build();
      },
      child: Text('Test setup'),
    ));

    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.reset();
        PluginMappintelligence.setLogLevel(LogLevel.info);
        PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
        PluginMappintelligence.setRequestInterval(1);
        PluginMappintelligence.setRequestPerQueue(300);
        PluginMappintelligence.setSendAppVersionInEveryRequest(true);
        //PluginMappintelligence.setEverId("111111111");
      },
      child: Text("Reset"),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.setEverId("123456789");
      },
      child: Text("Set Ever ID"),
    ));

    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.getEverID().then((String value) => {
              showAlertDialog(
                  context, "Current EverId: ${value.isEmpty ? "null" : value}")
            });
      },
      child: Text('Get Ever ID'),
    ));

    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.setIdsAndDomain(
            ["826582930668809"], "http://vdestellaaccount01.wt-eu02.net");
      },
      child: Text("Set new track IDs and domain during runtime"),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        await NativeBridge.askPhotoPermission();
        //await PluginMappintelligence.optOutAndSendCurrentData(true);
      },
      child: Text('Show Gallery Permission'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        Map<dynamic, dynamic>? data =
            await PluginMappintelligence.getTrackIdsAndDomain();
        if (data != null) {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text("Track Ids & Track Domain"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data["trackIds"].toString()),
                      Text(data["trackDomain"])
                    ],
                  ),
                );
              });
        }
      },
      child: Text("Get trackId and trackDomain"),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.setAnonymousTracking(true, [], false);
      },
      child: Text("Set anonymous tracking true \n no suppressed parameters"),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.setAnonymousTracking(
            true, ['uc703', 'uc709'], true);
      },
      child: Text(
          "Set anonymous tracking true \n suppress parameters uc703, uc709"),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        await PluginMappintelligence.setAnonymousTracking(
            false, ['cs801'], true);
      },
      child: Text("Set anonymous tracking false \n generate new everID true"),
    ));
    buttons.add(ElevatedButton(
        onPressed: () async {
          PluginMappintelligence.sendAndCleanData();
        },
        child: Text("Send data and clean")));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.getCurrentConfig();
      },
      child: Text("Print current config"),
    ));
    buttons.add(ElevatedButton(
        onPressed: () {
          PluginMappintelligence.setUserMatchingEnabled(false);
        },
        child: Text("Disable user matching")));
    buttons.add(ElevatedButton(
        onPressed: () {
          PluginMappintelligence.setUserMatchingEnabled(true);
        },
        child: Text("Enable user matching")));
    buttons.add(ElevatedButton(
        onPressed: () async {
          final result = await PluginMappintelligence.setTemporarySessionId(
              "user-1234-xyz");
          showAlertDialog(context, "Result: $result");
        },
        child: Text("Set temporary session ID")));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuration',
        ),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }

  showAlertDialog(BuildContext context, String title) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // show the dialog
}
