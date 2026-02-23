import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/quran_provider.dart';
import '../../models/quran_model.dart';
import '../../services/enhanced_quran_service.dart';
import '../../models/word_by_word_model.dart';

class EnhancedQuranReaderScreen extends StatefulWidget {
  final Surah surah;
  
  const EnhancedQuranReaderScreen({super.key, required this.surah});

  @override
  State<EnhancedQuranReaderScreen> createState() => _EnhancedQuranReaderScreenState();
}

class _EnhancedQuranReaderScreenState extends State<EnhancedQuranReaderScreen> {
  final EnhancedQuranService _service = EnhancedQuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<String> _transliterations = [];
  bool _showTransliteration = true;
  bool _isSlowMode = false;
  int? _playingVerse;
  int? _highlightedVerse;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_playingVerse != null) {
        _playNextVerse();
      }
    });
  }
  
  Future<void> _loadData() async {
    await Provider.of<QuranProvider>(context, listen: false)
        .loadVerses(widget.surah.number);
    
    final transliterations = await _service.getTransliteration(widget.surah.number);
    setState(() {
      _transliterations = transliterations;
    });
  }
  
  Future<void> _playVerse(int verseNumber) async {
    final audioUrl = _isSlowMode 
        ? _service.getSlowAudioUrl(widget.surah.number, verseNumber)
        : _service.getAudioUrl(widget.surah.number, verseNumber);
    
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(audioUrl));
    
    setState(() {
      _playingVerse = verseNumber;
      _highlightedVerse = verseNumber;
    });
  }
  
  Future<void> _playNextVerse() async {
    final provider = Provider.of<QuranProvider>(context, listen: false);
    if (_playingVerse != null && _playingVerse! < provider.verses.length) {
      await _playVerse(_playingVerse! + 1);
    } else {
      setState(() {
        _playingVerse = null;
        _highlightedVerse = null;
      });
    }
  }
  
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingVerse = null;
      _highlightedVerse = null;
    });
  }
  
  void _showWordByWordDialog(int verseNumber) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    final verseData = await _service.getWordByWord(
      widget.surah.number,
      verseNumber,
    );
    
    if (mounted) {
      Navigator.pop(context);
    }
    
    if (verseData != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => _WordByWordDialog(verseData: verseData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        actions: [
          IconButton(
            icon: Icon(_showTransliteration ? Icons.text_fields : Icons.text_fields_outlined),
            onPressed: () {
              setState(() {
                _showTransliteration = !_showTransliteration;
              });
            },
            tooltip: 'Toggle Transliteration',
          ),
          IconButton(
            icon: Icon(_isSlowMode ? Icons.slow_motion_video : Icons.speed),
            onPressed: () {
              setState(() {
                _isSlowMode = !_isSlowMode;
              });
            },
            tooltip: _isSlowMode ? 'Normal Speed' : 'Slow Speed',
          ),
          if (_playingVerse != null)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopAudio,
              tooltip: 'Stop',
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
            itemCount: provider.verses.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final verse = provider.verses[index];
              final isHighlighted = _highlightedVerse == verse.number;
              final transliteration = index < _transliterations.length 
                  ? _transliterations[index] 
                  : '';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: isHighlighted 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with verse number and controls
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'آیت ${verse.number}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _playingVerse == verse.number 
                                  ? Icons.pause_circle 
                                  : Icons.play_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (_playingVerse == verse.number) {
                                _stopAudio();
                              } else {
                                _playVerse(verse.number);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.translate,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => _showWordByWordDialog(verse.number),
                            tooltip: 'Word by Word',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Arabic text
                      Text(
                        verse.text,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 2,
                        ),
                      ),
                      
                      // Transliteration
                      if (_showTransliteration && transliteration.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transliteration,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      
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
    _audioPlayer.dispose();
    super.dispose();
  }
}

class _WordByWordDialog extends StatelessWidget {
  final VerseWithWords verseData;
  
  const _WordByWordDialog({required this.verseData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Word by Word - ${verseData.verseKey}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Words list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: verseData.words.length,
                itemBuilder: (context, index) {
                  final word = verseData.words[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Arabic word
                          Text(
                            word.arabicText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Transliteration
                          Text(
                            word.transliteration,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Translation
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word.translation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
