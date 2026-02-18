import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Consumer<TasbihProvider>(
        builder: (context, provider, child) {
          final progress = provider.count / provider.target;
          
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Current Tasbih
                      Text(
                        provider.tasbihTypes[provider.currentTasbih] ?? '',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
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
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
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
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                'of ${provider.target}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
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
                            child: Text(
                              'TAP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Reset Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  onPressed: () => provider.reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
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
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasbih Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            Text('Select Tasbih:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            
            ...provider.tasbihTypes.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key),
                onTap: () {
                  provider.setTasbih(entry.key);
                  Navigator.pop(context);
                },
              );
            }),
            
            const SizedBox(height: 16),
            Text('Target Count:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              children: [33, 99, 100, 500, 1000].map((count) {
                return ChoiceChip(
                  label: Text('$count'),
                  selected: provider.target == count,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setTarget(count);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
