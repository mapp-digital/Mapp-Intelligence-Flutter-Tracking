import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence_example/ManualMediaTracking.dart';
import 'package:plugin_mappintelligence_example/VideoPlayer.dart';

class Media extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () {
        var mediaProperties = MediaParameters("TestVideo");
        mediaProperties.action = "view";
        mediaProperties.position = 12;
        mediaProperties.duration = 120;
        mediaProperties.customCategories = {20: "mediaCat"};

        var mediaEvent = MediaEvent("Test", mediaProperties);
        PluginMappintelligence.trackMedia(mediaEvent);
      },
      child: Text('Test Media1'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {},
      child: Text('Player Example'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerApp(),
          ),
        );
      },
      child: Text('Player Example2'),
    ));
    buttons.add(ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManualMediaTracking()),
          );
        },
        child: Text('Manual Media Tracking')));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media'),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
