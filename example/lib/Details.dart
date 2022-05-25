import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';

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
        PluginMappintelligence.reset();
        PluginMappintelligence.setLogLevel(LogLevel.info);
        PluginMappintelligence.setBatchSupportEnabledWithSize(false, 150);
        PluginMappintelligence.setRequestInterval(1);
        PluginMappintelligence.setRequestPerQueue(300);
        PluginMappintelligence.setSendAppVersionInEveryRequest(true);
        //PluginMappintelligence.setEverId("111111111");
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
        PluginMappintelligence.setIdsAndDomain(
            ["826582930668809"], "http://vdestellaaccount01.wt-eu02.net");
      },
      child: Text("Set new track IDs and domain during runtime"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
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
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.setAnonymousTracking(true, [], false);
      },
      child: Text("Set anonymous tracking true \n no suppressed parameters"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.setAnonymousTracking(true, ['uc703','uc709'], true);
      },
      child: Text("Set anonymous tracking true \n suppress parameters uc703, uc709']"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        PluginMappintelligence.setAnonymousTracking(false, ['cs801'], true);
      },
      child: Text("Set anonymous tracking false \n generate new everID true"),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
        onPressed: () async {
          PluginMappintelligence.sendAndCleanData();
        },
        child: Text("Send data and clean")));
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
