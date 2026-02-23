import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SixPillarsImanScreen extends StatelessWidget {
  const SixPillarsImanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Six Pillars of Iman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple,
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Articles of Faith',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'What Muslims Believe',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _PillarCard(
              number: 1,
              title: 'Belief in Allah',
              icon: Icons.star,
              color: Colors.amber,
              description: 'Belief in one God (Allah) who is the Creator, Sustainer, and Lord of everything. He has no partners, no children, and nothing is like Him.',
              details: [
                'Allah is One and Unique',
                'He has 99 beautiful names',
                'He is All-Knowing and All-Powerful',
                'He is the Most Merciful',
              ],
            ),
            
            _PillarCard(
              number: 2,
              title: 'Belief in Angels',
              icon: Icons.cloud,
              color: Colors.blue,
              description: 'Angels are created from light and always obey Allah. They have different duties assigned by Allah.',
              details: [
                'Jibreel (Gabriel) - Revelation',
                'Mikail (Michael) - Provisions',
                'Israfil - Trumpet on Day of Judgment',
                'Azrael - Angel of Death',
              ],
            ),
            
            _PillarCard(
              number: 3,
              title: 'Belief in Books',
              icon: Icons.menu_book,
              color: Colors.green,
              description: 'Allah revealed books to guide humanity. The Quran is the final and complete revelation.',
              details: [
                'Quran - Revealed to Prophet Muhammad ﷺ',
                'Torah - Revealed to Prophet Musa (Moses)',
                'Gospel - Revealed to Prophet Isa (Jesus)',
                'Psalms - Revealed to Prophet Dawud (David)',
              ],
            ),
            
            _PillarCard(
              number: 4,
              title: 'Belief in Prophets',
              icon: Icons.people,
              color: Colors.teal,
              description: 'Allah sent prophets to guide people. Muhammad ﷺ is the final prophet.',
              details: [
                'Adam - First Prophet',
                'Ibrahim (Abraham) - Father of Prophets',
                'Musa (Moses) - Prophet to Pharaoh',
                'Isa (Jesus) - Born miraculously',
                'Muhammad ﷺ - Final Prophet',
              ],
            ),
            
            _PillarCard(
              number: 5,
              title: 'Belief in Day of Judgment',
              icon: Icons.gavel,
              color: Colors.orange,
              description: 'Everyone will be resurrected and judged by Allah for their deeds. Paradise or Hell will be the final destination.',
              details: [
                'Life after death',
                'Resurrection of all people',
                'Judgment based on deeds',
                'Paradise (Jannah) for believers',
                'Hell (Jahannam) for disbelievers',
              ],
            ),
            
            _PillarCard(
              number: 6,
              title: 'Belief in Divine Decree (Qadr)',
              icon: Icons.timeline,
              color: Colors.deepPurple,
              description: 'Everything happens by Allah\'s will and knowledge. Good and bad are both tests from Allah.',
              details: [
                'Allah knows everything',
                'Everything is written',
                'Nothing happens without Allah\'s will',
                'We have free will to choose',
                'Tests make us stronger',
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
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      userProvider.logActivity(
        activityType: 'lesson_completed',
        points: 20,
        metadata: {'lesson': 'Six Pillars of Iman'},
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

class _PillarCard extends StatelessWidget {
  final int number;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> details;

  const _PillarCard({
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                '$number',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 13),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail,
                        style: const TextStyle(fontSize: 14),
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
