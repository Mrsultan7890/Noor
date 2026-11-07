import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_game_play.dart';

class MemoryGameLevels extends StatefulWidget {
  const MemoryGameLevels({super.key});

  @override
  State<MemoryGameLevels> createState() => _MemoryGameLevelsState();
}

class _MemoryGameLevelsState extends State<MemoryGameLevels> {
  int _unlockedLevel = 1;
  final Map<int, int> _starsByLevel = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final starsByLevel = <int, int>{
      for (var level = 1; level <= 50; level++)
        level: prefs.getInt('memory_stars_$level') ?? 0,
    };
    if (!mounted) return;
    setState(() {
      _unlockedLevel = prefs.getInt('memory_unlocked_level') ?? 1;
      _starsByLevel.addAll(starsByLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match Levels'),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 50,
          itemBuilder: (context, index) {
            final level = index + 1;
            final isUnlocked = level <= _unlockedLevel;
            final stars = _getStars(level);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: level % 2 == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: isUnlocked
                        ? () async {
                            final stars = await Navigator.push<int>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryGamePlay(level: level),
                              ),
                            );
                            if (stars != null) {
                              final prefs = await SharedPreferences.getInstance();
                              final bestStars = stars > (_starsByLevel[level] ?? 0)
                                  ? stars
                                  : (_starsByLevel[level] ?? 0);
                              await prefs.setInt('memory_stars_$level', bestStars);
                              final unlockedLevel = level == _unlockedLevel &&
                                      _unlockedLevel < 50
                                  ? _unlockedLevel + 1
                                  : _unlockedLevel;
                              if (unlockedLevel != _unlockedLevel) {
                                await prefs.setInt(
                                  'memory_unlocked_level',
                                  unlockedLevel,
                                );
                              }
                              if (!mounted) return;
                              setState(() {
                                _starsByLevel[level] = bestStars;
                                _unlockedLevel = unlockedLevel;
                              });
                            }
                          }
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isUnlocked
                              ? [Colors.pink, Colors.purple]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUnlocked ? Colors.pink.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$level',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isUnlocked && stars > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => Icon(
                                  i < stars ? Icons.star : Icons.star_border,
                                  color: Colors.yellow,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }

  int _getStars(int level) {
    return _starsByLevel[level] ?? 0;
  }
}
