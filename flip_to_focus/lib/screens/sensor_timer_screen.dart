import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
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

      if (_isFlat && _timer == null) {
        _startTimer();
      } else if (!_isFlat && _timer != null) {
        _stopTimerWithFailure();
      }
    });
  }

  void _startTimer() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SUKCES! Zdobywasz punkty!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _points += 10;
      _secondsLeft = widget.sessionDurationSeconds;
    });
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
