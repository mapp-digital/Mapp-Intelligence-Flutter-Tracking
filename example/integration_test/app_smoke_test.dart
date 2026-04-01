import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plugin_mappintelligence_example/main.dart' as app;

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final maxTicks = timeout.inMilliseconds ~/ step.inMilliseconds;
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for expected widget to appear.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example app launches and basic navigation works',
      (WidgetTester tester) async {
    app.main();

    final consentDialog = find.text('User Tracking');
    await _pumpUntilVisible(tester, consentDialog);
    expect(consentDialog, findsOneWidget);

    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Mapp Intelligence Demo'), findsOneWidget);
    expect(find.text('Page Tracking'), findsOneWidget);
    expect(find.text('Webview'), findsOneWidget);

    await tester.tap(find.text('Page Tracking'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Track Page'), findsOneWidget);
    expect(find.text('Track Custom Page'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Mapp Intelligence Demo'), findsOneWidget);
  });
}
