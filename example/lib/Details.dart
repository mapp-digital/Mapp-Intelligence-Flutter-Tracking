import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

// ignore: must_be_immutable
class DetailsView extends StatelessWidget {
  int index;
  DetailsView(this.index);
  final TestSwitch isSwitched = new TestSwitch();

  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        await PluginMappintelligence.optOutAndSendCurrentData(true);
      },
      child: Text('Opt out'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        await PluginMappintelligence.optIn();
      },
      child: Text('Opt in'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        await PluginMappintelligence.reset();
      },
      child: Text('Reset'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(Row(
      children: [Text('Anonymus tracking'), isSwitched],
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

class _TestSwitchState extends State<TestSwitch> {
  bool text = false;

  void change(bool swit) {
    setState(() {
      this.text = swit;
      if (swit) {
        // statement(s) will execute if the Boolean expression is true.
        PluginMappintelligence.enableAnonymousTrackingWithParameters(["uc706"]);
      } else {
        // statement(s) will execute if the Boolean expression is false.
        PluginMappintelligence.enableAnonymousTracking(false);
      }
    });
  }

  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.data == null) {
          print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        print(projectSnap);
        text = projectSnap.data as bool;
        return Switch(
            value: text,
            onChanged: (value) {
              change(value);
              print(value);
            });
      },
      future: PluginMappintelligence.isAnonymousTrackingEnabled(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: projectWidget(),
    );
  }
}

class TestSwitch extends StatefulWidget {
  final _TestSwitchState state = new _TestSwitchState();

  void update(bool swit) {
    state.change(swit);
  }

  @override
  _TestSwitchState createState() => state;
}
