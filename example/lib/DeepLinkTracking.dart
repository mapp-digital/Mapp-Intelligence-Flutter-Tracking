import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class DeepLinkTracking extends StatelessWidget {
  DeepLinkTracking({Key? key}) : super(key: key);

  TextEditingController _controller =
      TextEditingController(text: "google.g.g.g");

  void testMCParameterTracking() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      final params = Map<String, String>.from({"mc": text});
      PluginMappintelligence.trackPage("DeepLink Tracking", params);
    }
  }

  void testUrl1() {
    final url =
        "https://testurl.com/?wt_mc=email.newsletter.nov2020.thursday&cc45=parameter45";
    PluginMappintelligence.trackUrl(url, null);
    PluginMappintelligence.trackPage("DeepLink Tracking");
    PluginMappintelligence.sendAndCleanData();
  }

  void testUrl2() {
    final url =
        "https://testurl.com/?abc=email.newsletter.nov2020.thursday&wt_cc12=parameter12";
    PluginMappintelligence.trackUrl(url, "abc");
    PluginMappintelligence.trackPage("DeepLink Tracking");
    PluginMappintelligence.sendAndCleanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Parameter value")),
                    Container(
                      width: double.maxFinite,
                      child: ElevatedButton(
                          onPressed: testMCParameterTracking,
                          child: Text("Test MC parameter tracking")),
                    )
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            onPressed: testUrl1, child: Text("URL 1 Test"))),
                    Container(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            onPressed: testUrl2, child: Text("URL 2 Test"))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
