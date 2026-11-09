import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import '../../models/quran_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/arabic_text.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<QuranProvider>(context, listen: false)
          .loadVerses(widget.surah.number);
      _loadScrollPosition();
    });
    _scrollController.addListener(_saveScrollPosition);
  }

  Future<void> _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_read_surah_number', widget.surah.number);
    await prefs.setString('quran_last_read_surah_name', widget.surah.name);
    await prefs.setString(
      'quran_last_read_surah_english_name',
      widget.surah.englishName,
    );
    await prefs.setString(
      'quran_last_read_surah_translation',
      widget.surah.englishNameTranslation,
    );
    await prefs.setInt(
      'quran_last_read_surah_ayah_count',
      widget.surah.numberOfAyahs,
    );
    await prefs.setString(
      'quran_last_read_surah_revelation_type',
      widget.surah.revelationType,
    );
    final position =
        prefs.getDouble('quran_scroll_${widget.surah.number}') ?? 0.0;
    if (position > 0 && _scrollController.hasClients) {
      _scrollController.jumpTo(position);
    }
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setDouble(
            'quran_scroll_${widget.surah.number}', _scrollController.offset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          widget.surah.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Mark as completed',
            onPressed: () => _markAsCompleted(context),
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: provider.verses.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final verse = provider.verses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Verse number
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ArabicText(
                          'آیت ${verse.number}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Arabic text
                      ArabicText(
                        verse.text,
                        style: const TextStyle(
                          fontSize: 30,
                          height: 2,
                        ),
                      ),

                      const Divider(height: 32),

                      // Urdu translation
                      Text(
                        verse.translation,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsCompleted(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'quran_read',
        points: 10,
        metadata: {
          'surah_number': widget.surah.number,
          'surah_name': widget.surah.englishName,
        },
        activityName: 'Surah',
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login to earn points!'),
          ),
        );
      }
    }
  }
}
