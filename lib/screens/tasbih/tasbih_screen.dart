import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/tasbih_provider.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih - تسبیح'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final provider = Provider.of<TasbihProvider>(context, listen: false);
              Share.share(
                'Alhamdulillah! I completed ${provider.count} ${provider.currentTasbih} on Noor App! 🌙\n\nJoin me in remembering Allah.',
                subject: 'My Tasbih Progress',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Consumer<TasbihProvider>(
        builder: (context, provider, child) {
          final progress = provider.count / provider.target;
          final isComplete = provider.count >= provider.target;
          
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Current Tasbih Name
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            provider.tasbihTypes[provider.currentTasbih] ?? '',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Counter Circle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              height: 250,
                              child: CircularProgressIndicator(
                                value: progress > 1 ? 1 : progress,
                                strokeWidth: 15,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isComplete ? Colors.green : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${provider.count}',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: isComplete ? Colors.green : Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  'of ${provider.target}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (isComplete) ...[
                                  const SizedBox(height: 8),
                                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                                ],
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Tap Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            provider.increment();
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.touch_app, color: Colors.white, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'TAP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showSettings(context),
                        icon: const Icon(Icons.tune),
                        label: const Text('Change'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showSettings(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasbih Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Select Tasbih:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...provider.tasbihTypes.entries.map((entry) {
              final isSelected = provider.currentTasbih == entry.key;
              return Card(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: Text(entry.key),
                  onTap: () {
                    provider.setTasbih(entry.key);
                    Navigator.pop(context);
                  },
                ),
              );
            }),
            
            const SizedBox(height: 24),
            Text(
              'Target Count:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [33, 99, 100, 500, 1000].map((count) {
                return ChoiceChip(
                  label: Text('$count'),
                  selected: provider.target == count,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: provider.target == count ? Colors.white : null,
                    fontWeight: provider.target == count ? FontWeight.bold : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      provider.setTarget(count);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
