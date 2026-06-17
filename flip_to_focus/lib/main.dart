import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/time_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('jwt_token');
  runApp(FlipToFocusApp(isLoggedIn: token != null));
}

class FlipToFocusApp extends StatelessWidget {
  final bool isLoggedIn;
  const FlipToFocusApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipToFocus',
      theme: ThemeData.dark(),
      home: isLoggedIn ? const TimeSelectionScreen() : const LoginScreen(),
    );
  }
}
