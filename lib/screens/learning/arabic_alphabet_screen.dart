import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/arabic_alphabet_model.dart';
import '../../providers/user_provider.dart';
import 'dart:math';

class ArabicAlphabetScreen extends StatefulWidget {
  const ArabicAlphabetScreen({super.key});

  @override
  State<ArabicAlphabetScreen> createState() => _ArabicAlphabetScreenState();
}

class _ArabicAlphabetScreenState extends State<ArabicAlphabetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Arabic'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Letters', icon: Icon(Icons.abc)),
            Tab(text: 'Harakat', icon: Icon(Icons.format_size)),
            Tab(text: 'Quiz', icon: Icon(Icons.quiz)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LettersTab(),
          _HarakatTab(),
          _QuizTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _LettersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ArabicAlphabetData.letters.length,
      itemBuilder: (context, index) {
        final letter = ArabicAlphabetData.letters[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () => _showLetterDetails(context, letter),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    letter.arabic,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    letter.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    letter.transliteration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLetterDetails(BuildContext context, ArabicLetter letter) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                letter.arabic,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                letter.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pronunciation: ${letter.pronunciation}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Examples:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...letter.examples.map((example) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  example,
                  style: const TextStyle(fontSize: 24),
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarakatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ArabicAlphabetData.harakat.length,
      itemBuilder: (context, index) {
        final harakat = ArabicAlphabetData.harakat[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      harakat.example,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        harakat.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        harakat.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sound: ${harakat.sound}',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuizTab extends StatefulWidget {
  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> {
  final Random _random = Random();
  ArabicLetter? _currentLetter;
  List<String> _options = [];
  int _score = 0;
  int _totalQuestions = 0;
  String? _selectedAnswer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final letters = ArabicAlphabetData.letters;
    _currentLetter = letters[_random.nextInt(letters.length)];
    
    final wrongOptions = letters
        .where((l) => l.name != _currentLetter!.name)
        .toList()
      ..shuffle();
    
    _options = [
      _currentLetter!.name,
      wrongOptions[0].name,
      wrongOptions[1].name,
      wrongOptions[2].name,
    ]..shuffle();
    
    _selectedAnswer = null;
    _showResult = false;
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _totalQuestions++;
      if (answer == _currentLetter!.name) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _generateQuestion();
    });
  }

  void _resetQuiz() {
    // Award points if score is good
    if (_totalQuestions >= 10 && _score >= 7) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        userProvider.logActivity(
          activityType: 'lesson_completed',
          points: 20,
          metadata: {
            'lesson': 'Arabic Alphabet Quiz',
            'score': _score,
            'total': _totalQuestions,
            'accuracy': ((_score / _totalQuestions) * 100).toStringAsFixed(0),
          },
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz completed! +20 points'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    
    setState(() {
      _score = 0;
      _totalQuestions = 0;
      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLetter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_score / $_totalQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _totalQuestions > 0
                            ? '${((_score / _totalQuestions) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'What is this letter?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _currentLetter!.arabic,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isCorrect = option == _currentLetter!.name;
                final isSelected = option == _selectedAnswer;
                
                Color? backgroundColor;
                if (_showResult && isSelected) {
                  backgroundColor = isCorrect ? Colors.green : Colors.red;
                } else if (_showResult && isCorrect) {
                  backgroundColor = Colors.green;
                }
                
                return ElevatedButton(
                  onPressed: _showResult ? null : () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: _showResult ? Colors.white : null,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showResult ? _nextQuestion : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
