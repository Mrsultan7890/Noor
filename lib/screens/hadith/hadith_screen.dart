import 'package:flutter/material.dart';
import '../../services/hadith_service.dart';
import '../../models/hadith_model.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final HadithService _service = HadithService();
  List<Hadith> _hadiths = [];
  bool _isLoading = false;
  String? _error;
  String _selectedBook = 'bukhari';

  final Map<String, String> _books = {
    'bukhari': 'Sahih Bukhari',
    'muslim': 'Sahih Muslim',
    'abu-dawud': 'Abu Dawood',
  };

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hadiths = await _service.getHadiths(_selectedBook, 1);
      setState(() {
        _hadiths = hadiths;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith - حدیث'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (book) {
              setState(() => _selectedBook = book);
              _loadHadiths();
            },
            itemBuilder: (context) => _books.entries
                .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadHadiths, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _hadiths.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final hadith = _hadiths[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_books[_selectedBook]} - ${hadith.hadithNumber}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hadith.arabicText,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 20, height: 2),
                            ),
                            const Divider(height: 32),
                            Text(
                              hadith.englishText,
                              style: const TextStyle(fontSize: 16, height: 1.8),
                            ),
                            if (hadith.narrator.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Narrator: ${hadith.narrator}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
