import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class ExceptionTracking extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () {
        PluginMappintelligence.trackExceptionWithNameAndMessage(
            "exceptionName", "exceptionMessage");
      },
      child: Text('Track Exception With Name And Message'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        throw Exception('BarException');
        //PluginMappintelligence.raiseUncaughtException();
      },
      child: Text('Track Uncaught exception'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var userInfo = Map<String, String>();
        userInfo.putIfAbsent(
            ErrorUserInfo.description, () => "this will be error description!");
        userInfo.putIfAbsent(
            ErrorUserInfo.failureReason, () => "this will be failure reason!");
        PluginMappintelligence.trackError(
            userInfo, "www.mapp.test.intelligence.com", 200);
      },
      child: Text('Track Error'),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exception Tracking'),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
