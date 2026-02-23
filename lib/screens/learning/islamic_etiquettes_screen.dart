import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class IslamicEtiquettesScreen extends StatelessWidget {
  const IslamicEtiquettesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Etiquettes (Adab)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Colors.indigo,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.favorite_border, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Good Manners in Islam',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const _EtiquetteCard(
            title: 'Eating Etiquette',
            icon: Icons.restaurant,
            color: Colors.orange,
            rules: [
              'Say Bismillah before eating',
              'Eat with right hand',
              'Eat from your side of the plate',
              'Don\'t waste food',
              'Say Alhamdulillah after eating',
              'Don\'t eat while lying down',
              'Wash hands before and after',
            ],
          ),
          
          const _EtiquetteCard(
            title: 'Greeting (Salam)',
            icon: Icons.waving_hand,
            color: Colors.green,
            rules: [
              'Say "Assalamu Alaikum" (Peace be upon you)',
              'Reply with "Wa Alaikum Assalam" (And upon you be peace)',
              'Smile when greeting',
              'Greet everyone you meet',
              'The younger greets the elder first',
              'The one riding greets the one walking',
              'Small group greets larger group',
            ],
          ),
          
          const _EtiquetteCard(
            title: 'Mosque Etiquette',
            icon: Icons.mosque,
            color: Colors.teal,
            rules: [
              'Remove shoes before entering',
              'Enter with right foot first',
              'Pray 2 rakats (Tahiyyat al-Masjid)',
              'Keep silence and avoid worldly talk',
              'Turn off mobile phone',
              'Don\'t eat strong-smelling food before',
              'Sit respectfully',
              'Leave with left foot first',
            ],
          ),
          
          const _EtiquetteCard(
            title: 'Bathroom Etiquette',
            icon: Icons.wc,
            color: Colors.blue,
            rules: [
              'Enter with left foot',
              'Say dua before entering',
              'Don\'t take Quran or Allah\'s name inside',
              'Use water for cleanliness',
              'Exit with right foot',
              'Say dua after exiting',
              'Wash hands thoroughly',
            ],
          ),
          
          const _EtiquetteCard(
            title: 'Sleeping Etiquette',
            icon: Icons.bedtime,
            color: Colors.purple,
            rules: [
              'Sleep on right side',
              'Face towards Qibla if possible',
              'Say Bismillah and sleeping dua',
              'Perform wudu before sleeping',
              'Read Ayat al-Kursi',
              'Recite last 3 Surahs of Quran',
              'Don\'t sleep on stomach',
            ],
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            onPressed: () => _markAsCompleted(context),
            icon: const Icon(Icons.check),
            label: const Text('Mark as Learned'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      userProvider.logActivity(
        activityType: 'lesson_completed',
        points: 20,
        metadata: {'lesson': 'Islamic Etiquettes'},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson completed! +20 points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _EtiquetteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> rules;

  const _EtiquetteCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.rules,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
