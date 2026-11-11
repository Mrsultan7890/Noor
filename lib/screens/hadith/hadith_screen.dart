import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/hadith_service.dart';
import '../../models/hadith_model.dart';
import '../../widgets/arabic_text.dart';
import '../../utils/user_friendly_error.dart';
import '../../widgets/service_loading_view.dart';

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
  String _selectedBook = 'abudawud';
  String _language = 'en';
  int _page = 1;
  bool _hasNextPage = true;

  final Map<String, String> _books = {
    'abudawud': 'Sunan Abu Dawud',
    'bukhari': 'Sahih Bukhari',
    'muslim': 'Sahih Muslim',
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadHadiths();
  }

  bool get _isUrdu => _language == 'ur';

  String _bookTitle(String book) {
    if (!_isUrdu) return _books[book] ?? book;
    return switch (book) {
      'bukhari' => 'صحیح بخاری',
      'muslim' => 'صحیح مسلم',
      _ => 'سنن ابو داؤد',
    };
  }

  Future<void> _loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = preferences.getString('hadith_dua_language') ?? 'en';
    });
  }

  Future<void> _toggleLanguage() async {
    final language = _isUrdu ? 'en' : 'ur';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('hadith_dua_language', language);
    if (!mounted) return;
    setState(() => _language = language);
  }

  Future<void> _loadHadiths() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hadiths = await _service.getHadiths(_selectedBook, _page);
      if (!mounted) return;
      setState(() {
        _hadiths = hadiths;
        _hasNextPage = hadiths.length == HadithService.pageSize;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Could not load hadith: $e\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = UserFriendlyError.content(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArabicLabel('Hadith - حدیث'),
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(_isUrdu ? 'English' : 'اردو'),
          ),
          PopupMenuButton<String>(
            onSelected: (book) {
              setState(() {
                _selectedBook = book;
                _page = 1;
                _hasNextPage = true;
              });
              _loadHadiths();
            },
            itemBuilder: (context) => _books.keys
                .map(
                  (book) => PopupMenuItem(
                    value: book,
                    child: Directionality(
                      textDirection:
                          _isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      child: Text(_bookTitle(book)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const ServiceLoadingView(
              serviceName: 'Hadith',
              icon: Icons.menu_book_outlined,
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHadiths,
                        child: Text(_isUrdu ? 'دوبارہ کوشش کریں' : 'Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _hadiths.isEmpty
                          ? Center(
                              child: Text(
                                _isUrdu
                                    ? 'اس کتاب میں مزید احادیث نہیں ہیں۔'
                                    : 'No more hadiths are available in this book.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: _hadiths.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final hadith = _hadiths[index];
                                final translation = _isUrdu
                                    ? hadith.urduText
                                    : hadith.englishText;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Directionality(
                                            textDirection: _isUrdu
                                                ? TextDirection.rtl
                                                : TextDirection.ltr,
                                            child: Text(
                                              '${_bookTitle(_selectedBook)} - ${hadith.hadithNumber}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: ArabicText(
                                            hadith.arabicText,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              height: 2,
                                            ),
                                          ),
                                        ),
                                        const Divider(height: 32),
                                        Directionality(
                                          textDirection: _isUrdu
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          child: Text(
                                            translation.isEmpty
                                                ? (_isUrdu
                                                    ? 'اس حدیث کا اردو ترجمہ دستیاب نہیں۔'
                                                    : 'English translation unavailable.')
                                                : translation,
                                            textAlign: _isUrdu
                                                ? TextAlign.right
                                                : TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              height: 1.8,
                                            ),
                                          ),
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
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: _page > 1
                                  ? () {
                                      setState(() => _page--);
                                      _loadHadiths();
                                    }
                                  : null,
                              child: Text(
                                _isUrdu ? 'پچھلا صفحہ' : 'Previous',
                              ),
                            ),
                            Text(
                              _isUrdu ? 'صفحہ $_page' : 'Page $_page',
                            ),
                            OutlinedButton(
                              onPressed: _hasNextPage
                                  ? () {
                                      setState(() => _page++);
                                      _loadHadiths();
                                    }
                                  : null,
                              child: Text(_isUrdu ? 'اگلا صفحہ' : 'Next'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
