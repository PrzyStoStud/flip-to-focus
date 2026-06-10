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
  int _sessionPoints = 0;
  DateTime? _globalStartTime;
  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.sessionDurationSeconds;

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

  void _evaluateTimerState() {
    if (_isFlat && _timer == null) {
      _startTimer();
    } else if (!_isFlat && _timer != null) {
      _stopTimerWithFailure();
    }
  }

  void _startTimer() {
    _startTime ??= DateTime.now();
    _globalStartTime ??= DateTime.now();

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

  void _stopTimerWithFailure() async {
    _timer?.cancel();
    _timer = null;
    _startTime = null;

    if (_sessionPoints > 0) {
      final endTime = DateTime.now();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koniec nauki. Wysyłam $_sessionPoints pkt na serwer!'),
          backgroundColor: Colors.blue,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      int currentTotal = prefs.getInt('total_points') ?? 0;
      await prefs.setInt('total_points', currentTotal + _sessionPoints);

      _sendSessionToServer(
        _globalStartTime ?? endTime,
        endTime,
        _sessionPoints,
      );

      setState(() {
        _sessionPoints = 0;
        _globalStartTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesja przerwana! Podniosłeś telefon za wcześnie.'),
          backgroundColor: Colors.red,
        ),
      );
      _globalStartTime = null;
    }

    setState(() {
      _secondsLeft = widget.sessionDurationSeconds;
    });
  }

  void _stopTimerWithSuccess() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ukończono cykl! Zbierasz punkty. Nie podnoś telefonu!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _sessionPoints += 10;
      _secondsLeft = widget.sessionDurationSeconds;
    });

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
      final offlineList = prefs.getStringList('offline_sessions') ?? [];
      offlineList.add(bodyData);
      await prefs.setStringList('offline_sessions', offlineList);
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
                'Ta sesja: +$_sessionPoints pkt',
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
