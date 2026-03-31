import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugin_mappintelligence');

  // Captures every method call made through the channel.
  final List<MethodCall> log = [];

  // Default handler — returns sensible values so methods don't throw.
  Future<Object?> defaultHandler(MethodCall call) async {
    log.add(call);
    switch (call.method) {
      case 'getEverId':
        return 'ever-id-123';
      case 'setEverId':
        return 'ok';
      case 'getIdsAndDomain':
        return {'trackIds': ['123'], 'trackDomain': 'example.com'};
      case 'getCurrentConfig':
        return {'key': 'value'};
      case 'resetConfig':
        return 'reset';
      case 'sendAndCleanData':
        return 'sent';
      case 'setTemporarySessionId':
        return 'ok';
      case 'setUserMatchingEnabled':
        return 'ok';
      case 'setEnableBackgroundSendout':
        return 'ok';
      case 'updateCustomParams':
        return 'ok';
      case 'disableAutoTracking':
      case 'disableActivityTracking':
      case 'disableFragmentTracking':
        return 'ok';
      default:
        return null;
    }
  }

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, defaultHandler);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  MethodCall lastCall() => log.last;

  MethodCall callWithMethod(String method) =>
      log.firstWhere((c) => c.method == method);

  // ---------------------------------------------------------------------------
  // platformVersion
  // ---------------------------------------------------------------------------

  group('platformVersion', () {
    test('invokes getPlatformVersion and returns result', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return '1.0.0';
      });
      final version = await PluginMappintelligence.platformVersion;
      expect(version, '1.0.0');
      expect(lastCall().method, 'getPlatformVersion');
    });
  });

  // ---------------------------------------------------------------------------
  // initialize
  // ---------------------------------------------------------------------------

  group('initialize', () {
    test('invokes initialize with trackIds and trackDomain', () async {
      await PluginMappintelligence.initialize(['123456789'], 'track.example.com');
      final call = lastCall();
      expect(call.method, 'initialize');
      expect(call.arguments['trackIds'], ['123456789']);
      expect(call.arguments['trackDomain'], 'track.example.com');
    });

    test('returns successfull prefix in result', () async {
      final result = await PluginMappintelligence.initialize(['id'], 'domain');
      expect(result, startsWith('successfull'));
    });
  });

  // ---------------------------------------------------------------------------
  // setLogLevel
  // ---------------------------------------------------------------------------

  group('setLogLevel', () {
    test('sends LogLevel index + 1', () async {
      await PluginMappintelligence.setLogLevel(LogLevel.debug);
      // debug is index 1, so argument should be 2
      expect(lastCall().method, 'setLogLevel');
      expect(lastCall().arguments, [LogLevel.debug.index + 1]);
    });

    test('sends correct index for each log level', () async {
      for (final level in LogLevel.values) {
        log.clear();
        await PluginMappintelligence.setLogLevel(level);
        expect(lastCall().arguments, [level.index + 1]);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // setBatchSupportEnabledWithSize
  // ---------------------------------------------------------------------------

  group('setBatchSupportEnabledWithSize', () {
    test('sends isEnabled and size', () async {
      await PluginMappintelligence.setBatchSupportEnabledWithSize(true, 100);
      expect(lastCall().method, 'setBatchSupportEnabledWithSize');
      expect(lastCall().arguments, [true, 100]);
    });
  });

  // ---------------------------------------------------------------------------
  // setRequestInterval
  // ---------------------------------------------------------------------------

  group('setRequestInterval', () {
    test('sends interval size', () async {
      await PluginMappintelligence.setRequestInterval(30);
      expect(lastCall().method, 'setRequestInterval');
      expect(lastCall().arguments, [30]);
    });
  });

  // ---------------------------------------------------------------------------
  // setRequestPerQueue
  // ---------------------------------------------------------------------------

  group('setRequestPerQueue', () {
    test('sends request number', () async {
      await PluginMappintelligence.setRequestPerQueue(5);
      expect(lastCall().method, 'setRequestPerQueue');
      expect(lastCall().arguments, [5]);
    });
  });

  // ---------------------------------------------------------------------------
  // setSendAppVersionInEveryRequest
  // ---------------------------------------------------------------------------

  group('setSendAppVersionInEveryRequest', () {
    test('sends true', () async {
      await PluginMappintelligence.setSendAppVersionInEveryRequest(true);
      expect(lastCall().method, 'setSendAppVersionInEveryRequest');
      expect(lastCall().arguments, [true]);
    });

    test('sends false', () async {
      await PluginMappintelligence.setSendAppVersionInEveryRequest(false);
      expect(lastCall().arguments, [false]);
    });
  });

  // ---------------------------------------------------------------------------
  // enableCrashTracking
  // ---------------------------------------------------------------------------

  group('enableCrashTracking', () {
    test('sends ExceptionType index', () async {
      await PluginMappintelligence.enableCrashTracking(ExceptionType.uncaught);
      expect(lastCall().method, 'enableCrashTracking');
      expect(lastCall().arguments, [ExceptionType.uncaught.index]);
    });
  });

  // ---------------------------------------------------------------------------
  // optIn / optOut
  // ---------------------------------------------------------------------------

  group('optIn', () {
    test('invokes OptIn', () async {
      await PluginMappintelligence.optIn();
      expect(lastCall().method, 'OptIn');
    });
  });

  group('optOutAndSendCurrentData', () {
    test('invokes optOutAndSendCurrentData with value', () async {
      await PluginMappintelligence.optOutAndSendCurrentData(true);
      expect(lastCall().method, 'optOutAndSendCurrentData');
      expect(lastCall().arguments, [true]);
    });
  });

  // ---------------------------------------------------------------------------
  // reset
  // ---------------------------------------------------------------------------

  group('reset', () {
    test('invokes resetConfig', () async {
      await PluginMappintelligence.reset();
      expect(lastCall().method, 'resetConfig');
    });
  });

  // ---------------------------------------------------------------------------
  // trackPage
  // ---------------------------------------------------------------------------

  group('trackPage', () {
    test('without params invokes trackPage with name', () async {
      await PluginMappintelligence.trackPage('Home');
      expect(lastCall().method, 'trackPage');
      expect(lastCall().arguments, ['Home']);
    });

    test('with params invokes trackCustomPage with name and params map', () async {
      await PluginMappintelligence.trackPage('Home', {'key': 'value'});
      expect(lastCall().method, 'trackCustomPage');
      expect(lastCall().arguments, ['Home', {'key': 'value'}]);
    });
  });

  // ---------------------------------------------------------------------------
  // trackPageWithCustomData
  // ---------------------------------------------------------------------------

  group('trackPageWithCustomData', () {
    test('with customName invokes trackPageWithCustomNameAndPageViewEvent', () async {
      await PluginMappintelligence.trackPageWithCustomData(null, 'MyPage');
      expect(lastCall().method, 'trackPageWithCustomNameAndPageViewEvent');
      expect(lastCall().arguments, ['MyPage']);
    });

    test('with pageViewEvent invokes trackPageWithCustomData with JSON', () async {
      final event = PageViewEvent('ProductPage');
      await PluginMappintelligence.trackPageWithCustomData(event);
      expect(lastCall().method, 'trackPageWithCustomData');
      final decoded = jsonDecode(lastCall().arguments[0] as String);
      expect(decoded['name'], 'ProductPage');
    });

    test('pageViewEvent JSON includes nested objects', () async {
      final event = PageViewEvent('Cart');
      event.pageParameters = PageParameters()..searchTerm = 'shoes';
      event.ecommerceParameters = EcommerceParameters()..currency = 'EUR';
      await PluginMappintelligence.trackPageWithCustomData(event);
      final decoded = jsonDecode(lastCall().arguments[0] as String);
      expect(decoded['pageParameters']['searchTerm'], 'shoes');
      expect(decoded['ecommerceParameters']['currency'], 'EUR');
    });
  });

  // ---------------------------------------------------------------------------
  // trackExceptionWithNameAndMessage
  // ---------------------------------------------------------------------------

  group('trackExceptionWithNameAndMessage', () {
    test('sends name and message in map', () async {
      await PluginMappintelligence.trackExceptionWithNameAndMessage(
          'NullPointerException', 'stack trace here');
      expect(lastCall().method, 'trackExceptionWithNameAndMessage');
      expect(lastCall().arguments['name'], 'NullPointerException');
      expect(lastCall().arguments['message'], 'stack trace here');
    });
  });

  // ---------------------------------------------------------------------------
  // trackAction
  // ---------------------------------------------------------------------------

  group('trackAction', () {
    test('invokes trackAction with JSON-encoded ActionEvent', () async {
      final event = ActionEvent('ButtonClick');
      event.eventParameters = EventParameters()
        ..parameters = {1: 'param_value'};
      await PluginMappintelligence.trackAction(event);
      expect(lastCall().method, 'trackAction');
      final decoded = jsonDecode(lastCall().arguments[0] as String);
      expect(decoded['name'], 'ButtonClick');
      expect(decoded['eventParameters']['parameters']['1'], 'param_value');
    });
  });

  // ---------------------------------------------------------------------------
  // trackUrl
  // ---------------------------------------------------------------------------

  group('trackUrl', () {
    test('without mediaCode invokes trackUrlWithoutMediaCode', () async {
      await PluginMappintelligence.trackUrl('https://example.com', null);
      expect(lastCall().method, 'trackUrlWithoutMediaCode');
      expect(lastCall().arguments, ['https://example.com']);
    });

    test('with mediaCode invokes trackUrl with url and code', () async {
      await PluginMappintelligence.trackUrl('https://example.com', 'mc123');
      expect(lastCall().method, 'trackUrl');
      expect(lastCall().arguments, ['https://example.com', 'mc123']);
    });
  });

  // ---------------------------------------------------------------------------
  // trackMedia
  // ---------------------------------------------------------------------------

  group('trackMedia', () {
    test('invokes trackMedia with JSON-encoded MediaEvent', () async {
      final params = MediaParameters('video.mp4')
        ..action = 'play'
        ..duration = 120
        ..position = 0;
      final event = MediaEvent('VideoPlayer', params);
      await PluginMappintelligence.trackMedia(event);
      expect(lastCall().method, 'trackMedia');
      final decoded = jsonDecode(lastCall().arguments[0] as String);
      expect(decoded['name'], 'VideoPlayer');
      expect(decoded['mediaParameters']['action'], 'play');
      expect(decoded['mediaParameters']['duration'], 120);
    });
  });

  // ---------------------------------------------------------------------------
  // trackWebview
  // ---------------------------------------------------------------------------

  group('trackWebview', () {
    test('with all coordinates sends x, y, width, height, url', () async {
      await PluginMappintelligence.trackWebview(0, 0, 320, 480, 'https://example.com');
      expect(lastCall().method, 'trackWebview');
      expect(lastCall().arguments, [0.0, 0.0, 320.0, 480.0, 'https://example.com']);
    });

    test('with null coordinates sends only url', () async {
      await PluginMappintelligence.trackWebview(null, null, null, null, 'https://example.com');
      expect(lastCall().method, 'trackWebview');
      expect(lastCall().arguments, ['https://example.com']);
    });
  });

  // ---------------------------------------------------------------------------
  // getEverID / setEverId
  // ---------------------------------------------------------------------------

  group('getEverID', () {
    test('invokes getEverId and returns value', () async {
      final id = await PluginMappintelligence.getEverID();
      expect(lastCall().method, 'getEverId');
      expect(id, 'ever-id-123');
    });

    test('returns empty string when native returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return null;
      });
      final id = await PluginMappintelligence.getEverID();
      expect(id, '');
    });
  });

  group('setEverId', () {
    test('invokes setEverId with the provided id', () async {
      await PluginMappintelligence.setEverId('new-ever-id');
      expect(lastCall().method, 'setEverId');
      expect(lastCall().arguments, ['new-ever-id']);
    });
  });

  // ---------------------------------------------------------------------------
  // setIdsAndDomain / getTrackIdsAndDomain
  // ---------------------------------------------------------------------------

  group('setIdsAndDomain', () {
    test('sends trackIds and trackDomain', () async {
      await PluginMappintelligence.setIdsAndDomain(['id1', 'id2'], 'track.com');
      expect(lastCall().method, 'setIdsAndDomain');
      expect(lastCall().arguments['trackIds'], ['id1', 'id2']);
      expect(lastCall().arguments['trackDomain'], 'track.com');
    });
  });

  group('getTrackIdsAndDomain', () {
    test('invokes getIdsAndDomain and returns map', () async {
      final data = await PluginMappintelligence.getTrackIdsAndDomain();
      expect(lastCall().method, 'getIdsAndDomain');
      expect(data?['trackIds'], ['123']);
      expect(data?['trackDomain'], 'example.com');
    });
  });

  // ---------------------------------------------------------------------------
  // setAnonymousTracking
  // ---------------------------------------------------------------------------

  group('setAnonymousTracking', () {
    test('sends anonymousTracking=true with non-empty params', () async {
      await PluginMappintelligence.setAnonymousTracking(true, ['email']);
      expect(lastCall().method, 'enableAnonymousTracking');
      expect(lastCall().arguments['anonymousTracking'], true);
      expect(lastCall().arguments['params'], ['email']);
    });

    test('sends params as null when list is empty', () async {
      await PluginMappintelligence.setAnonymousTracking(false, []);
      expect(lastCall().arguments['params'], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // setTemporarySessionId
  // ---------------------------------------------------------------------------

  group('setTemporarySessionId', () {
    test('sends session id in map', () async {
      await PluginMappintelligence.setTemporarySessionId('session-abc');
      expect(lastCall().method, 'setTemporarySessionId');
      expect(lastCall().arguments['temporarySessionId'], 'session-abc');
    });
  });

  // ---------------------------------------------------------------------------
  // setUserMatchingEnabled / setEnableBackgroundSendout
  // ---------------------------------------------------------------------------

  group('setUserMatchingEnabled', () {
    test('sends enabled flag', () async {
      await PluginMappintelligence.setUserMatchingEnabled(true);
      expect(lastCall().method, 'setUserMatchingEnabled');
      expect(lastCall().arguments['enabled'], true);
    });
  });

  group('setEnableBackgroundSendout', () {
    test('sends enabled flag', () async {
      await PluginMappintelligence.setEnableBackgroundSendout(false);
      expect(lastCall().method, 'setEnableBackgroundSendout');
      expect(lastCall().arguments['enabled'], false);
    });
  });

  // ---------------------------------------------------------------------------
  // getCurrentConfig
  // ---------------------------------------------------------------------------

  group('getCurrentConfig', () {
    test('invokes getCurrentConfig and returns map', () async {
      final config = await PluginMappintelligence.getCurrentConfig();
      expect(callWithMethod('getCurrentConfig').method, 'getCurrentConfig');
      expect(config['key'], 'value');
    });
  });

  // ---------------------------------------------------------------------------
  // sendAndCleanData
  // ---------------------------------------------------------------------------

  group('sendAndCleanData', () {
    test('invokes sendAndCleanData', () async {
      await PluginMappintelligence.sendAndCleanData();
      expect(callWithMethod('sendAndCleanData').method, 'sendAndCleanData');
    });
  });

  // ---------------------------------------------------------------------------
  // reset
  // ---------------------------------------------------------------------------

  group('reset', () {
    test('invokes resetConfig', () async {
      await PluginMappintelligence.reset();
      expect(lastCall().method, 'resetConfig');
    });
  });

  // ---------------------------------------------------------------------------
  // trackError
  // ---------------------------------------------------------------------------

  group('trackError', () {
    test('sends userInfo, domain and code', () async {
      await PluginMappintelligence.trackError({'key': 'val'}, 'com.example', 42);
      expect(lastCall().method, 'trackError');
      expect(lastCall().arguments['domain'], 'com.example');
      expect(lastCall().arguments['code'], 42);
      expect(lastCall().arguments['userInfo'], {'key': 'val'});
    });
  });
}
