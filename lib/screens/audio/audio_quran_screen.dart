import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  final AudioPlayer _player = AudioPlayer();
  int? _currentSurah;
  bool _isLoading = false;
  String _selectedReciter = 'ar.alafasy';

  final Map<String, String> _reciters = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.abdulbasitmurattal': 'Abdul Basit (Murattal)',
    'ar.abdurrahmaansudais': 'Abdur-Rahman As-Sudais',
    'ar.saadalghamadi': 'Saad Al-Ghamdi',
    'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
    'ar.husary': 'Mahmoud Khalil Al-Hussary',
  };

  final List<String> _surahNames = [
    'Al-Fatihah', 'Al-Baqarah', 'Aal-E-Imran', 'An-Nisa', 'Al-Maidah',
    'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya', 'Al-Hajj', 'Al-Muminun', 'An-Nur', 'Al-Furqan',
    'Ash-Shuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqiah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumuah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-Ala', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Lail', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
    'Al-Qariah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil',
    'Quraish', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas'
  ];

  @override
  void initState() {
    super.initState();
    _loadReciter();
  }

  Future<void> _loadReciter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedReciter = prefs.getString('reciter') ?? 'ar.alafasy');
  }

  Future<void> _saveReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reciter', reciter);
    setState(() => _selectedReciter = reciter);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int surahNumber) async {
    if (!mounted) return;
    
    await _player.stop();
    
    setState(() {
      _isLoading = true;
      _currentSurah = surahNumber;
    });

    try {
      await _player.setUrl('https://cdn.islamic.network/quran/audio/128/$_selectedReciter/$surahNumber.mp3');
      await _player.play();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Reciter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reciters.entries.map((e) => RadioListTile<String>(
            title: Text(e.value),
            value: e.key,
            groupValue: _selectedReciter,
            onChanged: (val) {
              if (val != null) {
                _saveReciter(val);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Quran - آڈیو قرآن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Select Reciter',
            onPressed: _showReciterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 114,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final surahNumber = index + 1;
                final isPlaying = _currentSurah == surahNumber;
                
                return Card(
                  color: isPlaying ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPlaying ? Theme.of(context).primaryColor : null,
                      child: Text('$surahNumber', style: TextStyle(color: isPlaying ? Colors.white : null)),
                    ),
                    title: Text(_surahNames[index], style: TextStyle(fontWeight: isPlaying ? FontWeight.bold : null)),
                    subtitle: Text('Surah $surahNumber'),
                    trailing: _isLoading && isPlaying
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                            color: Theme.of(context).primaryColor,
                            iconSize: 32,
                            onPressed: () {
                              if (isPlaying) {
                                _player.pause();
                              } else {
                                _playAudio(surahNumber);
                              }
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          if (_currentSurah != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  Text(
                    _surahNames[_currentSurah! - 1],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _player.duration ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
                            onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position)),
                                Text(_formatDuration(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 36,
                        onPressed: _currentSurah! > 1 ? () => _playAudio(_currentSurah! - 1) : null,
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final playing = playerState?.playing ?? false;
                          return IconButton(
                            icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                            iconSize: 64,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              if (playing) {
                                _player.pause();
                              } else {
                                _player.play();
                              }
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 36,
                        onPressed: _currentSurah! < 114 ? () => _playAudio(_currentSurah! + 1) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
