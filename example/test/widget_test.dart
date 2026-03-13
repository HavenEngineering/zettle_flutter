import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zettle_example/main.dart';

void main() {
  testWidgets('App renders initial UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Zettle Example'), findsOneWidget);
    expect(find.text('SDK not initialized'), findsOneWidget);
    expect(find.text('Initialize SDK'), findsOneWidget);
  });

  testWidgets('Initialize button is enabled before init', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Initialize SDK'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Auth buttons are disabled before init', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);

    final loginButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Login'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(loginButton.onPressed, isNull);
  });

  testWidgets('Credential fields are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('iOS Client ID'), findsOneWidget);
    expect(find.text('Android Client ID'), findsOneWidget);
    expect(find.text('Redirect URL'), findsOneWidget);
  });
}
