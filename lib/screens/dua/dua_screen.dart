import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../services/dua_content_service.dart';
import '../../utils/activity_feedback.dart';
import '../../widgets/arabic_text.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  Set<String> _memorizedDuas = {};
  List<DuaCatalogItem> _remoteDuas = [];
  String _language = 'en';
  bool _catalogOffline = false;

  @override
  void initState() {
    super.initState();
    _loadMemorizedDuas();
    _loadLanguage();
    _loadRemoteDuas();
  }

  bool get _isUrdu => _language == 'ur';

  List<Map<String, String>> get _allDuas => [
        ...duas,
        ..._remoteDuas.map((dua) => dua.toScreenMap()),
      ];

  String _localizedCategory(String category) {
    if (!_isUrdu) return category;
    return switch (category) {
      'Morning' => 'صبح',
      'Evening' => 'شام',
      'Travel' => 'سفر',
      'Home' => 'گھر',
      'Sleep' => 'نیند',
      'Meals' => 'کھانا',
      'Daily' => 'روزمرہ',
      _ => 'روزمرہ',
    };
  }

  String _memorizedKey(Map<String, String> dua) => dua['id'] ?? dua['title']!;

  Future<void> _loadRemoteDuas() async {
    try {
      final catalog = await DuaContentService().load();
      if (!mounted) return;
      setState(() {
        _remoteDuas = catalog.items;
        _catalogOffline = catalog.isOffline;
      });
    } on FormatException catch (error) {
      debugPrint('Unable to read the dua catalog: $error');
      if (mounted) setState(() => _catalogOffline = true);
    }
  }

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

  Future<void> _toggleMemorized(String duaKey, String duaTitle) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_memorizedDuas.contains(duaKey)) {
      _memorizedDuas.remove(duaKey);
    } else {
      _memorizedDuas.add(duaKey);

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
      'arabic':
          'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ',
      'transliteration':
          'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namut',
      'translation':
          'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening; by Your leave we live and by Your leave we die.',
      'translationUrdu':
          'اے اللہ! تیرے ہی حکم سے ہم نے صبح کی، تیرے ہی حکم سے شام کرتے ہیں، تیرے ہی حکم سے جیتے ہیں اور تیرے ہی حکم سے مرتے ہیں۔',
      'source': 'Sunan Ibn Majah 3868',
      'category': 'Morning'
    },
    {
      'title': 'Evening Dua',
      'titleUrdu': 'شام کی دعا',
      'arabic':
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ أَسْأَلُكَ خَيْرَ هَٰذِهِ اللَّيْلَةِ، وَأَعُوذُ بِكَ مِنْ شَرِّ هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      'transliteration':
          'Amsayna wa amsal-mulku lillahi walhamdu lillah. La ilaha illallahu wahdahu la sharika lah. Lahul-mulku wa lahul-hamdu wa huwa ala kulli shay’in qadir. Allahumma as’aluka khayra hadhihil-laylati, wa a’udhu bika min sharri hadhihil-laylati wa sharri ma ba’daha. Allahumma inni a’udhu bika minal-kasali wa su’il-kibar. Allahumma inni a’udhu bika min adhabi fin-nari wa adhabi fil-qabr.',
      'translation':
          'We have entered the evening, and all dominion and praise belong to Allah. There is no god worthy of worship except Allah alone, without partner. His is the dominion and praise, and He has power over all things. O Allah, I ask You for the good of this night and seek refuge in You from its evil and the evil that follows it. O Allah, I seek refuge in You from laziness, the weakness of old age, and the punishment of the Fire and the grave.',
      'translationUrdu':
          'ہم نے شام کی اور تمام بادشاہی اور تعریف اللہ ہی کے لیے ہے۔ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کی بادشاہی اور اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے۔ اے اللہ! میں تجھ سے اس رات کی بھلائی مانگتا ہوں اور اس کے شر اور اس کے بعد کے شر سے تیری پناہ چاہتا ہوں۔ اے اللہ! میں سستی، بڑھاپے کی کمزوری، جہنم کے عذاب اور قبر کے عذاب سے تیری پناہ چاہتا ہوں۔',
      'source': 'Sahih Muslim 2723a',
      'category': 'Evening'
    },
    {
      'title': 'Before Eating',
      'titleUrdu': 'کھانے سے پہلے',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'translation': 'In the name of Allah',
      'translationUrdu': 'اللہ کے نام سے۔',
      'source': 'Sahih al-Bukhari 5376',
      'category': 'Daily'
    },
    {
      'title': 'After Eating',
      'titleUrdu': 'کھانے کے بعد',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا الطَّعَامَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      'transliteration':
          'Alhamdu lillahil-ladhi at’amani hadha at-ta’ama wa razaqanihi min ghayri hawlin minni wa la quwwah',
      'translation':
          'All praise is for Allah, who fed me this food and provided it for me without any power or strength on my part.',
      'translationUrdu':
          'تمام تعریف اللہ کے لیے ہے جس نے مجھے یہ کھانا کھلایا اور میری کسی قوت و طاقت کے بغیر مجھے یہ رزق عطا فرمایا۔',
      'source': 'Sunan Abi Dawud 4023',
      'category': 'Daily'
    },
    {
      'title': 'Before Sleeping',
      'titleUrdu': 'سونے سے پہلے',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
      'translationUrdu':
          'اے اللہ! تیرے نام کے ساتھ میں مرتا اور زندہ ہوتا ہوں۔',
      'source': 'Sahih al-Bukhari 6312',
      'category': 'Daily'
    },
    {
      'title': 'Waking Up',
      'titleUrdu': 'جاگنے کے بعد',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'transliteration':
          'Alhamdu lillahil-ladhi ahyana ba’da ma amatana wa ilayhin-nushur',
      'translation':
          'All praise is for Allah, who gave us life after causing us to die, and to Him is the resurrection.',
      'translationUrdu':
          'تمام تعریف اللہ کے لیے ہے جس نے ہمیں موت جیسی نیند کے بعد زندگی دی، اور اسی کی طرف دوبارہ اٹھ کر جانا ہے۔',
      'source': 'Sahih al-Bukhari 6312',
      'category': 'Morning'
    },
    {
      'title': 'Leaving Home',
      'titleUrdu': 'گھر سے نکلتے وقت',
      'arabic':
          'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration':
          'Bismillahi tawakkaltu alallahi, la hawla wa la quwwata illa billah',
      'translation':
          'In the name of Allah; I place my trust in Allah. There is no power and no strength except through Allah.',
      'translationUrdu':
          'اللہ کے نام سے، میں نے اللہ پر بھروسا کیا۔ اللہ کے سوا نہ کسی میں طاقت ہے نہ قوت۔',
      'source': 'Jami` at-Tirmidhi 3426 (grading differs among scholars)',
      'category': 'Travel'
    },
    {
      'title': 'Entering Home',
      'titleUrdu': 'گھر میں داخل ہوتے وقت',
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ، بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
      'transliteration':
          'Allahumma inni as’aluka khayral-mawliji wa khayral-makhraji. Bismillahi walajna, wa bismillahi kharajna, wa alallahi rabbina tawakkalna.',
      'translation':
          'O Allah, I ask You for the good of entering and the good of leaving. In the name of Allah we enter, in the name of Allah we leave, and in Allah, our Lord, we place our trust.',
      'translationUrdu':
          'اے اللہ! میں تجھ سے داخل ہونے اور نکلنے کی بھلائی مانگتا ہوں۔ اللہ کے نام سے ہم داخل ہوئے، اللہ کے نام سے ہم نکلے، اور اپنے رب اللہ ہی پر ہم نے بھروسا کیا۔',
      'source': 'Sunan Abi Dawud 5096 (graded weak by al-Albani)',
      'category': 'Daily'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = _allDuas
        .map((dua) => _localizedCategory(dua['category']!))
        .toSet()
        .toList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const ArabicLabel('Duas - دعائیں'),
          actions: [
            IconButton(
              onPressed: _loadRemoteDuas,
              icon: const Icon(Icons.refresh),
              tooltip: _isUrdu ? 'دعائیں تازہ کریں' : 'Refresh duas',
            ),
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
            final categoryDuas = _allDuas
                .where(
                    (dua) => _localizedCategory(dua['category']!) == category)
                .toList();
            return ListView.builder(
              itemCount: categoryDuas.length + (_catalogOffline ? 1 : 0),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (_catalogOffline && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _isUrdu
                          ? 'آف لائن ہیں؛ محفوظ شدہ دعائیں دکھائی جا رہی ہیں۔'
                          : 'Offline: showing saved duas and built-in content.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final dua = categoryDuas[index - (_catalogOffline ? 1 : 0)];
                final memorizedKey = _memorizedKey(dua);
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
                                  _isUrdu ? dua['titleUrdu']! : dua['title']!,
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
                                _memorizedDuas.contains(memorizedKey)
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _memorizedDuas.contains(memorizedKey)
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () =>
                                  _toggleMemorized(memorizedKey, dua['title']!),
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
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Source: ${dua['source']!}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Divider(height: 24),
                        Directionality(
                          textDirection:
                              _isUrdu ? TextDirection.rtl : TextDirection.ltr,
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
