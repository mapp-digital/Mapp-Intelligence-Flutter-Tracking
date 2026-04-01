import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_mappintelligence/WebTrackingController.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

// ---------------------------------------------------------------------------
// Fake platform — captures NavigationDelegate callbacks so tests can trigger
// them directly without a real device.
// ---------------------------------------------------------------------------

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) =>
      FakeWebViewController(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) =>
      FakeWebViewWidget(params);

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) =>
      FakeCookieManager(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) =>
      FakeNavigationDelegate(params);
}

/// Stores callbacks registered by NavigationDelegate so tests can fire them.
class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(super.params) : super.implementation();

  PageEventCallback? _onPageStarted;
  PageEventCallback? _onPageFinished;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;
  @override
  Future<void> setOnPageStarted(PageEventCallback cb) async =>
      _onPageStarted = cb;
  @override
  Future<void> setOnPageFinished(PageEventCallback cb) async =>
      _onPageFinished = cb;
  @override
  Future<void> setOnProgress(ProgressCallback cb) async => _onProgress = cb;
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback cb) async =>
      _onWebResourceError = cb;
  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback cb) async =>
      _onNavigationRequest = cb;
  @override
  Future<void> setOnUrlChange(UrlChangeCallback cb) async {}
  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback cb) async {}
  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback cb) async {}

  // Simulation helpers
  void simulatePageStarted(String url) => _onPageStarted?.call(url);
  Future<void> simulatePageFinished(String url) async =>
      _onPageFinished?.call(url);
  void simulateProgress(int progress) => _onProgress?.call(progress);
  void simulateWebResourceError(WebResourceError error) =>
      _onWebResourceError?.call(error);
  Future<NavigationDecision> simulateNavigationRequest(
          NavigationRequest req) async =>
      await _onNavigationRequest?.call(req) ?? NavigationDecision.navigate;
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  FakeNavigationDelegate? capturedDelegate;
  final List<String> jsLog = [];
  final List<JavaScriptChannelParams> channels = [];

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {
    capturedDelegate = handler as FakeNavigationDelegate;
  }

  @override
  Future<void> runJavaScript(String js) async => jsLog.add(js);

  @override
  Future<String> runJavaScriptReturningResult(String js) async => '';

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async =>
      channels.add(params);

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<String?> currentUrl() async => 'https://example.com';
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => Container();
}

class FakeCookieManager extends PlatformWebViewCookieManager {
  FakeCookieManager(super.params) : super.implementation();
}

// ---------------------------------------------------------------------------
// Helper: get the FakeWebViewController backing a WebViewController
// ---------------------------------------------------------------------------
FakeWebViewController _fakePlatformController(WebViewController controller) {
  return controller.platform as FakeWebViewController;
}

