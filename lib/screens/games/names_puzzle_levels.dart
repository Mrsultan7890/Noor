import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../services/names_service.dart';
import '../../utils/activity_feedback.dart';
import '../../widgets/arabic_text.dart';
import 'game_widgets.dart';
import '../../utils/user_friendly_error.dart';

class NamesPuzzleLevels extends StatefulWidget {
  const NamesPuzzleLevels({super.key});

  @override
  State<NamesPuzzleLevels> createState() => _NamesPuzzleLevelsState();
}

class _NamesPuzzleLevelsState extends State<NamesPuzzleLevels> {
  final NamesService _namesService = NamesService();
  List<Map<String, String>> _names = [];
  int _unlockedLevel = 1;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final names = await _namesService.get99Names();
      if (names.length != 99) {
        throw StateError('Expected 99 names but received ${names.length}.');
      }
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _names = names;
        _unlockedLevel = prefs.getInt('names_puzzle_unlocked_level') ?? 1;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Could not load the Names Puzzle: $e\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = UserFriendlyError.content(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _openLevel(int level) async {
    final name = _names[level - 1];
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _NamesPuzzlePlay(
          name: name,
          names: _names,
          level: level,
        ),
      ),
    );
    if (completed != true || !mounted) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'game_completed',
        points: 10,
        metadata: {'game_id': 'names_puzzle', 'level': level},
        activityName: '99 Names Puzzle level',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final nextLevel = level == _unlockedLevel && _unlockedLevel < 99
        ? _unlockedLevel + 1
        : _unlockedLevel;
    if (nextLevel != _unlockedLevel) {
      await prefs.setInt('names_puzzle_unlocked_level', nextLevel);
    }
    if (!mounted) return;
    setState(() => _unlockedLevel = nextLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names Puzzle'),
      ),
      body: GameScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _names.length,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final unlocked = level <= _unlockedLevel;
                      final name = _names[index];
                      return GameLevelCard(
                        level: level,
                        title: name['transliteration']!,
                        subtitle: 'Name $level',
                        unlocked: unlocked,
                        onTap: unlocked ? () => _openLevel(level) : null,
                      );
                    },
                  ),
      ),
    );
  }
}

class _NamesPuzzlePlay extends StatefulWidget {
  const _NamesPuzzlePlay({
    required this.name,
    required this.names,
    required this.level,
  });

  final Map<String, String> name;
  final List<Map<String, String>> names;
  final int level;

  @override
  State<_NamesPuzzlePlay> createState() => _NamesPuzzlePlayState();
}

class _NamesPuzzlePlayState extends State<_NamesPuzzlePlay> {
  late final List<String> _options;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    final correctMeaning = widget.name['meaning']!;
    final distractors = widget.names
        .map((name) => name['meaning']!)
        .where((meaning) => meaning != correctMeaning)
        .toSet()
        .toList();
    distractors.shuffle();
    _options = [correctMeaning, ...distractors.take(3)]..shuffle();
  }

  void _answer(String answer) {
    if (_answered) return;
    if (answer != widget.name['meaning']) {
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
        content: Text('${widget.name['transliteration']} — $answer'),
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
    final name = widget.name;
    return Scaffold(
      appBar: AppBar(title: const Text('99 Names Puzzle')),
      body: GameScreenBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              LinearProgressIndicator(value: widget.level / 99, minHeight: 6),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Name ${widget.level} of 99',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      ArabicText(
                        name['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 44, height: 1.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What is the meaning of ${name['transliteration']}?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
    );
  }
}
