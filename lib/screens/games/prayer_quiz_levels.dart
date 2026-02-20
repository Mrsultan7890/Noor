import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_quiz_play.dart';

class PrayerQuizLevels extends StatefulWidget {
  const PrayerQuizLevels({super.key});

  @override
  State<PrayerQuizLevels> createState() => _PrayerQuizLevelsState();
}

class _PrayerQuizLevelsState extends State<PrayerQuizLevels> {
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _unlockedLevel = prefs.getInt('prayer_unlocked_level') ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Quiz Levels'), backgroundColor: Colors.orange),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.red.shade50]),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 50,
          itemBuilder: (context, index) {
            final level = index + 1;
            final isUnlocked = level <= _unlockedLevel;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: level % 2 == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: isUnlocked
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PrayerQuizPlay(level: level)),
                            );
                            if (result == true && level == _unlockedLevel) {
                              setState(() => _unlockedLevel++);
                              SharedPreferences.getInstance().then((p) => p.setInt('prayer_unlocked_level', _unlockedLevel));
                            }
                          }
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isUnlocked ? [Colors.orange, Colors.red] : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        boxShadow: [BoxShadow(color: isUnlocked ? Colors.orange.withOpacity(0.5) : Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: Center(
                        child: Text('$level', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
