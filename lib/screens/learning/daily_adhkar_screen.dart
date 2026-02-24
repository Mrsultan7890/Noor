import 'package:flutter/material.dart';

class DailyAdhkarScreen extends StatelessWidget {
  const DailyAdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Adhkar'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Morning'),
              Tab(text: 'Evening'),
              Tab(text: 'Meals'),
              Tab(text: 'Home'),
              Tab(text: 'Sleep'),
              Tab(text: 'Travel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDuaList(_morningAdhkar),
            _buildDuaList(_eveningAdhkar),
            _buildDuaList(_mealsAdhkar),
            _buildDuaList(_homeAdhkar),
            _buildDuaList(_sleepAdhkar),
            _buildDuaList(_travelAdhkar),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaList(List<Map<String, String>> duas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final dua = duas[index];
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
                  child: Text(
                    dua['arabic']!,
                    style: const TextStyle(fontSize: 22, height: 2),
                    textAlign: TextAlign.right,
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
                if (dua['repeat'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  static final List<Map<String, String>> _morningAdhkar = [
    {
      'title': 'Morning Dua',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'transliteration': 'Asbahna wa asbahal mulku lillah walhamdulillah',
      'translation': 'We have entered morning and the kingdom belongs to Allah, and all praise is for Allah',
      'repeat': '1 time',
    },
    {
      'title': 'Ayat al-Kursi',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      'transliteration': 'Allahu la ilaha illa huwal hayyul qayyum, la ta\'khudhuhu sinatun wa la nawm',
      'translation': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer. Neither drowsiness overtakes Him nor sleep',
      'repeat': '1 time',
    },
    {
      'title': 'Protection Dua',
      'arabic': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
      'transliteration': 'Bismillahil ladhi la yadurru ma\'asmihi shay\'un fil ardi wa la fis sama',
      'translation': 'In the name of Allah with whose name nothing can harm in the earth nor in the heaven',
      'repeat': '3 times',
    },
    {
      'title': 'Tasbih',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'transliteration': 'Subhanallahi wa bihamdihi',
      'translation': 'Glory be to Allah and praise Him',
      'repeat': '100 times',
    },
  ];

  static final List<Map<String, String>> _eveningAdhkar = [
    {
      'title': 'Evening Dua',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'transliteration': 'Amsayna wa amsal mulku lillah walhamdulillah',
      'translation': 'We have entered evening and the kingdom belongs to Allah, and all praise is for Allah',
      'repeat': '1 time',
    },
    {
      'title': 'Seeking Refuge',
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'transliteration': 'A\'udhu bikalimatillahit tammati min sharri ma khalaq',
      'translation': 'I seek refuge in the perfect words of Allah from the evil of what He created',
      'repeat': '3 times',
    },
    {
      'title': 'Last 3 Surahs',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'transliteration': 'Qul huwallahu ahad',
      'translation': 'Say: He is Allah, the One (Surah Al-Ikhlas)',
      'repeat': '3 times each (Al-Ikhlas, Al-Falaq, An-Nas)',
    },
  ];

  static final List<Map<String, String>> _mealsAdhkar = [
    {
      'title': 'Before Eating',
      'arabic': 'بِسْمِ اللَّهِ وَعَلَىٰ بَرَكَةِ اللَّهِ',
      'transliteration': 'Bismillah wa \'ala barakatillah',
      'translation': 'In the name of Allah and with the blessings of Allah',
    },
    {
      'title': 'If Forgot Bismillah',
      'arabic': 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
      'transliteration': 'Bismillahi awwalahu wa akhirahu',
      'translation': 'In the name of Allah at its beginning and at its end',
    },
    {
      'title': 'After Eating',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'transliteration': 'Alhamdulillahil ladhi at\'amana wa saqana wa ja\'alana muslimin',
      'translation': 'Praise be to Allah who has fed us, given us drink, and made us Muslims',
    },
  ];

  static final List<Map<String, String>> _homeAdhkar = [
    {
      'title': 'Leaving Home',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      'transliteration': 'Bismillah, tawakkaltu \'alallah',
      'translation': 'In the name of Allah, I place my trust in Allah',
    },
    {
      'title': 'Entering Home',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
      'transliteration': 'Allahumma inni as\'aluka khayral mawliji wa khayral makhraji',
      'translation': 'O Allah, I ask You for the best entrance and the best exit',
    },
  ];

  static final List<Map<String, String>> _sleepAdhkar = [
    {
      'title': 'Before Sleeping',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
    },
    {
      'title': 'Ayat al-Kursi Before Sleep',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Allahu la ilaha illa huwal hayyul qayyum',
      'translation': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer',
      'repeat': '1 time',
    },
    {
      'title': 'Waking Up',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'transliteration': 'Alhamdulillahil ladhi ahyana ba\'da ma amatana wa ilayhin nushur',
      'translation': 'Praise be to Allah who gave us life after death and to Him is the resurrection',
    },
  ];

  static final List<Map<String, String>> _travelAdhkar = [
    {
      'title': 'Traveling Dua',
      'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا',
      'transliteration': 'Subhanal ladhi sakhkhara lana hadha',
      'translation': 'Glory to Him who has subjected this to us',
    },
    {
      'title': 'Protection While Traveling',
      'arabic': 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَٰذَا الْبِرَّ وَالتَّقْوَىٰ',
      'transliteration': 'Allahumma inna nas\'aluka fi safarina hadhal birra wat taqwa',
      'translation': 'O Allah, we ask You for righteousness and piety in this journey',
    },
  ];
}
