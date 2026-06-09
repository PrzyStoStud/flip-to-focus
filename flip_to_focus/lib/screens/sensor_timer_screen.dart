import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SensorTimerScreen extends StatefulWidget {
  final int sessionDurationSeconds;

  const SensorTimerScreen({super.key, required this.sessionDurationSeconds});

  @override
  State<SensorTimerScreen> createState() => _SensorTimerScreenState();
}

class _SensorTimerScreenState extends State<SensorTimerScreen> {
  double _zAxis = 0.0;
  bool _isFlat = false;
  late int _secondsLeft;
  int _points = 0;
  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.sessionDurationSeconds;

    _loadSavedPoints();

    _sensorSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      setState(() {
        _zAxis = event.z;
        _isFlat = _zAxis < -8.5;
      });

      _evaluateTimerState();
    });
  }

  Future<void> _loadSavedPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _points = prefs.getInt('total_points') ?? 0;
    });
  }

  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_points', _points);
  }

  void _evaluateTimerState() {
    if (_isFlat && _timer == null) {
      _startTimer();
    } else if (!_isFlat && _timer != null) {
      _stopTimerWithFailure();
    }
  }

  void _startTimer() {
    _startTime ??= DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _stopTimerWithSuccess();
        }
      });
    });
  }

  void _stopTimerWithFailure() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesja przerwana! Podniosłeś telefon.'),
        backgroundColor: Colors.red,
      ),
    );

    setState(() {
      _secondsLeft = widget.sessionDurationSeconds;
    });
  }

  void _stopTimerWithSuccess() {
    _timer?.cancel();
    _timer = null;

    final endTime = DateTime.now();
    final actualStartTime =
        _startTime ??
        endTime.subtract(Duration(seconds: widget.sessionDurationSeconds));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SUKCES! Zdobywasz punkty!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _points += 10;
      _secondsLeft = widget.sessionDurationSeconds;
      _startTime = null;
    });

    _savePoints();
    _sendSessionToServer(actualStartTime, endTime, 10);
    _evaluateTimerState();
  }

  Future<void> _sendSessionToServer(
    DateTime start,
    DateTime end,
    int pointsEarned,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) return;

    final url = Uri.parse('https://flip-to-focus.tau2c.top/sessions');
    final bodyData = jsonEncode({
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'points': pointsEarned,
    });

    try {
      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyData,
      );

      if (response.statusCode == 401) {
        final refreshed = await _refreshAccessToken();

        if (refreshed) {
          token = prefs.getString('jwt_token');
          response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: bodyData,
          );
        } else {
          return;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
      } else {}
    } catch (e) {
      //
    }
  }

  Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return false;

    try {
      final url = Uri.parse('https://flip-to-focus.tau2c.top/auth/token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await prefs.setString('jwt_token', responseData['access_token']);

        if (responseData.containsKey('refresh_token')) {
          await prefs.setString('refresh_token', responseData['refresh_token']);
        }
        return true;
      }
    } catch (e) {
      //
    }

    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  String get formattedTime {
    int minutes = _secondsLeft ~/ 60;
    int seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFlat ? Colors.black : Colors.grey[900],
      appBar: AppBar(
        title: const Text('Aktywna Sesja'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Punkty: $_points',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFlat ? 'Świetnie! Skup się.' : 'Odłóż telefon ekranem w dół!',
              style: TextStyle(
                fontSize: 24,
                color: _isFlat ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text('Odczyt osi Z: ${_zAxis.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
