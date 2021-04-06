import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class Campaign extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        var campaignProperties =
            MICampaignParameters("email.newsletter.nov2020.thursday");
        campaignProperties.mediaCode = "abc";
        campaignProperties.oncePerSession = true;
        campaignProperties.action = MICampaignAction.view;
        campaignProperties.customParameters = {12: "camParam1"};

        var event = MIPageViewEvent("TestCampaign");
        event.campaignParameters = campaignProperties;
        PluginMappintelligence.trackPageWithCustomData(event);
      },
      child: Text('Test Campaign'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var urlString =
            "https://testurl.com/?wt_mc=email.newsletter.nov2020.thursday&wt_cc45=parameter45";
        PluginMappintelligence.trackUrl(urlString, null);
      },
      child: Text('Test Link1'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var urlString =
            "https://testurl.com/?wt_mc=email.newsletter.nov2020.thursday&wt_cc45=parameter45";
        PluginMappintelligence.trackUrl(urlString, "abc");
      },
      child: Text('Test Link2'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
