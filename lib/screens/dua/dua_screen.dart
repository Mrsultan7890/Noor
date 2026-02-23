import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {

  Set<String> _memorizedDuas = {};

  @override
  void initState() {
    super.initState();
    _loadMemorizedDuas();
  }

  Future<void> _loadMemorizedDuas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _memorizedDuas = (prefs.getStringList('memorized_duas') ?? []).toSet();
    });
  }

  Future<void> _toggleMemorized(String duaTitle) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (_memorizedDuas.contains(duaTitle)) {
      _memorizedDuas.remove(duaTitle);
    } else {
      _memorizedDuas.add(duaTitle);
      
      // Award points for memorizing
      if (userProvider.isAuthenticated) {
        await userProvider.logActivity(
          activityType: 'dua_memorized',
          points: 15,
          metadata: {'dua_title': duaTitle},
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dua memorized! +15 points'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('memorized_duas', _memorizedDuas.toList());
    setState(() {});
  }

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dua['title']!,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              tooltip: 'Mark as memorized',
                            ),
                          ],
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
