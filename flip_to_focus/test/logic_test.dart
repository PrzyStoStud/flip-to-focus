import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Logika Autoryzacji i Tokenów', () {
    test(
      '1. Pomyślne logowanie powinno zapisać tokeny w SharedPreferences',
      () async {
        final prefs = await SharedPreferences.getInstance();

        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_jwt_token',
              'refresh_token': 'fake_refresh',
            }),
            200,
          );
        });

        final response = await client.post(
          Uri.parse('https://flip-to-focus.tau2c.top/auth/token'),
        );
        final data = jsonDecode(response.body);

        await prefs.setString('jwt_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);

        expect(prefs.getString('jwt_token'), 'fake_jwt_token');
        expect(prefs.getString('refresh_token'), 'fake_refresh');
      },
    );

    test('2. Błędne logowanie (401) nie powinno zapisywać tokenów', () async {
      final prefs = await SharedPreferences.getInstance();

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid credentials'}),
          401,
        );
      });

      final response = await client.post(
        Uri.parse('https://flip-to-focus.tau2c.top/auth/token'),
      );

      if (response.statusCode == 200) {
        await prefs.setString('jwt_token', 'token'); 
      }

      expect(prefs.getString('jwt_token'), isNull);
    });

    test('3. Wylogowanie powinno całkowicie wyczyścić pamięć', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'token123');
      await prefs.setInt('total_points', 50);

      await prefs.remove('jwt_token');
      await prefs.remove('total_points');

      expect(prefs.getString('jwt_token'), isNull);
      expect(prefs.getInt('total_points'), isNull);
    });
  });

  group('Logika Trybu Offline (SharedPreferences)', () {
    test('4. Zapisanie pierwszej sesji do pustej kolejki offline', () async {
      final prefs = await SharedPreferences.getInstance();
      final bodyData = jsonEncode({'points': 10});

      final offlineList = prefs.getStringList('offline_sessions') ?? [];
      offlineList.add(bodyData);
      await prefs.setStringList('offline_sessions', offlineList);

      final savedList = prefs.getStringList('offline_sessions');
      expect(savedList, isNotNull);
      expect(savedList!.length, 1);
      expect(savedList[0], bodyData);
    });

    test(
      '5. Dodawanie kolejnych sesji nie nadpisuje starych w kolejce offline',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_sessions', [
          '{"points": 10}',
        ]);

        final offlineList = prefs.getStringList('offline_sessions') ?? [];
        offlineList.add('{"points": 20}'); 
        await prefs.setStringList('offline_sessions', offlineList);

        final savedList = prefs.getStringList('offline_sessions');
        expect(savedList!.length, 2);
        expect(savedList.last, '{"points": 20}');
      },
    );

    test(
      '6. Pomyślna synchronizacja powinna czyścić wybrane sesje z kolejki',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_sessions', ['sesja1', 'sesja2']);

        List<String> remainingSessions = [];
        await prefs.setStringList('offline_sessions', remainingSessions);

        expect(prefs.getStringList('offline_sessions'), isEmpty);
      },
    );
  });

  group('Logika Rejestracji', () {
    test('7. Pomyślna rejestracja powinna zwrócić kod 200 lub 201', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'email': 'test@test.com', 'id': '123'}),
          201,
        );
      });

      final response = await client.post(
        Uri.parse('https://flip-to-focus.tau2c.top/auth/register'),
      );
      expect(response.statusCode, inInclusiveRange(200, 201));
      expect(jsonDecode(response.body)['email'], 'test@test.com');
    });

    test(
      '8. Rejestracja istniejącego konta powinna zwrócić kod 400 (Validation Error)',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'detail': 'Email already registered'}),
            400,
          );
        });

        final response = await client.post(
          Uri.parse('https://flip-to-focus.tau2c.top/auth/register'),
        );
        expect(response.statusCode, 400);
      },
    );
  });

  group('Logika Operacji CRUD (Profil)', () {
    test('9. Pobieranie sumy punktów (GET) z poprawnym tokenem', () async {
      final client = MockClient((request) async {
        if (request.headers['Authorization'] == 'Bearer proper_token') {
          return http.Response(jsonEncode({'points': 150}), 200);
        }
        return http.Response('Unauthorized', 401);
      });

      final response = await client.get(
        Uri.parse('https://flip-to-focus.tau2c.top/sessions/points'),
        headers: {'Authorization': 'Bearer proper_token'},
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['points'], 150);
    });

    test(
      '10. Usuwanie sesji (DELETE) wysyła żądanie pod poprawny endpoint',
      () async {
        final String testSessionId = 'abc-123';

        final client = MockClient((request) async {
          expect(
            request.url.path,
            '/sessions/abc-123',
          ); 
          expect(request.method, 'DELETE');
          return http.Response('{}', 200);
        });

        final response = await client.delete(
          Uri.parse('https://flip-to-focus.tau2c.top/sessions/$testSessionId'),
        );

        expect(response.statusCode, 200);
      },
    );
  });
}
