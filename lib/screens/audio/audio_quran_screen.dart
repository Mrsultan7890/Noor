import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int surahNumber) async {
    if (!mounted) return;
    try {
      await _player.setUrl('https://cdn.islamic.network/quran/audio/128/ar.alafasy/$surahNumber.mp3');
      _player.play();
      setState(() => _isPlaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Quran - آڈیو قرآن')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 114,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Surah ${index + 1}'),
                    trailing: IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => _playAudio(index + 1),
                    ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _player.duration ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(icon: const Icon(Icons.skip_previous), onPressed: () {}),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48),
                        onPressed: () {
                          if (_isPlaying) {
                            _player.pause();
                          } else {
                            _player.play();
                          }
                          setState(() => _isPlaying = !_isPlaying);
                        },
                      ),
                      IconButton(icon: const Icon(Icons.skip_next), onPressed: () {}),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
