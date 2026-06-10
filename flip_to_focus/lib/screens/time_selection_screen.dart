import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sensor_timer_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TimeSelectionScreen extends StatelessWidget {
  const TimeSelectionScreen({super.key});

  void _startSession(BuildContext context, int minutes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SensorTimerScreen(sessionDurationSeconds: minutes * 60),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final offlineList = prefs.getStringList('offline_sessions') ?? [];

    if (offlineList.isNotEmpty) {
      if (!context.mounted) return;
      final bool? shouldForceLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Niezapisane postępy!'),
          content: const Text(
            'Masz punkty zdobyte w trybie offline, które nie zostały jeszcze wysłane na serwer. '
            'Połącz się z internetem i wejdź w swój Profil, aby je zapisać. '
            '\n\nJeśli wylogujesz się teraz, te punkty PRZEPADNĄ. Czy na pewno chcesz się wylogować?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Wyloguj i strać punkty'),
            ),
          ],
        ),
      );

      if (shouldForceLogout != true) return;
    }

    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken != null) {
      try {
        final url = Uri.parse('https://flip-to-focus.tau2c.top/auth/logout');
        await http.post(
          url,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'refresh_token': refreshToken},
        );
      } catch (e) {
        //
      }
    }

    await prefs.remove('jwt_token');
    await prefs.remove('refresh_token');
    await prefs.remove('total_points');
    await prefs.remove('offline_sessions');

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz czas skupienia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Jak długo chcesz się uczyć?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildTimeButton(
                context,
                '15 Minut (Szybka powtórka)',
                15,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildTimeButton(
                context,
                '25 Minut (Pomodoro)',
                25,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildTimeButton(
                context,
                '60 Minut (Głębokie skupienie)',
                60,
                Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SensorTimerScreen(sessionDurationSeconds: 5),
                    ),
                  );
                },
                child: const Text(
                  'Szybki test (5 sekund)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(
    BuildContext context,
    String label,
    int minutes,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () => _startSession(context, minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
