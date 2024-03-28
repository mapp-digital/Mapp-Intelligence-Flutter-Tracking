import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class ActionTracking extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        var eventParameters = EventParameters();
        eventParameters.parameters = {20: "ck20Param1", 21: "ck21Param1"};

        var event = ActionEvent("TestAction");
        event.eventParameters = eventParameters;

        PluginMappintelligence.trackAction(event);
      },
      child: Text('Track Action'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var eventParameters = EventParameters();
        eventParameters.parameters = {20: "ck20Param1"};

        var sessionPropertis = SessionParameters();
        sessionPropertis.parameters = {10: 'sessionParameter1'};

        var userCategorises = UserCategories();
        userCategorises.birthday = Birthday(7, 12, 1991);
        userCategorises.city = "Nis";
        userCategorises.country = "Serbia";
        userCategorises.customerId = "99898390";
        userCategorises.emailAddress = "stefan.stevanovic@mapp.com";

        var event = ActionEvent("TestAction");
        event.eventParameters = eventParameters;
        event.sessionParameters = sessionPropertis;
        event.userCategories = userCategorises;

        PluginMappintelligence.trackAction(event);
      },
      child: Text('Track Custom Action'),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action Tracking'),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
