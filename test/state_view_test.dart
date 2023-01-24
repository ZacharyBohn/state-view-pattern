import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_examples.dart';

void main() {
  testWidgets('State variable accessible from UI', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomePage(initialUsername: 'test_username')),
    );
    expect(find.text('Current username: test_username'), findsOneWidget);
    return;
  });
  testWidgets('UI rebuilds on state notifyListeners()', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomePage(initialUsername: 'test_username')),
    );
    await tester.enterText(find.byType(TextField), 'new username');
    await tester.pumpAndSettle();
    expect(find.text('Current username: new username'), findsOneWidget);
    return;
  });
  testWidgets('Dynamic type of page fails at runtime', (tester) async {
    bool failed = false;
    try {
      await tester.pumpWidget(
        MaterialApp(home: SettingsPage()),
      );
      await tester.pumpAndSettle();
    } catch (e) {
      failed = true;
    }
    expect(failed, true);
    return;
  });
  testWidgets('Only rebuilds UI on listened to values', (tester) async {
    // TODO: implement
    return;
  });
}
