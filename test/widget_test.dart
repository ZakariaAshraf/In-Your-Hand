import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_your_hand/core/cache/cache_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full [MyApp] needs Firebase + ads init; cover that with integration_tests.
/// This smoke test only verifies widget harness + [CacheHelper] (prefs mock).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  testWidgets('widget harness and CacheHelper init', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('ok'))),
    );
    expect(find.text('ok'), findsOneWidget);
    expect(CacheHelper.getBool(key: CacheKeys.theme), isNull);
  });
}
