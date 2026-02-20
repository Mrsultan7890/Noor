import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryGamePlay extends StatefulWidget {
  final int level;
  const MemoryGamePlay({super.key, required this.level});

  @override
  State<MemoryGamePlay> createState() => _MemoryGamePlayState();
}

class _MemoryGamePlayState extends State<MemoryGamePlay> with TickerProviderStateMixin {
  List<String> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstIndex;
  int _moves = 0;
  int _matches = 0;
  bool _isChecking = false;

  final List<String> _arabicWords = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
    'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
    'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي'
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final pairs = _getPairsCount();
    final selected = (_arabicWords..shuffle()).take(pairs).toList();
    _cards = [...selected, ...selected]..shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _moves = 0;
    _matches = 0;
    _firstIndex = null;
  }

  int _getPairsCount() {
    if (widget.level <= 5) return 4;
    if (widget.level <= 10) return 6;
    if (widget.level <= 20) return 8;
    if (widget.level <= 30) return 10;
    return 12;
  }

  void _onCardTap(int index) {
    if (_isChecking || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _isChecking = true;
      _moves++;

      if (_cards[_firstIndex!] == _cards[index]) {
        setState(() {
          _matched[_firstIndex!] = true;
          _matched[index] = true;
          _matches++;
        });
        _firstIndex = null;
        _isChecking = false;

        if (_matches == _getPairsCount()) {
          _showWinDialog();
        }
      } else {
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            _flipped[_firstIndex!] = false;
            _flipped[index] = false;
            _firstIndex = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    final stars = _moves <= _getPairsCount() * 2 ? 3 : _moves <= _getPairsCount() * 3 ? 2 : 1;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(
                i < stars ? Icons.star : Icons.star_border,
                color: Colors.yellow,
                size: 40,
              )),
            ),
            const SizedBox(height: 16),
            Text('Moves: $_moves', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Next Level'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initGame());
            },
            child: const Text('Replay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.pink,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Moves: $_moves', style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getPairsCount() <= 6 ? 3 : 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: _matched[index]
                        ? [Colors.green, Colors.green.shade700]
                        : _flipped[index]
                            ? [Colors.white, Colors.grey.shade100]
                            : [Colors.pink, Colors.purple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _flipped[index] || _matched[index]
                      ? Text(
                          _cards[index],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      : const Icon(Icons.question_mark, size: 48, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
