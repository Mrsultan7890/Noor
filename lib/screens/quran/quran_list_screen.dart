import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import 'quran_reader_screen.dart';
import 'enhanced_quran_reader_screen.dart';
import '../../widgets/arabic_text.dart';
import '../../providers/app_language_provider.dart';
import '../../widgets/service_loading_view.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<QuranProvider>(context, listen: false).loadSurahs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Quran')),
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const ServiceLoadingView(
              serviceName: 'Quran',
              icon: Icons.menu_book_outlined,
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadSurahs(),
                    child: Text(context.tr('Try again')),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.surahs.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final surah = provider.surahs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${surah.number}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: ArabicText(
                    surah.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${surah.englishName} - ${surah.numberOfAyahs} ${context.tr('Ayahs')}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.headphones, size: 20),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EnhancedQuranReaderScreen(surah: surah),
                            ),
                          );
                        },
                        tooltip: context.tr('Learn Mode'),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranReaderScreen(surah: surah),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
