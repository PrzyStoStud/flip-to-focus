import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flip_to_focus/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = http.Response('{"access_token": "fake_test_token"}', 200);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test logowania i przejścia do wyboru czasu', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(httpClient: MockClient())),
    );

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
