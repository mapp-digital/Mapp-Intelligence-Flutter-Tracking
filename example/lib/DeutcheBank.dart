import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class DeutcheBank extends StatelessWidget {
  SessionParameters sessionParameters() {
    String environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: "Dev",
    );

    var sessionParameters = SessionParameters();
    sessionParameters.parameters = {7: environment};
    print(environment);

    return sessionParameters;
  }

  void magazineStoryViewed(magazineStory) async {
    var pageProperties = PageParameters();
    pageProperties.params = {3: 'Viewed: $magazineStory'};

    var pageViewEvent = PageViewEvent("Flowapp: Magazine Story viewed");
    pageViewEvent.pageParameters = pageProperties;
    pageViewEvent.sessionParameters = sessionParameters();

    PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
  }

  void userOpenedPushNotification(title) {
    var pageProperties = PageParameters();
    pageProperties.params = {3: 'Viewed: $title'};

    var pageViewEvent = PageViewEvent("Flowapp: Push Notification opened");
    pageViewEvent.pageParameters = pageProperties;
    pageViewEvent.sessionParameters = sessionParameters();

    PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
  }

  void newsCategoryLandingViewed(categoryTitle) {
    var pageProperties = PageParameters();
    pageProperties.params = {4: 'Category: $categoryTitle'};

    var pageViewEvent = PageViewEvent("Flowapp: Category Landing page viewed");
    pageViewEvent.pageParameters = pageProperties;
    pageViewEvent.sessionParameters = sessionParameters();

    PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
  }

  void newsArticleViewed(articleTitle) async {
    var pageProperties = PageParameters();
    pageProperties.params = {3: 'Viewed: $articleTitle'};

    var pageViewEvent = PageViewEvent("Flowapp: News article detail view");
    pageViewEvent.pageParameters = pageProperties;
    pageViewEvent.sessionParameters = sessionParameters();

    PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
  }

  final List<Widget> buttons = [];
  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) {
      buttons.add(
        ElevatedButton(
          onPressed: (() => magazineStoryViewed("Some story")),
          child: Text("Magazin Story viewed"),
        ),
      );
      buttons.add(ElevatedButton(
          onPressed: (() => userOpenedPushNotification("World cup")),
          child: Text("User opened push notification")));
      buttons.add(ElevatedButton(
          onPressed: (() => newsCategoryLandingViewed("Mapp Intelligence")),
          child: Text("News category landing viewed")));
      buttons.add(ElevatedButton(
          onPressed: (() => newsArticleViewed(
              "How to integrate Mapp Intelligence for flutter")),
          child: Text("News article viewed")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Deutche Bank'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: ListView(children: buttons));
  }
}
