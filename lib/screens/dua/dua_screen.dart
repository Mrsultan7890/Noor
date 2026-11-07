import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import '../../widgets/arabic_text.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {

  Set<String> _memorizedDuas = {};
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _loadMemorizedDuas();
    _loadLanguage();
  }

  bool get _isUrdu => _language == 'ur';

  Future<void> _loadMemorizedDuas() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _memorizedDuas = (prefs.getStringList('memorized_duas') ?? []).toSet();
    });
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('hadith_dua_language') ?? 'en';
    });
  }

  Future<void> _toggleLanguage() async {
    final language = _isUrdu ? 'en' : 'ur';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hadith_dua_language', language);
    if (!mounted) return;
    setState(() => _language = language);
  }

  Future<void> _toggleMemorized(String duaTitle) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (_memorizedDuas.contains(duaTitle)) {
      _memorizedDuas.remove(duaTitle);
    } else {
      _memorizedDuas.add(duaTitle);
      
      // Award points for memorizing
      if (userProvider.isAuthenticated) {
        await logActivityWithFeedback(
          context: context,
          userProvider: userProvider,
          activityType: 'dua_memorized',
          points: 15,
          metadata: {'dua_title': duaTitle},
          activityName: 'Dua',
        );
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('memorized_duas', _memorizedDuas.toList());
    if (mounted) setState(() {});
  }

  final List<Map<String, String>> duas = const [
    {
      'title': 'Morning Dua',
      'titleUrdu': 'صبح کی دعا',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'transliteration': 'Asbahna wa asbahal mulku lillah',
      'translation': 'We have entered morning and the kingdom belongs to Allah',
      'translationUrdu': 'ہم نے صبح کی اور ساری بادشاہی اللہ ہی کی ہے۔',
      'category': 'Morning'
    },
    {
      'title': 'Evening Dua',
      'titleUrdu': 'شام کی دعا',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'transliteration': 'Amsayna wa amsal mulku lillah',
      'translation': 'We have entered evening and the kingdom belongs to Allah',
      'translationUrdu': 'ہم نے شام کی اور ساری بادشاہی اللہ ہی کی ہے۔',
      'category': 'Evening'
    },
    {
      'title': 'Before Eating',
      'titleUrdu': 'کھانے سے پہلے',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'translation': 'In the name of Allah',
      'translationUrdu': 'اللہ کے نام سے۔',
      'category': 'Daily'
    },
    {
      'title': 'After Eating',
      'titleUrdu': 'کھانے کے بعد',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
      'transliteration': 'Alhamdulillahil ladhi at\'amana wa saqana',
      'translation': 'Praise be to Allah who has fed us and given us drink',
      'translationUrdu': 'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں کھلایا اور پلایا۔',
      'category': 'Daily'
    },
    {
      'title': 'Before Sleeping',
      'titleUrdu': 'سونے سے پہلے',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
      'translationUrdu': 'اے اللہ! تیرے نام کے ساتھ میں مرتا اور زندہ ہوتا ہوں۔',
      'category': 'Daily'
    },
    {
      'title': 'Waking Up',
      'titleUrdu': 'جاگنے کے بعد',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا',
      'transliteration': 'Alhamdulillahil ladhi ahyana ba\'da ma amatana',
      'translation': 'Praise be to Allah who gave us life after death',
      'translationUrdu': 'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں موت (نیند) کے بعد زندگی دی۔',
      'category': 'Morning'
    },
    {
      'title': 'Leaving Home',
      'titleUrdu': 'گھر سے نکلتے وقت',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      'transliteration': 'Bismillah, tawakkaltu \'alallah',
      'translation': 'In the name of Allah, I place my trust in Allah',
      'translationUrdu': 'اللہ کے نام سے، میں نے اللہ پر بھروسا کیا۔',
      'category': 'Travel'
    },
    {
      'title': 'Entering Home',
      'titleUrdu': 'گھر میں داخل ہوتے وقت',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ',
      'transliteration': 'Allahumma inni as\'aluka khayral mawlij',
      'translation': 'O Allah, I ask You for the best entrance',
      'translationUrdu': 'اے اللہ! میں تجھ سے بہترین داخلے کی دعا کرتا ہوں۔',
      'category': 'Daily'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = duas
        .map((dua) => _isUrdu
            ? switch (dua['category']!) {
                'Morning' => 'صبح',
                'Evening' => 'شام',
                'Travel' => 'سفر',
                _ => 'روزمرہ',
              }
            : dua['category']!)
        .toSet()
        .toList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const ArabicLabel('Duas - دعائیں'),
          actions: [
            TextButton(
              onPressed: _toggleLanguage,
              child: Text(_isUrdu ? 'English' : 'اردو'),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: categories
                .map(
                  (category) => Tab(
                    child: Directionality(
                      textDirection:
                          _isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      child: Text(category),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
            final categoryDuas = duas.where((dua) {
              final localizedCategory = _isUrdu
                  ? switch (dua['category']!) {
                      'Morning' => 'صبح',
                      'Evening' => 'شام',
                      'Travel' => 'سفر',
                      _ => 'روزمرہ',
                    }
                  : dua['category'];
              return localizedCategory == category;
            }).toList();
            return ListView.builder(
              itemCount: categoryDuas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final dua = categoryDuas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Directionality(
                                textDirection: _isUrdu
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  _isUrdu
                                      ? dua['titleUrdu']!
                                      : dua['title']!,
                                  textAlign: _isUrdu
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _memorizedDuas.contains(dua['title'])
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _memorizedDuas.contains(dua['title'])
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleMemorized(dua['title']!),
                              tooltip: _isUrdu
                                  ? 'یاد کرنے کا نشان لگائیں'
                                  : 'Mark as memorized',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ArabicText(
                          dua['arabic']!,
                          style: const TextStyle(fontSize: 24, height: 2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dua['transliteration']!,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                        const Divider(height: 24),
                        Directionality(
                          textDirection: _isUrdu
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Text(
                            _isUrdu
                                ? dua['translationUrdu']!
                                : dua['translation']!,
                            textAlign:
                                _isUrdu ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(fontSize: 16, height: 1.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
