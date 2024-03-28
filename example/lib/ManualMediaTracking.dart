import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class ManualMediaTracking extends StatefulWidget {
  const ManualMediaTracking({Key? key}) : super(key: key);

  @override
  State<ManualMediaTracking> createState() => _ManualMediaTrackingState();
}

final mediaNameController =
    TextEditingController(text: "Sample test video for flutter");
final positionController = TextEditingController(text: "");
final durationController = TextEditingController(text: "");
var incrementPosition = false;

void trackMedia(BuildContext context, String action) {
  final mediaName = mediaNameController.text;
  final duration = num.tryParse(durationController.text) ?? 0;
  var position = num.tryParse(positionController.text) ?? 0;
  if (mediaName.isEmpty) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("No media name"),
              content:
                  Text("Media name can't be empty. Enter some media name."),
              actions: [
                TextButton(onPressed: () {}, child: Text("OK")),
              ],
            ));
  }

  if (incrementPosition) {
    position += 5;
    positionController.text = position.toString();
  }
  durationController.text = duration.toString();

  final mediaParameters = MediaParameters(mediaNameController.text);
  mediaParameters.action = action;
  mediaParameters.position = position;
  mediaParameters.duration = duration;
  mediaParameters.name = mediaNameController.text;
  final mediaEvent = MediaEvent("Manual Media Tracking", mediaParameters);
  PluginMappintelligence.trackMedia(mediaEvent);
}

class _ManualMediaTrackingState extends State<ManualMediaTracking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manual Media Tracking"),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Media name"),
                  TextField(
                    controller: mediaNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "media name"),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          "Increase position for 5 seconds on each action click")),
                  Switch.adaptive(
                      value: incrementPosition,
                      onChanged: (checked) {
                        setState(() {
                          incrementPosition = checked;
                        });
                      }),
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Row(
                children: [
                  DecimalTextField(
                    label: "Current position",
                    hint: "current position",
                    textController: positionController,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  DecimalTextField(
                    label: "Duration",
                    hint: "duration",
                    textController: durationController,
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "init");
                  },
                  child: Text("Init")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "play");
                  },
                  child: Text("Play")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "pause");
                  },
                  child: Text("Pause")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "stop");
                  },
                  child: Text("Stop")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "pos");
                  },
                  child: Text("Position")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "seek");
                  },
                  child: Text("Seek")),
              ElevatedButton(
                  onPressed: () {
                    trackMedia(context, "eof");
                  },
                  child: Text("Eof")),
            ],
          ),
        ),
      ]),
    );
  }
}

class DecimalTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? textController;
  final bool signed;
  final bool decimal;
  const DecimalTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.textController = null,
    this.signed = true,
    this.decimal = true,
  }) : super(key: key);

  String getText() {
    return textController?.text ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextField(
            controller: textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hint,
            ),
            keyboardType: TextInputType.numberWithOptions(
                signed: signed, decimal: decimal),
          )
        ],
      ),
    );
  }
}
