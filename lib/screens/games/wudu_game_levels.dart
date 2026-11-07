import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import 'game_widgets.dart';

class WuduGameLevels extends StatefulWidget {
  const WuduGameLevels({super.key});

  @override
  State<WuduGameLevels> createState() => _WuduGameLevelsState();
}

class _WuduGameLevelsState extends State<WuduGameLevels> {
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
      _unlockedLevel = prefs.getInt('wudu_unlocked_level') ?? 1;
      _isLoading = false;
    });
  }

  Future<void> _openLevel(int level) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _WuduStepQuestion(level: level)),
    );
    if (completed != true || !mounted) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'game_completed',
        points: 10,
        metadata: {'game_id': 'wudu_steps', 'level': level},
        activityName: 'Wudu Steps level',
      );
    }

    final nextLevel =
        level == _unlockedLevel && _unlockedLevel < _wuduSteps.length
            ? _unlockedLevel + 1
            : _unlockedLevel;
    if (nextLevel != _unlockedLevel) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wudu_unlocked_level', nextLevel);
    }
    if (!mounted) return;
    setState(() => _unlockedLevel = nextLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wudu Steps Game'),
      ),
      body: GameScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wuduSteps.length,
              itemBuilder: (context, index) {
                final level = index + 1;
                final unlocked = level <= _unlockedLevel;
                return GameLevelCard(
                  level: level,
                  title: 'Level $level',
                  subtitle: unlocked
                      ? 'Review ${_wuduSteps[index]}'
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

const List<String> _wuduSteps = [
  'Make Intention (Niyyah)',
  'Say Bismillah',
  'Wash Both Hands',
  'Rinse Mouth',
  'Rinse Nose',
  'Wash Face',
  'Wash Right Arm',
  'Wash Left Arm',
  'Wipe Head',
  'Wipe Ears',
  'Wash Right Foot',
  'Wash Left Foot',
];

class _WuduStepQuestion extends StatefulWidget {
  const _WuduStepQuestion({required this.level});

  final int level;

  @override
  State<_WuduStepQuestion> createState() => _WuduStepQuestionState();
}

class _WuduStepQuestionState extends State<_WuduStepQuestion> {
  late final List<String> _options;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    final correctStep = _wuduSteps[widget.level - 1];
    final distractors =
        _wuduSteps.where((step) => step != correctStep).toList()..shuffle();
    _options = [correctStep, ...distractors.take(3)]..shuffle();
  }

  void _answer(String answer) {
    if (_answered) return;
    if (answer != _wuduSteps[widget.level - 1]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not quite. Try another answer.')),
      );
      return;
    }
    setState(() => _answered = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Correct!'),
        content: Text('Step ${widget.level}: ${_wuduSteps[widget.level - 1]}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wudu Step ${widget.level}')),
      body: GameScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: widget.level / _wuduSteps.length,
                  minHeight: 6,
                ),
                const SizedBox(height: 24),
                Text(
                  'Which action is Step ${widget.level}?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                for (final option in _options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _answer(option),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(option),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
