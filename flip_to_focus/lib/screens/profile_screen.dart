import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalPoints = 0;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) return;

      await _syncOfflineSessions(token);

      final pointsUrl = Uri.parse(
        'https://flip-to-focus.tau2c.top/sessions/points',
      );
      final pointsResponse = await http.get(
        pointsUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      final listUrl = Uri.parse(
        'https://flip-to-focus.tau2c.top/sessions/list',
      );
      final listResponse = await http.get(
        listUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (pointsResponse.statusCode == 200 && listResponse.statusCode == 200) {
        final pointsData = jsonDecode(pointsResponse.body);
        final listData = jsonDecode(listResponse.body);

        setState(() {
          _totalPoints = pointsData['points'] ?? 0;
          _history = listData is List ? listData : [];
          _isLoading = false;
        });

        await prefs.setInt('total_points', _totalPoints);
      } else {
        _loadLocalData('Błąd serwera (Kod: ${pointsResponse.statusCode})');
      }
    } catch (e) {
      _loadLocalData('Błąd połączenia. Wyświetlam dane offline.');
    }
  }

  Future<void> _syncOfflineSessions(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineList = prefs.getStringList('offline_sessions') ?? [];

    if (offlineList.isEmpty) return; // Brak zaległych sesji

    final url = Uri.parse('https://flip-to-focus.tau2c.top/sessions');
    List<String> remainingSessions = [];

    // Pętla wysyła zaległe sesje jedna po drugiej
    for (String sessionData in offlineList) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: sessionData,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Sukces! Sesja wysłana, pomijamy dodawanie jej do remainingSessions
        } else {
          // Błąd backendu (np. 500), zostawiamy w kolejce na później
          remainingSessions.add(sessionData);
        }
      } catch (e) {
        // Znowu brak internetu, zostawiamy w kolejce
        remainingSessions.add(sessionData);
      }
    }

    // Nadpisujemy listę tylko tymi sesjami, których nie udało się wysłać
    await prefs.setStringList('offline_sessions', remainingSessions);
  }

  Future<void> _loadLocalData(String message) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalPoints = prefs.getInt('total_points') ?? 0;
      _errorMsg = message;
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final url = Uri.parse(
        'https://flip-to-focus.tau2c.top/sessions/$sessionId',
      );
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesja została usunięta.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProfileData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd usuwania sesji.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil użytkownika'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_errorMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMsg,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.amber,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Suma punktów',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                '$_totalPoints',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ukończone sesje',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                '${_history.length}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Historia Twoich sesji',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _history.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Brak zarejestrowanych sesji. Czas na naukę!',
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final session = _history[index];
                            final String startStr =
                                session['start'] ?? 'Nieznana data';
                            final int pts = session['points'] ?? 0;
                            final String id = session['id']?.toString() ?? '';

                            final displayDate = startStr.length > 16
                                ? startStr.substring(0, 16).replaceAll('T', ' ')
                                : startStr;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.history_toggle_off,
                                  color: Colors.blueAccent,
                                ),
                                title: Text('Sesja: +$pts punktów'),
                                subtitle: Text(displayDate),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _deleteSession(id),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
