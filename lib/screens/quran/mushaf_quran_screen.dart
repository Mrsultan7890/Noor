import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/utf8_json.dart';
import '../../widgets/arabic_text.dart';

class MushafQuranScreen extends StatefulWidget {
  const MushafQuranScreen({super.key});

  @override
  State<MushafQuranScreen> createState() => _MushafQuranScreenState();
}

class _MushafQuranScreenState extends State<MushafQuranScreen> {
  int _currentPage = 1;
  final Map<int, List<String>> _cachedPages = {};
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final lastPage = (prefs.getInt('mushaf_last_page') ?? 1).clamp(1, 604);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageController.jumpToPage(lastPage - 1);
      setState(() => _currentPage = lastPage);
    });
  }

  Future<void> _saveLastRead(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mushaf_last_page', page);
  }

  Future<List<String>> _loadPage(int page) async {
    if (_cachedPages.containsKey(page)) {
      return _cachedPages[page]!;
    }

    final response = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Mushaf page $page (HTTP ${response.statusCode}).',
      );
    }
    final data = decodeUtf8JsonResponse(response);
    final ayahs = data['data']['ayahs'] as List;
    final lines = ayahs.map((a) => a['text'].toString()).toList();
    _cachedPages[page] = lines;
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mushaf - Page $_currentPage/604'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showPageSelector,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade50, Colors.amber.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            final page = index + 1;
            setState(() => _currentPage = page);
            _saveLastRead(page);
          },
          itemCount: 604,
          itemBuilder: (context, index) {
            final page = index + 1;
            return FutureBuilder<List<String>>(
              future: _loadPage(page),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load this Mushaf page: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFF1E293B)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lines = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: lines.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: ArabicText(
                                  lines[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 2.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Page $page',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: IconTheme(
          data: const IconThemeData(color: Color(0xFF1E293B)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 1
                    ? () => _pageController.jumpToPage(0)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 32,
                onPressed: _currentPage > 1
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
              Text(
                '$_currentPage / 604',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 32,
                onPressed: _currentPage < 604
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < 604
                    ? () => _pageController.jumpToPage(603)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPageSelector() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Page Number (1-604)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= 604) {
                _pageController.jumpToPage(page - 1);
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
