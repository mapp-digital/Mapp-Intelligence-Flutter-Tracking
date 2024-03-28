import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class Campaign extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        var campaignProperties =
            CampaignParameters("email.newsletter.nov2020.thursday");
        campaignProperties.mediaCode = "abc";
        campaignProperties.oncePerSession = true;
        campaignProperties.action = CampaignAction.view;
        campaignProperties.campaignId = "testCampaignID";
        campaignProperties.customParameters = {12: "camParam1"};

        var event = PageViewEvent("TestCampaign");
        event.campaignParameters = campaignProperties;
        PluginMappintelligence.trackPageWithCustomData(event);
      },
      child: Text('Test Campaign'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var urlString =
            "https://testurl.com/?wt_mc=email.newsletter.nov2020.thursday&wt_cc45=parameter45";
        PluginMappintelligence.trackUrl(urlString, null);
        String className = this.runtimeType.toString();
        PluginMappintelligence.trackPageWithCustomData(null, className);
      },
      child: Text('Test Link1'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var urlString =
            "https://testurl.com/?abc=email.newsletter.nov2020.thursday&wt_cc12=parameter12";
        PluginMappintelligence.trackUrl(urlString, "abc");
        String className = this.runtimeType.toString();
        PluginMappintelligence.trackPageWithCustomData(null, className);
      },
      child: Text('Test Link2'),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign'),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
