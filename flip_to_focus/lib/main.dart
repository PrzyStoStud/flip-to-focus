import 'package:flutter/material.dart';

void main() {
  runApp(const FlipToFocusApp());
}

class FlipToFocusApp extends StatelessWidget {
  const FlipToFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark mode
    return MaterialApp(
      title: 'FlipToFocus',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zaloguj się'), centerTitle: true),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Hasło',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Button shows loading state
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logowanie... (stan: loading)')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('ZALOGUJ'),
            ),
          ],
        ),
      ),
    );
  }
}
