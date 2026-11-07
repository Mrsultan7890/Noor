import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/names_service.dart';

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load the Names Puzzle: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openLevel(int level) async {
    final name = _names[level - 1];
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _NamesPuzzlePlay(name: name, names: _names),
      ),
    );
    if (completed != true || !mounted) return;

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
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
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
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              unlocked ? Colors.amber : Colors.grey,
                          child: Text('$level'),
                        ),
                        title: Text(_names[index]['transliteration']!),
                        subtitle: Text('Name $level'),
                        trailing: Icon(
                          unlocked ? Icons.play_arrow : Icons.lock,
                        ),
                        onTap: unlocked ? () => _openLevel(level) : null,
                      ),
                    );
                  },
                ),
    );
  }
}

class _NamesPuzzlePlay extends StatefulWidget {
  const _NamesPuzzlePlay({required this.name, required this.names});

  final Map<String, String> name;
  final List<Map<String, String>> names;

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              name['name']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'What is the meaning of ${name['transliteration']}?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            for (final option in _options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _answer(option),
                  child: Text(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
