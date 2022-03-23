import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';

// ignore: must_be_immutable
class FormTracking extends StatelessWidget {
  bool isSwitched = false;

  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(
      TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    );
    buttons.add(
      TextFormField(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Enter your username',
        ),
      ),
    );
    buttons.add(Switch(
      value: isSwitched,
      onChanged: (value) {
        // ignore: unnecessary_statements
        () {
          isSwitched = value;
          print(isSwitched);
        };
      },
      activeTrackColor: Theme.of(context).primaryColorDark,
      activeColor: Theme.of(context).primaryColorLight,
    ));

    buttons.add(ElevatedButton(
      onPressed: () async {},
      child: Text('Confirm'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {},
      child: Text('Cancel'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {},
      child: Text('Path Anylisis'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));

    buttons.add(Switch(
      value: isSwitched,
      onChanged: (value) {
        // ignore: unnecessary_statements
        () {
          isSwitched = value;
          print(isSwitched);
        };
      },
      activeTrackColor: Theme.of(context).primaryColorDark,
      activeColor: Theme.of(context).primaryColorLight,
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
}
