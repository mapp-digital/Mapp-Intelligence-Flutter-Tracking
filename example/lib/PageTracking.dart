import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';

class PageTracking extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        String className = this.runtimeType.toString();
        PluginMappintelligence.trackPage(className);
      },
      child: Text('Track Page'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var pageParameters = {'Usrname': 'tom', 'Password': 'pass@123'};
        PluginMappintelligence.trackCustomPage("customName", pageParameters);
      },
      child: Text('Track Custom Page'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var pageProperties = MIPageParameters();
        pageProperties.searchTerm = "searchTerm";
        pageProperties.categories = {1: 'tom', 2: 'pass@123'};
        pageProperties.params = {11: 'tom', 22: 'pass@123'};
        var pageViewEvent = MIPageViewEvent("testNameFlutter");
        pageViewEvent.pageParameters = pageProperties;
        PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
      },
      child: Text('Track Page with custom data'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
