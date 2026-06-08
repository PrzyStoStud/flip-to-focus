import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FlipToFocusApp());
}

class FlipToFocusApp extends StatelessWidget {
  const FlipToFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipToFocus',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
