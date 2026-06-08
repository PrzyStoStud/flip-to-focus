import 'package:flutter/material.dart';
import 'time_selection_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zaloguj się'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Hasło',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logowanie z klawiatury...'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimeSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('ZALOGUJ'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Nie masz konta? Zarejestruj się!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
