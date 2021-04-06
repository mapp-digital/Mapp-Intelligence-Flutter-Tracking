import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class ActionTracking extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        var eventParameters = EventParameters();
        eventParameters.parameters = {20: "ck20Param1"};

        var event = ActionEvent("TestAction");
        event.eventParameters = eventParameters;

        PluginMappintelligence.trackAction(event);
      },
      child: Text('Track Action'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var eventParameters = EventParameters();
        eventParameters.parameters = {20: "ck20Param1"};

        var sessionPropertis = MISessionParameters();
        sessionPropertis.parameters = {10: 'sessionParameter1'};

        var userCategorises = MIUserCategories();
        userCategorises.birthday = MIBirthday(7, 12, 1991);
        userCategorises.city = "Nis";
        userCategorises.country = "Serbia";
        userCategorises.customerId = "99898390";
        userCategorises.emailAddress = "stefan.stevanovic@mapp.com";
        userCategorises.emailReceiverId = "8743798";

        var event = ActionEvent("TestAction");
        event.eventParameters = eventParameters;
        event.sessionParameters = sessionPropertis;
        event.userCategories = userCategorises;

        PluginMappintelligence.trackAction(event);
      },
      child: Text('Track Custom Action'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
