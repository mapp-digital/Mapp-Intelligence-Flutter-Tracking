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
      onPressed: ()  {
         PluginMappintelligence.optIn();
      },
      child: Text('Opt in'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: ()  {
        PluginMappintelligence.getEverID().then((String value) => {
          showAlertDialog(context,value)
        });

      },
      child: Text('Get Ever ID'),
      style:
      ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));

    buttons.add(ElevatedButton(
      onPressed: ()  {
        PluginMappintelligence.getUserAgent().then((String value) => {
          showAlertDialog(context,value)
        });
      },
      child: Text('Get User Agent'),
      style:
      ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.initialize(
            [794940687426749], 'http://tracker-int-01.webtrekk.net');
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

  showAlertDialog(BuildContext context,String title) {

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
