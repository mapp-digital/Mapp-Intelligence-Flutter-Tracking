import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence_example/VideoPlayer.dart';

class Media extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerApp(),
          ),
        );
      },
      child: Text('Test Media1'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {},
      child: Text('Player Example'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {},
      child: Text('Player Example2'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
