import 'package:flutter/material.dart';
import '../../services/dua_content_service.dart';
import '../../widgets/arabic_text.dart';

class DailyAdhkarScreen extends StatefulWidget {
  const DailyAdhkarScreen({super.key});

  @override
  State<DailyAdhkarScreen> createState() => _DailyAdhkarScreenState();
}

class _DailyAdhkarScreenState extends State<DailyAdhkarScreen> {
  List<DuaCatalogItem> _remoteDuas = [];
  bool _catalogOffline = false;

  @override
  void initState() {
    super.initState();
    _loadRemoteDuas();
  }

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Adhkar'),
          actions: [
            IconButton(
              onPressed: _loadRemoteDuas,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh duas',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Morning'),
              Tab(text: 'Evening'),
              Tab(text: 'Meals'),
              Tab(text: 'Home'),
              Tab(text: 'Sleep'),
              Tab(text: 'Travel'),
              Tab(text: 'Daily'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDuaList(_duasForCategory('Morning', _morningAdhkar)),
            _buildDuaList(_duasForCategory('Evening', _eveningAdhkar)),
            _buildDuaList(_duasForCategory('Meals', _mealsAdhkar)),
            _buildDuaList(_duasForCategory('Home', _homeAdhkar)),
            _buildDuaList(_duasForCategory('Sleep', _sleepAdhkar)),
            _buildDuaList(_duasForCategory('Travel', _travelAdhkar)),
            _buildDuaList(_duasForCategory('Daily', const [])),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _duasForCategory(
    String category,
    List<Map<String, String>> builtInDuas,
  ) {
    final remote = _remoteDuas
        .where((dua) => dua.category == category)
        .map((dua) => dua.toScreenMap());
    return [...builtInDuas, ...remote];
  }

  Widget _buildDuaList(List<Map<String, String>> duas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length + (_catalogOffline ? 1 : 0),
      itemBuilder: (context, index) {
        if (_catalogOffline && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Offline: showing saved duas and built-in content.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final dua = duas[index - (_catalogOffline ? 1 : 0)];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dua['title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ArabicText(
                    dua['arabic']!,
                    style: const TextStyle(fontSize: 22, height: 2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dua['transliteration']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua['translation']!,
                  style: const TextStyle(fontSize: 14),
                ),
                if (dua['source'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Source: ${dua['source']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (dua['repeat'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[900]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Repeat: ${dua['repeat']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static const Map<String, String> _ayatAlKursi = {
    'title': 'Ayat al-Kursi (Al-Baqarah 2:255)',
    'arabic':
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'transliteration':
        'Allahu la ilaha illa huwa al-hayyul-qayyum. La ta’khudhuhu sinatun wa la nawm. Lahu ma fis-samawati wa ma fil-ard. Man dhal-ladhi yashfa’u indahu illa bi-idhnih. Ya’lamu ma bayna aydihim wa ma khalfahum. Wa la yuhituna bi-shay’in min ilmihi illa bima sha’. Wasi’a kursiyyuhus-samawati wal-ard. Wa la ya’uduhu hifdhuhuma wa huwal-aliyyul-adhim.',
    'translation':
        'Allah—there is no god worthy of worship except Him, the Ever-Living, the Sustainer of all. Neither drowsiness nor sleep overtakes Him. To Him belongs whatever is in the heavens and the earth. Who can intercede with Him except by His permission? He knows what is before them and what is behind them, and they grasp nothing of His knowledge except what He wills. His Kursi encompasses the heavens and the earth, and preserving them does not tire Him. He is the Most High, the Most Great.',
    'source': 'Qur’an 2:255',
    'repeat': '1 time',
  };

  static const Map<String, String> _surahIkhlas = {
    'title': 'Surah Al-Ikhlas (Qur’an 112)',
    'arabic':
        'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    'transliteration':
        'Qul huwa Allahu ahad. Allahus-samad. Lam yalid wa lam yulad. Wa lam yakun lahu kufuwan ahad.',
    'translation':
        'Say, “He is Allah, the One; Allah, the Eternal Refuge. He neither begets nor is born, nor is there any equivalent to Him.”',
    'source':
        'Qur’an 112; recited in morning and evening (Jami` at-Tirmidhi 3575)',
    'repeat': '3 times',
  };

  static const Map<String, String> _surahFalaq = {
    'title': 'Surah Al-Falaq (Qur’an 113)',
    'arabic':
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'transliteration':
        'Qul a’udhu bi-rabbil-falaq. Min sharri ma khalaq. Wa min sharri ghasiqin idha waqab. Wa min sharrin-naffathati fil-uqad. Wa min sharri hasidin idha hasad.',
    'translation':
        'Say, “I seek refuge in the Lord of daybreak, from the evil of what He created, from the evil of the darkness when it settles, from the evil of those who blow on knots, and from the evil of an envier when they envy.”',
    'source':
        'Qur’an 113; recited in morning and evening (Jami` at-Tirmidhi 3575)',
    'repeat': '3 times',
  };

  static const Map<String, String> _surahNas = {
    'title': 'Surah An-Nas (Qur’an 114)',
    'arabic':
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    'transliteration':
        'Qul a’udhu bi-rabbin-nas. Malikin-nas. Ilahin-nas. Min sharril-waswasil-khannas. Alladhi yuwaswisu fi sudurin-nas. Minal-jinnati wan-nas.',
    'translation':
        'Say, “I seek refuge in the Lord of mankind, the King of mankind, the God of mankind, from the evil of the retreating whisperer, who whispers into the hearts of mankind, from among jinn and mankind.”',
    'source':
        'Qur’an 114; recited in morning and evening (Jami` at-Tirmidhi 3575)',
    'repeat': '3 times',
  };

  static const Map<String, String> _protectionDua = {
    'title': 'Protection Dua',
    'arabic':
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    'transliteration':
        'Bismillahil-ladhi la yadurru ma’asmihi shay’un fil-ardi wa la fis-sama’i wa huwas-sami’ul-alim',
    'translation':
        'In the name of Allah, with whose name nothing on earth or in heaven can cause harm; He is the All-Hearing, the All-Knowing.',
    'source': 'Sunan Abi Dawud 5088',
    'repeat': '3 times',
  };

  static final List<Map<String, String>> _morningAdhkar = [
    {
      'title': 'Morning Dua',
      'arabic':
          'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ',
      'transliteration':
          'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namut',
      'translation':
          'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening; by Your leave we live and by Your leave we die.',
      'source': 'Sunan Ibn Majah 3868',
      'repeat': '1 time',
    },
    _ayatAlKursi,
    _protectionDua,
    _surahIkhlas,
    _surahFalaq,
    _surahNas,
    {
      'title': 'Tasbih',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'transliteration': 'Subhanallahi wa bihamdihi',
      'translation': 'Glory and praise be to Allah.',
      'source': 'Sahih al-Bukhari 6405',
      'repeat': '100 times during the day',
    },
  ];

  static final List<Map<String, String>> _eveningAdhkar = [
    {
      'title': 'Evening Dua',
      'arabic':
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ أَسْأَلُكَ خَيْرَ هَٰذِهِ اللَّيْلَةِ، وَأَعُوذُ بِكَ مِنْ شَرِّ هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      'transliteration':
          'Amsayna wa amsal-mulku lillahi walhamdu lillah. La ilaha illallahu wahdahu la sharika lah. Lahul-mulku wa lahul-hamdu wa huwa ala kulli shay’in qadir. Allahumma as’aluka khayra hadhihil-laylati, wa a’udhu bika min sharri hadhihil-laylati wa sharri ma ba’daha. Allahumma inni a’udhu bika minal-kasali wa su’il-kibar. Allahumma inni a’udhu bika min adhabi fin-nari wa adhabi fil-qabr.',
      'translation':
          'We have entered the evening, and all dominion and praise belong to Allah. There is no god worthy of worship except Allah alone, without partner. His is the dominion and praise, and He has power over all things. O Allah, I ask You for the good of this night and seek refuge in You from its evil and the evil that follows it. O Allah, I seek refuge in You from laziness, the weakness of old age, and the punishment of the Fire and the grave.',
      'source': 'Sahih Muslim 2723a',
      'repeat': '1 time',
    },
    _protectionDua,
    _surahIkhlas,
    _surahFalaq,
    _surahNas,
  ];

  static final List<Map<String, String>> _mealsAdhkar = [
    {
      'title': 'Before Eating',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'translation': 'In the name of Allah.',
      'source': 'Sahih al-Bukhari 5376',
    },
    {
      'title': 'If Forgot Bismillah',
      'arabic': 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
      'transliteration': 'Bismillahi awwalahu wa akhirahu',
      'translation': 'In the name of Allah at its beginning and at its end',
      'source': 'Sunan Abi Dawud 3767',
    },
    {
      'title': 'After Eating',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا الطَّعَامَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      'transliteration':
          'Alhamdu lillahil-ladhi at’amani hadha at-ta’ama wa razaqanihi min ghayri hawlin minni wa la quwwah',
      'translation':
          'All praise is for Allah, who fed me this food and provided it for me without any power or strength on my part.',
      'source': 'Sunan Abi Dawud 4023',
    },
  ];

  static final List<Map<String, String>> _homeAdhkar = [
    {
      'title': 'Leaving Home',
      'arabic':
          'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration':
          'Bismillahi tawakkaltu alallahi, la hawla wa la quwwata illa billah',
      'translation':
          'In the name of Allah; I place my trust in Allah. There is no power and no strength except through Allah.',
      'source': 'Jami` at-Tirmidhi 3426 (grading differs among scholars)',
    },
    {
      'title': 'Entering Home',
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ، بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
      'transliteration':
          'Allahumma inni as’aluka khayral-mawliji wa khayral-makhraji. Bismillahi walajna, wa bismillahi kharajna, wa alallahi rabbina tawakkalna.',
      'translation':
          'O Allah, I ask You for the good of entering and the good of leaving. In the name of Allah we enter, in the name of Allah we leave, and in Allah, our Lord, we place our trust.',
      'source': 'Sunan Abi Dawud 5096 (graded weak by al-Albani)',
    },
  ];

  static final List<Map<String, String>> _sleepAdhkar = [
    {
      'title': 'Before Sleeping',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
      'source': 'Sahih al-Bukhari 6312',
    },
    _ayatAlKursi,
    {
      'title': 'Waking Up',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'transliteration':
          'Alhamdulillahil ladhi ahyana ba\'da ma amatana wa ilayhin nushur',
      'translation':
          'Praise be to Allah who gave us life after death and to Him is the resurrection',
      'source': 'Sahih al-Bukhari 6312',
    },
  ];

  static final List<Map<String, String>> _travelAdhkar = [
    {
      'title': 'Traveling Dua',
      'arabic':
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ، اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَٰذَا الْبِرَّ وَالتَّقْوَىٰ وَمِنَ الْعَمَلِ مَا تَرْضَىٰ، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَٰذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ وَالْخَلِيفَةُ فِي الْأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ وَكَآبَةِ الْمَنْظَرِ وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالْأَهْلِ',
      'transliteration':
          'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun. Allahumma inna nas’aluka fi safarina hadha al-birra wat-taqwa wa minal-amali ma tarda. Allahumma hawwin alayna safarana hadha watwi anna bu’dahu. Allahumma antas-sahibu fis-safari wal-khalifatu fil-ahl. Allahumma inni a’udhu bika min wa’tha’is-safari wa ka’abatil-manzari wa su’il-munqalabi fil-mali wal-ahl.',
      'translation':
          'Glory be to Him who has made this subservient to us, for we could not have controlled it ourselves, and surely to our Lord we will return. O Allah, we ask You on this journey for righteousness, piety, and deeds that please You. Make this journey easy for us and shorten its distance. You are our Companion on the journey and Protector of our family. I seek refuge in You from the hardships of travel, distressing sights, and a bad return concerning wealth and family.',
      'source': 'Sahih Muslim 1342 (say Allahu Akbar three times before it)',
    },
    {
      'title': 'Returning from Travel',
      'arabic': 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
      'transliteration': 'Ayibuna ta’ibuna abiduna li-rabbina hamidun',
      'translation':
          'We return, repentant, worshipping our Lord, and praising Him.',
      'source': 'Sahih Muslim 1342',
    },
    {
      'title': 'Seeking Refuge When Stopping on a Journey',
      'arabic':
          'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'transliteration':
          'A’udhu bi-kalimatillahit-tammati min sharri ma khalaq',
      'translation':
          'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      'source': 'Sahih Muslim 2708',
      'repeat': '3 times',
    },
  ];
}
