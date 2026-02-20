import 'package:flutter/material.dart';
import 'dart:math';

class PrayerQuizPlay extends StatefulWidget {
  final int level;
  const PrayerQuizPlay({super.key, required this.level});

  @override
  State<PrayerQuizPlay> createState() => _PrayerQuizPlayState();
}

class _PrayerQuizPlayState extends State<PrayerQuizPlay> {
  final List<Map<String, dynamic>> _questions = [
    {'q': 'First prayer of the day?', 'a': 'Fajr', 'o': ['Fajr', 'Dhuhr', 'Asr', 'Maghrib']},
    {'q': 'Prayer after sunset?', 'a': 'Maghrib', 'o': ['Fajr', 'Maghrib', 'Isha', 'Dhuhr']},
    {'q': 'Last prayer of the day?', 'a': 'Isha', 'o': ['Isha', 'Maghrib', 'Asr', 'Fajr']},
    {'q': 'Afternoon prayer?', 'a': 'Asr', 'o': ['Asr', 'Dhuhr', 'Fajr', 'Maghrib']},
    {'q': 'Midday prayer?', 'a': 'Dhuhr', 'o': ['Dhuhr', 'Asr', 'Fajr', 'Isha']},
  ];

  int _currentQ = 0;
  int _score = 0;

  void _answer(String ans) {
    if (ans == _questions[_currentQ]['a']) {
      _score++;
    }
    
    if (_currentQ < _questions.length - 1) {
      setState(() => _currentQ++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final stars = _score == 5 ? 3 : _score >= 3 ? 2 : 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.yellow, size: 40)),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score/5', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context, true); }, child: const Text('Next')),
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _currentQ = 0; _score = 0; }); }, child: const Text('Retry')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQ];
    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.level}'), backgroundColor: Colors.orange),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.red.shade50])),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Question ${_currentQ + 1}/5', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Text(q['q'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 48),
            ...(q['o'] as List).map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _answer(opt),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.orange,
                ),
                child: Text(opt, style: const TextStyle(fontSize: 20)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
