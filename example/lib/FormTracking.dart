import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class FormTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Form Tracking'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: FormTracking());
  }
}

// ignore: must_be_immutable
class FormTracking extends StatefulWidget {
  @override
  State<FormTracking> createState() => _FormTrackingState();
}

class _FormTrackingState extends State<FormTracking> {
  bool isSwitched = false;
  bool isSwitchedAnonymous = false;
  int selectedValue = 0;
  Map<int, Widget> children = {
    0: Text('Owl'),
    1: Text('Kiwi'),
    2: Text('Rio'),
    3: Text('Telluraves')
  };

  DateTime _chosenDateTime = DateTime(2022, 3, 22);

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
    buttons.add(ListTile(
      title: const Text('Switch:'),
      trailing: CupertinoSwitch(
        activeColor: Theme.of(context).primaryColorDark,
        value: isSwitched,
        onChanged: (bool value) {
          setState(() {
            isSwitched = value;
          });
        },
      ),
      onTap: () {
        setState(() {
          isSwitched = !isSwitched;
        });
      },
    ));

    buttons.add(ElevatedButton(
      onPressed: () async {},
      child: Text('Confirm'),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {},
      child: Text('Cancel'),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () {},
      child: Text('Path Anylisis'),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark),
    ));

    buttons.add(ListTile(
      title: const Text('Anonymous:'),
      trailing: CupertinoSwitch(
        activeColor: Theme.of(context).primaryColorDark,
        value: isSwitchedAnonymous,
        onChanged: (bool value) {
          setState(() {
            isSwitchedAnonymous = value;
          });
        },
      ),
      onTap: () {
        setState(() {
          isSwitchedAnonymous = !isSwitchedAnonymous;
        });
      },
    ));

    buttons.add(CupertinoSegmentedControl(
      children: children,
      onValueChanged: (value) {
        selectedValue = int.parse(value.toString());
        setState(() {});
      },
      selectedColor: Theme.of(context).primaryColorDark,
      unselectedColor: CupertinoColors.systemGrey5,
      borderColor: Theme.of(context).primaryColorDark,
      pressedColor: Theme.of(context).primaryColorDark,
      groupValue: selectedValue,
    ));

    buttons.add(
      Column(
        children: [
          SizedBox(
            height: 250,
            child: CupertinoDatePicker(
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (val) {
                  setState(() {
                    _chosenDateTime = val;
                  });
                }),
          ),

          // Close the modal
          CupertinoButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
