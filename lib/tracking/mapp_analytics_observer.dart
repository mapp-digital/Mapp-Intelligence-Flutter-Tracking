import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/tracking/tracking_events.dart';

class MappAnalyticsObserver extends RouteObserver<PageRoute<dynamic>> {
  final List<TrackingEvents> trackingEvents;

  MappAnalyticsObserver(
      [this.trackingEvents = const <TrackingEvents>[
        TrackingEvents.PUSH,
        TrackingEvents.POP,
        TrackingEvents.REPLACE
      ]]);

  void _sendScreenView(String actionName, Route<dynamic> route) {
    var screenName = route.settings.name;
    debugPrint('PAGE TRACKING >> $actionName - screen: $screenName');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute && trackingEvents.contains(TrackingEvents.PUSH)) {
      _sendScreenView("push", route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute);
    if (newRoute is PageRoute &&
        trackingEvents.contains(TrackingEvents.REPLACE)) {
      _sendScreenView("replace", newRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute &&
        route is PageRoute &&
        trackingEvents.contains(TrackingEvents.POP)) {
      _sendScreenView("pop", previousRoute);
    }
  }
}
