import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SalahGuideScreen extends StatelessWidget {
  const SalahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Pray (Salah)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue,
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.self_improvement, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'The Second Pillar of Islam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '5 Daily Prayers',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Prayer Times:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            const _PrayerTimeCard(
              name: 'Fajr',
              time: 'Before sunrise',
              rakats: '2 Rakats',
              icon: Icons.wb_twilight,
              color: Colors.indigo,
            ),
            const _PrayerTimeCard(
              name: 'Dhuhr',
              time: 'After midday',
              rakats: '4 Rakats',
              icon: Icons.wb_sunny,
              color: Colors.orange,
            ),
            const _PrayerTimeCard(
              name: 'Asr',
              time: 'Afternoon',
              rakats: '4 Rakats',
              icon: Icons.wb_cloudy,
              color: Colors.amber,
            ),
            const _PrayerTimeCard(
              name: 'Maghrib',
              time: 'After sunset',
              rakats: '3 Rakats',
              icon: Icons.nights_stay,
              color: Colors.deepOrange,
            ),
            const _PrayerTimeCard(
              name: 'Isha',
              time: 'Night',
              rakats: '4 Rakats',
              icon: Icons.bedtime,
              color: Colors.deepPurple,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'How to Perform One Rakat:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            const _StepCard(
              number: 1,
              title: 'Make Wudu',
              description: 'Perform ablution to purify yourself',
            ),
            const _StepCard(
              number: 2,
              title: 'Face Qibla',
              description: 'Stand facing the direction of Kaaba in Makkah',
            ),
            const _StepCard(
              number: 3,
              title: 'Make Intention (Niyyah)',
              description: 'Intend in your heart which prayer you are performing',
            ),
            const _StepCard(
              number: 4,
              title: 'Takbir (Allahu Akbar)',
              description: 'Raise hands to ears and say "Allahu Akbar"',
            ),
            const _StepCard(
              number: 5,
              title: 'Recite Al-Fatihah',
              description: 'Recite the opening chapter of the Quran',
            ),
            const _StepCard(
              number: 6,
              title: 'Recite Another Surah',
              description: 'Recite any short surah or verses from Quran',
            ),
            const _StepCard(
              number: 7,
              title: 'Ruku (Bowing)',
              description: 'Say "Allahu Akbar" and bow, say "Subhana Rabbiyal Adheem" 3 times',
            ),
            const _StepCard(
              number: 8,
              title: 'Stand Up',
              description: 'Say "Sami Allahu liman hamidah" while standing up',
            ),
            const _StepCard(
              number: 9,
              title: 'First Sujood (Prostration)',
              description: 'Say "Allahu Akbar" and prostrate, say "Subhana Rabbiyal A\'la" 3 times',
            ),
            const _StepCard(
              number: 10,
              title: 'Sit Between Sujood',
              description: 'Sit briefly and say "Allahu Akbar"',
            ),
            const _StepCard(
              number: 11,
              title: 'Second Sujood',
              description: 'Prostrate again and say "Subhana Rabbiyal A\'la" 3 times',
            ),
            const _StepCard(
              number: 12,
              title: 'Tashahhud (After 2nd Rakat)',
              description: 'Sit and recite Tashahhud and Durood',
            ),
            const _StepCard(
              number: 13,
              title: 'Tasleem (Ending)',
              description: 'Turn head right and left saying "Assalamu Alaikum wa Rahmatullah"',
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: const Column(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Tip for Beginners',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start by learning Surah Al-Fatihah and 3 short surahs (Al-Ikhlas, Al-Falaq, An-Nas). Practice the movements slowly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
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
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      userProvider.logActivity(
        activityType: 'lesson_completed',
        points: 20,
        metadata: {'lesson': 'How to Pray (Salah)'},
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

class _PrayerTimeCard extends StatelessWidget {
  final String name;
  final String time;
  final String rakats;
  final IconData icon;
  final Color color;

  const _PrayerTimeCard({
    required this.name,
    required this.time,
    required this.rakats,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(time),
        trailing: Text(
          rakats,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
