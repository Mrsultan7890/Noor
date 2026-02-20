import 'package:flutter/material.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  final List<Map<String, String>> duas = const [
    {
      'title': 'Morning Dua',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'transliteration': 'Asbahna wa asbahal mulku lillah',
      'translation': 'We have entered morning and the kingdom belongs to Allah',
      'category': 'Morning'
    },
    {
      'title': 'Evening Dua',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'transliteration': 'Amsayna wa amsal mulku lillah',
      'translation': 'We have entered evening and the kingdom belongs to Allah',
      'category': 'Evening'
    },
    {
      'title': 'Before Eating',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'translation': 'In the name of Allah',
      'category': 'Daily'
    },
    {
      'title': 'After Eating',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
      'transliteration': 'Alhamdulillahil ladhi at\'amana wa saqana',
      'translation': 'Praise be to Allah who has fed us and given us drink',
      'category': 'Daily'
    },
    {
      'title': 'Before Sleeping',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
      'category': 'Daily'
    },
    {
      'title': 'Waking Up',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا',
      'transliteration': 'Alhamdulillahil ladhi ahyana ba\'da ma amatana',
      'translation': 'Praise be to Allah who gave us life after death',
      'category': 'Morning'
    },
    {
      'title': 'Leaving Home',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      'transliteration': 'Bismillah, tawakkaltu \'alallah',
      'translation': 'In the name of Allah, I place my trust in Allah',
      'category': 'Travel'
    },
    {
      'title': 'Entering Home',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ',
      'transliteration': 'Allahumma inni as\'aluka khayral mawlij',
      'translation': 'O Allah, I ask You for the best entrance',
      'category': 'Daily'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = duas.map((d) => d['category']!).toSet().toList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duas - دعائیں'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
            final categoryDuas = duas.where((d) => d['category'] == category).toList();
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
                        Text(
                          dua['title']!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dua['arabic']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 24, height: 2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dua['transliteration']!,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                        const Divider(height: 24),
                        Text(
                          dua['translation']!,
                          style: const TextStyle(fontSize: 16, height: 1.6),
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
