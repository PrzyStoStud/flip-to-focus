import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flip_to_focus/main.dart';

void main() {
  testWidgets('Test logowania - wpisywanie danych i klikanie przycisku', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FlipToFocusApp());

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.text('ZALOGUJ');

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(emailField, 'student@uczelnia.pl');
    await tester.enterText(passwordField, 'tajnehaslo123');

    await tester.tap(loginButton);

    await tester.pump();
  });
}