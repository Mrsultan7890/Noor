import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class HalalHaramScreen extends StatelessWidget {
  const HalalHaramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halal & Haram'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Colors.green,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'What is Permissible & Forbidden',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const _CategoryCard(
            title: 'What is Halal?',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            description: 'Halal means permissible or lawful in Islam. These are things Allah has allowed us to do.',
            items: [
              'All vegetables and fruits',
              'Grains, rice, wheat, bread',
              'Fish and seafood',
              'Meat from halal animals (chicken, beef, lamb)',
              'Milk, cheese, yogurt',
              'Eggs',
              'Honey',
              'Earning through honest work',
            ],
          ),
          
          const _CategoryCard(
            title: 'What is Haram?',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            description: 'Haram means forbidden in Islam. These are things Allah has prohibited for our own good.',
            items: [
              'Pork and pig products',
              'Alcohol and intoxicants',
              'Drugs and smoking',
              'Gambling',
              'Stealing',
              'Lying and cheating',
              'Backbiting and gossip',
              'Interest (Riba) in business',
            ],
          ),
          
          const _CategoryCard(
            title: 'Halal Food Rules',
            icon: Icons.restaurant_menu,
            color: Colors.orange,
            description: 'Guidelines for what Muslims can eat and drink.',
            items: [
              'Animal must be slaughtered in Islamic way',
              'Say Bismillah before slaughtering',
              'No pork or pork products',
              'No alcohol or intoxicants',
              'No blood',
              'No dead animals (not slaughtered properly)',
              'Check ingredients for haram substances',
              'Eat only from halal sources',
            ],
          ),
          
          const _CategoryCard(
            title: 'Halal Meat Requirements',
            icon: Icons.set_meal,
            color: Colors.brown,
            description: 'How meat becomes halal for Muslims.',
            items: [
              'Animal must be alive and healthy',
              'Slaughter by Muslim or People of the Book',
              'Say "Bismillah, Allahu Akbar"',
              'Cut throat, windpipe, and blood vessels',
              'Let blood drain completely',
              'Treat animal with kindness',
              'Use sharp knife',
              'Don\'t slaughter in front of other animals',
            ],
          ),
          
          const _CategoryCard(
            title: 'Business Ethics (Halal)',
            icon: Icons.business_center,
            color: Colors.blue,
            description: 'How to earn money in a halal way.',
            items: [
              'Honest trade and business',
              'Fair prices, no cheating',
              'No interest (Riba)',
              'No gambling or lottery',
              'No selling haram items',
              'Pay workers fairly',
              'Keep promises and contracts',
              'Give correct weight and measure',
            ],
          ),
          
          const _CategoryCard(
            title: 'Haram Business Practices',
            icon: Icons.money_off,
            color: Colors.red,
            description: 'Business activities that are forbidden.',
            items: [
              'Charging or paying interest (Riba)',
              'Gambling and betting',
              'Selling alcohol or drugs',
              'Selling pork products',
              'Fraud and deception',
              'Hoarding goods to increase prices',
              'Bribery and corruption',
              'Selling stolen goods',
            ],
          ),
          
          const _CategoryCard(
            title: 'Social Interactions (Halal)',
            icon: Icons.people,
            color: Colors.teal,
            description: 'Proper way to interact with others.',
            items: [
              'Respect everyone',
              'Be kind and helpful',
              'Speak truth',
              'Keep promises',
              'Maintain modesty',
              'Lower your gaze',
              'Avoid free mixing of genders',
              'Seek permission before entering',
            ],
          ),
          
          const _CategoryCard(
            title: 'Haram Social Behaviors',
            icon: Icons.block,
            color: Colors.red,
            description: 'Social behaviors that are forbidden.',
            items: [
              'Backbiting (talking bad about others)',
              'Lying and false testimony',
              'Gossiping and spreading rumors',
              'Arrogance and pride',
              'Showing off (Riya)',
              'Inappropriate relationships',
              'Disrespecting parents',
              'Breaking promises',
            ],
          ),
          
          const _CategoryCard(
            title: 'Entertainment (Halal)',
            icon: Icons.sports_esports,
            color: Colors.purple,
            description: 'Permissible forms of entertainment.',
            items: [
              'Sports and physical activities',
              'Reading beneficial books',
              'Spending time with family',
              'Learning new skills',
              'Traveling and exploring',
              'Halal games and hobbies',
              'Listening to Islamic nasheeds',
              'Watching educational content',
            ],
          ),
          
          const _CategoryCard(
            title: 'Entertainment (Haram)',
            icon: Icons.not_interested,
            color: Colors.red,
            description: 'Forms of entertainment that are forbidden.',
            items: [
              'Gambling and betting',
              'Watching inappropriate content',
              'Music with inappropriate lyrics',
              'Wasting time excessively',
              'Games promoting violence/haram',
              'Nightclubs and bars',
              'Mixed dancing',
              'Anything leading to sin',
            ],
          ),
          
          const _CategoryCard(
            title: 'Marriage & Family (Halal)',
            icon: Icons.favorite,
            color: Colors.pink,
            description: 'Proper Islamic way of marriage and family life.',
            items: [
              'Nikah (Islamic marriage)',
              'Treating spouse with kindness',
              'Raising children with Islamic values',
              'Spending quality time with family',
              'Being faithful to spouse',
              'Providing for family',
              'Respecting in-laws',
              'Teaching children Quran',
            ],
          ),
          
          const _CategoryCard(
            title: 'Marriage & Family (Haram)',
            icon: Icons.heart_broken,
            color: Colors.red,
            description: 'Forbidden relationships and family behaviors.',
            items: [
              'Zina (fornication/adultery)',
              'Dating and boyfriend/girlfriend',
              'Inappropriate relationships',
              'Being alone with non-mahram',
              'Neglecting family responsibilities',
              'Abusing spouse or children',
              'Disobeying parents (without valid reason)',
              'Breaking family ties',
            ],
          ),
          
          const _CategoryCard(
            title: 'Clothing & Appearance (Halal)',
            icon: Icons.checkroom,
            color: Colors.indigo,
            description: 'Proper Islamic dress and appearance.',
            items: [
              'Modest dress covering awrah',
              'Clean and presentable clothes',
              'Natural beauty and grooming',
              'Wearing perfume (for men)',
              'Trimming nails and hair',
              'Using kohl (eyeliner)',
              'Wearing ring (for men: silver only)',
              'Dressing appropriately for occasions',
            ],
          ),
          
          const _CategoryCard(
            title: 'Clothing & Appearance (Haram)',
            icon: Icons.block,
            color: Colors.red,
            description: 'Forbidden dress and appearance modifications.',
            items: [
              'Imitating opposite gender',
              'Permanent tattoos',
              'Silk clothing for men',
              'Gold jewelry for men',
              'Tight or transparent clothing',
              'Showing awrah in public',
              'Plucking eyebrows',
              'Hair extensions (if deceptive)',
            ],
          ),
          
          const _CategoryCard(
            title: 'Technology & Media (Halal)',
            icon: Icons.devices,
            color: Colors.cyan,
            description: 'Proper use of technology and media.',
            items: [
              'Educational content',
              'Islamic lectures and nasheeds',
              'Halal entertainment',
              'Learning beneficial skills online',
              'Staying connected with family',
              'Using social media for dawah',
              'Reading Islamic articles',
              'Productive use of time',
            ],
          ),
          
          const _CategoryCard(
            title: 'Technology & Media (Haram)',
            icon: Icons.phone_disabled,
            color: Colors.red,
            description: 'Forbidden use of technology and media.',
            items: [
              'Pornography and explicit content',
              'Excessive time-wasting',
              'Cyberbullying and harassment',
              'Spreading false information',
              'Hacking and stealing data',
              'Inappropriate chatting',
              'Watching haram content',
              'Neglecting prayers for devices',
            ],
          ),
          
          const _CategoryCard(
            title: 'Animals & Pets (Halal)',
            icon: Icons.pets,
            color: Colors.lime,
            description: 'Proper treatment of animals in Islam.',
            items: [
              'Keeping cats as pets',
              'Treating animals with kindness',
              'Feeding and caring for animals',
              'Using animals for work (humanely)',
              'Keeping birds and fish',
              'Protecting animals from harm',
              'Slaughtering animals humanely',
              'Riding horses and camels',
            ],
          ),
          
          const _CategoryCard(
            title: 'Animals & Pets (Haram)',
            icon: Icons.dangerous,
            color: Colors.red,
            description: 'Forbidden treatment and use of animals.',
            items: [
              'Keeping dogs inside house (except guard/hunting)',
              'Animal cruelty and abuse',
              'Fighting animals for entertainment',
              'Cutting animal tails or ears',
              'Branding animals on face',
              'Hunting for sport (not food)',
              'Keeping animals in poor conditions',
              'Using animals for gambling',
            ],
          ),
          
          const _CategoryCard(
            title: 'Health & Medicine (Halal)',
            icon: Icons.medical_services,
            color: Colors.lightGreen,
            description: 'Seeking treatment and maintaining health.',
            items: [
              'Seeking medical treatment',
              'Taking vaccines',
              'Surgery when necessary',
              'Using halal medicines',
              'Exercising and staying fit',
              'Eating healthy food',
              'Mental health treatment',
              'Preventive healthcare',
            ],
          ),
          
          const _CategoryCard(
            title: 'Health & Medicine (Haram)',
            icon: Icons.medication,
            color: Colors.red,
            description: 'Forbidden medicines and health practices.',
            items: [
              'Alcohol-based medicine (if alternatives exist)',
              'Using haram substances',
              'Unnecessary cosmetic surgery',
              'Gender change surgery',
              'Abortion (except valid reasons)',
              'Euthanasia',
              'Harmful drugs and steroids',
              'Neglecting health deliberately',
            ],
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
                  'Important Note',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'When in doubt, ask a knowledgeable person or scholar. It\'s better to avoid doubtful things.',
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
    );
  }

  void _markAsCompleted(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      userProvider.logActivity(
        activityType: 'lesson_completed',
        points: 20,
        metadata: {'lesson': 'Halal & Haram'},
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

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> items;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.items,
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      color == Colors.red ? Icons.cancel : Icons.check_circle,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
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
