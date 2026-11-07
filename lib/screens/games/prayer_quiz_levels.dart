import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import 'game_widgets.dart';
import 'prayer_quiz_play.dart';

class PrayerQuizLevels extends StatefulWidget {
  const PrayerQuizLevels({super.key});

  @override
  State<PrayerQuizLevels> createState() => _PrayerQuizLevelsState();
}

class _PrayerQuizLevelsState extends State<PrayerQuizLevels> {
  int _unlockedLevel = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _unlockedLevel = prefs.getInt('prayer_unlocked_level') ?? 1;
      _isLoading = false;
    });
  }

  Future<void> _openLevel(int level) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PrayerQuizPlay(level: level)),
    );
    if (completed != true || !mounted) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'game_completed',
        points: 10,
        metadata: {'game_id': 'prayer_quiz', 'level': level},
        activityName: 'Prayer Quiz level',
      );
    }

    final nextLevel = level == _unlockedLevel && _unlockedLevel < 50
        ? _unlockedLevel + 1
        : _unlockedLevel;
    if (nextLevel != _unlockedLevel) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('prayer_unlocked_level', nextLevel);
    }
    if (!mounted) return;
    setState(() => _unlockedLevel = nextLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Quiz')),
      body: GameScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 50,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final unlocked = level <= _unlockedLevel;
                  return GameLevelCard(
                    level: level,
                    title: 'Level $level',
                    subtitle: unlocked
                        ? 'Test your prayer knowledge'
                        : 'Complete earlier levels to unlock',
                    unlocked: unlocked,
                    onTap: unlocked ? () => _openLevel(level) : null,
                  );
                },
              ),
      ),
    );
  }
}