Future<T> _runQuietly<T>(FutureOr<T> Function() body) {
  return runZoned(
    () async => await body(),
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, ____) {},
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugin_mappintelligence');
  late WebViewController controller;
  late FakeWebViewController fakeController;

  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
    controller = WebViewController();
    fakeController = _fakePlatformController(controller);

    // Mock the native method channel used by PluginMappintelligence
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'getEverId':
          return 'test-ever-id-123';
        case 'trackWebviewConfiguration':
        case 'trackExceptionWithNameAndMessage':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // -------------------------------------------------------------------------
  // 1. Basic setup
  // -------------------------------------------------------------------------

  test('constructs without error when no navigationDelegate is provided', () {
    expect(
      () => WebTrackingController(controller: controller),
      returnsNormally,
    );
  });

  test('registers a NavigationDelegate on the controller', () {
    WebTrackingController(controller: controller);
    expect(fakeController.capturedDelegate, isNotNull);
  });

  test('registers ReactNativeWebView JavaScript channel', () {
    WebTrackingController(controller: controller);
    expect(
      fakeController.channels.any((c) => c.name == 'ReactNativeWebView'),
      isTrue,
    );
  });

  // -------------------------------------------------------------------------
  // 2. Regression: bug reproduction — client callbacks were silently dropped
  //    (demonstrates what the issue was before the fix)
  // -------------------------------------------------------------------------

  test(
      'REGRESSION: without fix, a second setNavigationDelegate call would '
      'override the first — verified by confirming only one delegate is active',
      () {
    // Before the fix, clients had to call setNavigationDelegate themselves,
    // which WebTrackingController then replaced. Now clients pass their
    // callbacks via navigationDelegate parameter — only one delegate is set.
    bool clientCalled = false;

    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onPageStarted: (_) => clientCalled = true,
      ),
    );

    fakeController.capturedDelegate!.simulatePageStarted('https://example.com');
    expect(clientCalled, isTrue,
        reason: 'Client onPageStarted must not be dropped');
  });

  // -------------------------------------------------------------------------
  // 3. All five callbacks are forwarded
  // -------------------------------------------------------------------------

  test('onPageStarted client callback is forwarded', () {
    String? capturedUrl;
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onPageStarted: (url) => capturedUrl = url,
      ),
    );

    fakeController.capturedDelegate!.simulatePageStarted('https://example.com');
    expect(capturedUrl, 'https://example.com');
  });

  test('onProgress client callback is forwarded', () {
    int? capturedProgress;
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onProgress: (p) => capturedProgress = p,
      ),
    );

    fakeController.capturedDelegate!.simulateProgress(75);
    expect(capturedProgress, 75);
  });

  test('onWebResourceError client callback is forwarded', () {
    WebResourceError? capturedError;
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onWebResourceError: (e) => capturedError = e,
      ),
    );

    final error = WebResourceError(
      errorCode: 404,
      description: 'Not found',
      errorType: WebResourceErrorType.fileNotFound,
    );
    fakeController.capturedDelegate!.simulateWebResourceError(error);
    expect(capturedError?.description, 'Not found');
  });

  test('onNavigationRequest client callback is forwarded', () async {
    bool clientCalled = false;
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onNavigationRequest: (req) {
          clientCalled = true;
          return NavigationDecision.navigate;
        },
      ),
    );

    await fakeController.capturedDelegate!.simulateNavigationRequest(
      NavigationRequest(url: 'https://example.com', isMainFrame: true),
    );
    expect(clientCalled, isTrue);
  });

  test('onNavigationRequest preserves prevent decision from client callback',
      () async {
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onNavigationRequest: (_) => NavigationDecision.prevent,
      ),
    );

    final decision =
        await fakeController.capturedDelegate!.simulateNavigationRequest(
      NavigationRequest(url: 'https://example.com', isMainFrame: true),
    );
    expect(decision, NavigationDecision.prevent);
  });

  // -------------------------------------------------------------------------
  // 4. onPageFinished ordering — client fires AFTER EverID injection
  // -------------------------------------------------------------------------

  test('onPageFinished: plugin injects EverID before client callback fires',
      () async {
    final log = <String>[];

    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onPageFinished: (_) => log.add('client'),
      ),
    );

    await fakeController.capturedDelegate!
        .simulatePageFinished('https://example.com');
    // Flush the full async chain: handleLoad (method channel) → runJavaScript → .then(client cb)
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
        fakeController.jsLog
            .any((js) => js.contains('webtrekkApplicationEverId')),
        isTrue,
        reason: 'EverID script must have been injected');
    expect(log, contains('client'),
        reason: 'Client onPageFinished must fire after injection');
  });

  test('onPageFinished: EverID value from native is injected into the page',
      () async {
    WebTrackingController(controller: controller);

    await fakeController.capturedDelegate!
        .simulatePageFinished('https://example.com');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      fakeController.jsLog.any((js) => js.contains("'test-ever-id-123'")),
      isTrue,
    );
  });

  // -------------------------------------------------------------------------
  // 5. onLoad fires only on success, not after getEverID failure
  // -------------------------------------------------------------------------

  test('onLoad is called on successful page load', () async {
    bool onLoadCalled = false;
    final wt = WebTrackingController(
      controller: controller,
      onLoad: () => onLoadCalled = true,
    );

    await wt.handleLoad();
    expect(onLoadCalled, isTrue);
  });

  test('onLoad is NOT called when getEverID throws', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getEverId') throw PlatformException(code: 'ERROR');
      return null;
    });

    bool onLoadCalled = false;
    final wt = WebTrackingController(
      controller: controller,
      onLoad: () => onLoadCalled = true,
    );

    await _runQuietly(() => wt.handleLoad());
    expect(onLoadCalled, isFalse);
  });

  test('client onPageFinished still fires when EverID injection fails',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getEverId') throw PlatformException(code: 'ERROR');
      return null;
    });

    bool clientCalled = false;
    WebTrackingController(
      controller: controller,
      navigationDelegate: NavigationDelegate(
        onPageFinished: (_) => clientCalled = true,
      ),
    );

    await _runQuietly(() async {
      await fakeController.capturedDelegate!
          .simulatePageFinished('https://example.com');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    expect(clientCalled, isTrue);
  });

  // -------------------------------------------------------------------------
  // 6. JavaScript channel message dispatch
  // -------------------------------------------------------------------------

  test('malformed JSON message does not throw', () {
    WebTrackingController(controller: controller);
    final channel = fakeController.channels
        .firstWhere((c) => c.name == 'ReactNativeWebView');

    expect(
      () => _runQuietly(
        () => channel.onMessageReceived(JavaScriptMessage(message: 'not-json')),
      ),
      returnsNormally,
    );
  });

  test('message missing method/name fields does not dispatch tracking call',
      () {
    final methodCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      methodCalls.add(call.method);
      return null;
    });

    WebTrackingController(controller: controller);
    final jsChannel = fakeController.channels
        .firstWhere((c) => c.name == 'ReactNativeWebView');

    _runQuietly(
      () => jsChannel
          .onMessageReceived(JavaScriptMessage(message: '{"foo":"bar"}')),
    );
    expect(methodCalls, isNot(contains('trackWebPage')));
    expect(methodCalls, isNot(contains('trackWebEvent')));
  });

  test('onMessage callback fires for every received message', () {
    final received = <String>[];
    WebTrackingController(
      controller: controller,
      onMessage: (msg) => received.add(msg),
    );

    final jsChannel = fakeController.channels
        .firstWhere((c) => c.name == 'ReactNativeWebView');

    _runQuietly(
      () => jsChannel.onMessageReceived(JavaScriptMessage(message: 'hello')),
    );
    expect(received, contains('hello'));
  });

  test('trackCustomPage message dispatches trackWebPage', () async {
    final methodCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      methodCalls.add(call);
      return null;
    });

    WebTrackingController(controller: controller);
    final jsChannel = fakeController.channels
        .firstWhere((c) => c.name == 'ReactNativeWebView');

    await _runQuietly(
      () => jsChannel.onMessageReceived(
        JavaScriptMessage(
          message:
              '{"method":"trackCustomPage","name":"Home","params":"{\\"foo\\":\\"bar\\"}"}',
        ),
      ),
    );

    expect(
      methodCalls.any((call) => call.method == 'trackWebPage'),
      Platform.isAndroid,
    );
  });

  test('trackCustomEvent message dispatches trackWebEvent', () async {
    final methodCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      methodCalls.add(call);
      return null;
    });

    WebTrackingController(controller: controller);
    final jsChannel = fakeController.channels
        .firstWhere((c) => c.name == 'ReactNativeWebView');

    await _runQuietly(
      () => jsChannel.onMessageReceived(
        JavaScriptMessage(
          message:
              '{"method":"trackCustomEvent","name":"CTA","params":"{\\"foo\\":\\"bar\\"}"}',
        ),
      ),
    );

    expect(
      methodCalls.any((call) => call.method == 'trackWebEvent'),
      Platform.isAndroid,
    );
  });
}
