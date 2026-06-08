import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flip_to_focus/main.dart';

void main() {
  testWidgets('Test logowania i przejścia do wyboru czasu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FlipToFocusApp());

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.text('ZALOGUJ');

    await tester.enterText(emailField, 'student@uczelnia.pl');
    await tester.enterText(passwordField, 'tajnehaslo123');

    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    expect(find.text('Wybierz czas skupienia'), findsOneWidget);
    expect(find.text('25 Minut (Pomodoro)'), findsOneWidget);
  });
}
