import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import 'game_widgets.dart';
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
    if (!mounted) return;
    setState(() {
      _unlockedLevel = prefs.getInt('memory_unlocked_level') ?? 1;
      for (var level = 1; level <= 50; level++) {
        _starsByLevel[level] = prefs.getInt('memory_stars_$level') ?? 0;
      }
    });
  }

  Future<void> _openLevel(int level) async {
    final stars = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => MemoryGamePlay(level: level)),
    );
    if (stars == null || !mounted) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'game_completed',
        points: 10,
        metadata: {'game_id': 'memory_match', 'level': level, 'stars': stars},
        activityName: 'Memory Match level',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final bestStars = stars > (_starsByLevel[level] ?? 0)
        ? stars
        : (_starsByLevel[level] ?? 0);
    await prefs.setInt('memory_stars_$level', bestStars);
    final nextLevel = level == _unlockedLevel && _unlockedLevel < 50
        ? _unlockedLevel + 1
        : _unlockedLevel;
    if (nextLevel != _unlockedLevel) {
      await prefs.setInt('memory_unlocked_level', nextLevel);
    }
    if (!mounted) return;
    setState(() {
      _starsByLevel[level] = bestStars;
      _unlockedLevel = nextLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: GameScreenBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 50,
          itemBuilder: (context, index) {
            final level = index + 1;
            final unlocked = level <= _unlockedLevel;
            return GameLevelCard(
              level: level,
              title: 'Level $level',
              subtitle: unlocked
                  ? 'Match the Arabic letters'
                  : 'Complete earlier levels to unlock',
              unlocked: unlocked,
              stars: _starsByLevel[level] ?? 0,
              onTap: unlocked ? () => _openLevel(level) : null,
            );
          },
        ),
      ),
    );
  }
}
