# Mapp Intelligence Flutter Plugin

[![pub.dev](https://img.shields.io/pub/v/plugin_mappintelligence.svg)](https://pub.dev/packages/plugin_mappintelligence)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-lightgrey.svg)](https://pub.dev/packages/plugin_mappintelligence)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter plugin for integrating the [Mapp Intelligence](https://mapp.com/) SDK into Android and iOS applications. Track user activity, screen flow, media usage, ecommerce events, and link app sessions with WebView sessions — all from a single Dart API.

[Documentation](https://documentation.mapp.com/latest/en/flutter-software-development-kit-19109838.html) | [pub.dev](https://pub.dev/packages/plugin_mappintelligence) | [Support](https://support.webtrekk.com/) | [Changelog](CHANGELOG.md)

---

## Requirements

| | Minimum version |
|---|---|
| Flutter | 1.20.0 |
| Dart SDK | 2.17.0 |
| Android | API 21 (Android 5.0) |
| iOS | 12.0 |

---

## Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  plugin_mappintelligence: ^5.0.10
```

Then run:

```bash
flutter pub get
```

---

## Setup

### Android

No native setup required. All initialization is done from Dart.

### iOS

No native setup required. All initialization is done from Dart.

---

## Initialization

Initialize the SDK as early as possible, typically in `main()`:

```dart
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PluginMappintelligence.initialize(
    ['794940687426749'],
    'https://tracker.mapp.com',
  );

  await PluginMappintelligence.setLogLevel(LogLevel.debug);
  await PluginMappintelligence.setBatchSupportEnabledWithSize(true, 150);
  await PluginMappintelligence.setRequestInterval(60);
  await PluginMappintelligence.enableCrashTracking(ExceptionType.allExceptionTypes);
  await PluginMappintelligence.build(); // Android only — required to finalize config

  runApp(MyApp());
}
```

---

## Usage

### Page Tracking

Track a simple page view:

```dart
await PluginMappintelligence.trackPage('Home');
```

Track a page with custom parameters:

```dart
await PluginMappintelligence.trackPage('ProductDetail', {
  'product_id': '12345',
  'category': 'shoes',
});
```

Track a page with full event data:

```dart
final event = PageViewEvent('Checkout');
event.pageParameters = PageParameters()
  ..searchTerm = 'running shoes'
  ..params = {1: 'organic'};
event.ecommerceParameters = EcommerceParameters()
  ..currency = 'EUR'
  ..orderValue = 89.99;

await PluginMappintelligence.trackPageWithCustomData(event);
```

### Automatic Page Tracking with Navigator

Add `MappAnalyticsObserver` to your `MaterialApp` to track navigation automatically:

```dart
import 'package:plugin_mappintelligence/tracking/mapp_analytics_observer.dart';
import 'package:plugin_mappintelligence/tracking/tracking_events.dart';

MaterialApp(
  navigatorObservers: [
    MappAnalyticsObserver([TrackingEvents.PUSH]),
  ],
  // ...
)
```

### Action Tracking

```dart
final event = ActionEvent('AddToCart');
event.eventParameters = EventParameters()
  ..parameters = {1: 'product_id', 2: 'quantity'};

await PluginMappintelligence.trackAction(event);
```

### Ecommerce Tracking

```dart
final product = Product()
  ..name = 'Running Shoes'
  ..cost = 89.99
  ..quantity = 1;

final ecommerce = EcommerceParameters()
  ..products = [product]
  ..status = Status.purchased
  ..currency = 'EUR'
  ..orderID = 'ORD-9876'
  ..orderValue = 89.99;

final event = PageViewEvent('OrderConfirmation');
event.ecommerceParameters = ecommerce;

await PluginMappintelligence.trackPageWithCustomData(event);
```

### Media Tracking

```dart
final mediaParams = MediaParameters('intro_video.mp4')
  ..action = 'play'
  ..duration = 180
  ..position = 0
  ..soundVolume = 1.0;

final event = MediaEvent('VideoPlayer', mediaParams);
await PluginMappintelligence.trackMedia(event);
```

### Campaign / URL Tracking

```dart
// Track a deeplink URL with a media code
await PluginMappintelligence.trackUrl('https://example.com/promo', 'SUMMER2024');

// Track without a media code
await PluginMappintelligence.trackUrl('https://example.com/landing', null);
```

### Exception Tracking

```dart
try {
  // ...
} catch (e, stack) {
  await PluginMappintelligence.trackExceptionWithNameAndMessage(
    e.runtimeType.toString(),
    stack.toString(),
  );
}
```

### Privacy & Consent

```dart
// Opt in — enable tracking
await PluginMappintelligence.optIn();

// Opt out — disable tracking and optionally send remaining data
await PluginMappintelligence.optOutAndSendCurrentData(true);

// Anonymous tracking — track without persisting identifiers
await PluginMappintelligence.setAnonymousTracking(true, ['email', 'phone']);
```

### EverID Management

```dart
// Get the current EverID
final everId = await PluginMappintelligence.getEverID();

// Set a specific EverID
await PluginMappintelligence.setEverId('custom-ever-id');
```

---

## WebView Session Linking

To keep tracking sessions continuous between your native app and a WebView, use `WebTrackingController`. It injects the app's EverID into the WebView and forwards tracking events from the web page back to the native SDK.

### Basic usage

```dart
import 'package:plugin_mappintelligence/WebTrackingController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    WebTrackingController(controller: _controller);

    _controller.loadRequest(Uri.parse('https://your-tracked-page.com'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
```

### With custom NavigationDelegate callbacks

Pass your own `NavigationDelegate` — all callbacks are preserved alongside the plugin's tracking logic:

```dart
WebTrackingController(
  controller: _controller,
  navigationDelegate: NavigationDelegate(
    onPageStarted: (url) {
      print('Loading: $url');
    },
    onPageFinished: (url) {
      // Fires after EverID has been injected into the page
      print('Loaded: $url');
    },
    onProgress: (progress) {
      print('Progress: $progress%');
    },
    onWebResourceError: (error) {
      print('Error: ${error.description}');
    },
    onNavigationRequest: (request) {
      // Block specific URLs if needed
      if (request.url.contains('blocked.com')) {
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    },
  ),
  onLoad: () {
    // Called after EverID injection completes successfully
    print('EverID injected');
  },
  onMessage: (message) {
    // Called when the WebView sends a tracking event
    print('WebView message: $message');
  },
);
```

The WebView page must use the `ReactNativeWebView` JavaScript bridge to send tracking events:

```javascript
// Track a page from the WebView
window.ReactNativeWebView.postMessage(JSON.stringify({
  method: 'trackCustomPage',
  name: 'WebProductDetail',
  params: '{"product":"shoes"}'
}));

// Track an event from the WebView
window.ReactNativeWebView.postMessage(JSON.stringify({
  method: 'trackCustomEvent',
  name: 'WebAddToCart',
  params: '{"product":"shoes"}'
}));
```

---

## Configuration Reference

| Method | Description |
|---|---|
| `initialize(trackIds, trackDomain)` | Initialize the SDK with tracking IDs and domain |
| `setLogLevel(LogLevel)` | Set logging verbosity (`all`, `debug`, `warning`, `error`, `none`) |
| `setBatchSupportEnabledWithSize(bool, int)` | Enable batching requests with a maximum queue size |
| `setRequestInterval(int)` | Set the interval in seconds between batch sends |
| `setRequestPerQueue(int)` | Set the maximum number of requests per queue |
| `setSendAppVersionInEveryRequest(bool)` | Include app version in every tracking request |
| `enableCrashTracking(ExceptionType)` | Enable automatic crash/exception tracking |
| `setAnonymousTracking(bool, List<String>)` | Enable anonymous mode, optionally suppressing specific fields |
| `setUserMatchingEnabled(bool)` | Enable cross-device user matching |
| `setEnableBackgroundSendout(bool)` | Send queued requests when the app moves to background |
| `setTemporarySessionId(String)` | Set a temporary session identifier |
| `optIn()` | Enable tracking after opt-out |
| `optOutAndSendCurrentData(bool)` | Disable tracking, optionally flushing queued data |
| `build()` | Finalize configuration — Android only, call after all configuration |

---

## Contributing

See [INSTRUCTIONS.md](INSTRUCTIONS.md) for the full development, testing, and release workflow.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
