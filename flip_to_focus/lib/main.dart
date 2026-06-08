import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

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
                    // Przejście do ekranu czujników!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorTimerScreen(),
                      ),
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
        ),
      ),
    );
  }
}

class SensorTimerScreen extends StatefulWidget {
  const SensorTimerScreen({super.key});

  @override
  State<SensorTimerScreen> createState() => _SensorTimerScreenState();
}

class _SensorTimerScreenState extends State<SensorTimerScreen> {
  double _zAxis = 0.0;
  bool _isFlat = false;
  int _secondsLeft = 60; // UWAGA: Zmieniłem na 60 dla pewności!
  int _points = 0;
  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
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
      _secondsLeft = 60;
    });
  }

  void _stopTimerWithSuccess() {
    _timer?.cancel();
    _timer = null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SUKCES! Zdobywasz +10 punktów!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _points += 10;
      _secondsLeft = 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
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
              '$_secondsLeft s',
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
