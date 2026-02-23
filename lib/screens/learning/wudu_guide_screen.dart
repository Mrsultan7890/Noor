import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class WuduGuideScreen extends StatelessWidget {
  const WuduGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Perform Wudu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.cyan,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.water_drop, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Ablution (Wudu)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Purification before Prayer',
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
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'When is Wudu Required?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Before each prayer (Salah)\n• Before touching the Quran\n• Before Tawaf (circling Kaaba)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Steps to Perform Wudu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            const _StepCard(
              number: 1,
              title: 'Make Intention (Niyyah)',
              description: 'Intend in your heart to perform wudu for purification',
              arabic: '',
            ),
            
            const _StepCard(
              number: 2,
              title: 'Say Bismillah',
              description: 'Begin by saying "In the name of Allah"',
              arabic: 'بِسْمِ اللَّهِ',
            ),
            
            const _StepCard(
              number: 3,
              title: 'Wash Both Hands',
              description: 'Wash both hands up to the wrists 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 4,
              title: 'Rinse Mouth',
              description: 'Rinse your mouth thoroughly 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 5,
              title: 'Rinse Nose',
              description: 'Sniff water into nostrils and blow out 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 6,
              title: 'Wash Face',
              description: 'Wash entire face from forehead to chin, ear to ear, 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 7,
              title: 'Wash Right Arm',
              description: 'Wash right arm from fingertips to elbow 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 8,
              title: 'Wash Left Arm',
              description: 'Wash left arm from fingertips to elbow 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 9,
              title: 'Wipe Head',
              description: 'Wipe head with wet hands from front to back once',
              arabic: '',
            ),
            
            const _StepCard(
              number: 10,
              title: 'Wipe Ears',
              description: 'Wipe inside and back of both ears once',
              arabic: '',
            ),
            
            const _StepCard(
              number: 11,
              title: 'Wash Right Foot',
              description: 'Wash right foot up to ankle 3 times',
              arabic: '',
            ),
            
            const _StepCard(
              number: 12,
              title: 'Wash Left Foot',
              description: 'Wash left foot up to ankle 3 times',
              arabic: '',
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dua After Wudu:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
                    style: TextStyle(fontSize: 18, height: 2),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Ash-hadu an la ilaha illallahu wahdahu la sharika lah, wa ash-hadu anna Muhammadan \'abduhu wa rasuluh',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'I bear witness that there is no god but Allah alone, with no partner, and I bear witness that Muhammad is His servant and messenger.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
                    'Things That Break Wudu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Using the bathroom\n• Passing gas\n• Deep sleep\n• Bleeding\n• Vomiting',
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
        metadata: {'lesson': 'How to Perform Wudu'},
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

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String arabic;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.arabic,
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
              decoration: const BoxDecoration(
                color: Colors.cyan,
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
                  if (arabic.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      arabic,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
