import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MushafQuranScreen extends StatefulWidget {
  const MushafQuranScreen({super.key});

  @override
  State<MushafQuranScreen> createState() => _MushafQuranScreenState();
}

class _MushafQuranScreenState extends State<MushafQuranScreen> {
  int _currentPage = 1;
  List<String> _lines = [];
  bool _isLoading = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('mushaf_last_page') ?? 1;
    setState(() => _currentPage = lastPage);
    _loadPage(lastPage);
    if (lastPage > 1) {
      _pageController.jumpToPage(lastPage - 1);
    }
  }

  Future<void> _saveLastRead(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mushaf_last_page', page);
  }

  Future<void> _loadPage(int page) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        setState(() {
          _lines = ayahs.map((a) => a['text'].toString()).toList();
          _currentPage = page;
          _isLoading = false;
        });
        _saveLastRead(page);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                  if (page >= 1 && page <= 604) {
                    _loadPage(page);
                  }
                },
                itemCount: 604,
                itemBuilder: (context, index) {
                  if (index + 1 != _currentPage) {
                    return const SizedBox();
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            children: _lines.map((line) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  line,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: 2,
                                    fontFamily: 'Amiri',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Page $_currentPage',
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
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage > 1
                  ? () {
                      _pageController.jumpToPage(0);
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 32,
              onPressed: _currentPage > 1
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),
            Text(
              '$_currentPage / 604',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 32,
              onPressed: _currentPage < 604
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < 604
                  ? () {
                      _pageController.jumpToPage(603);
                    }
                  : null,
            ),
          ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
