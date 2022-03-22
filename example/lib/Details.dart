import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'dart:io' show Platform;

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
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.optIn();
      },
      child: Text('Opt in'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.getEverID()
            .then((String value) => {showAlertDialog(context, value)});
      },
      child: Text('Get Ever ID'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
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
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));

    buttons.add(ElevatedButton(
      onPressed: () {
        var map = Map<String, dynamic>();
        if (Platform.isAndroid) {
          map.putIfAbsent("trackIds", () => ["794940687426749"]); // required
          map.putIfAbsent(
              "domain", () => "http://tracker-int-01.webtrekk.net"); // required
          map.putIfAbsent("batchSupportEnabled", () => true);
          map.putIfAbsent("batchSupportSize", () => 150);
          map.putIfAbsent("requestInterval", () => 15);
          map.putIfAbsent("requestPerQueue", () => 300);
          map.putIfAbsent("everId", () => "1111111111");
          PluginMappintelligence.reset(map);
        } else if (Platform.isIOS) {
          PluginMappintelligence.reset(map);
          PluginMappintelligence.setLogLevel(LogLevel.info);
          PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
          PluginMappintelligence.setRequestInterval(1);
          PluginMappintelligence.setRequestPerQueue(300);
          PluginMappintelligence.setEverId("111111111");
        }
      },
      child: Text("Reset"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.setEverId("123456789");
      },
      child: Text("Set Ever ID"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
        backgroundColor: Theme.of(context).primaryColor,
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
