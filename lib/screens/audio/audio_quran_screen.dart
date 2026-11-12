import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/user_friendly_error.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/arabic_text.dart';
import '../../services/quran_audio_service.dart';
import '../../services/quran_audio_playback.dart';
import '../../providers/app_language_provider.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  final AudioPlayer _player = QuranAudioPlayback.player;
  final QuranAudioService _audioService = QuranAudioService();
  int? _currentSurah;
  List<QuranAudioAyah> _currentAyahs = const [];
  int? _currentAyahIndex;
  bool _isLoading = false;
  bool _isPlayerExpanded = true;
  String _selectedReciter = 'ar.alafasy';
  double _playbackSpeed = 1;
  LoopMode _loopMode = LoopMode.off;
  StreamSubscription<int?>? _indexSubscription;

  final Map<String, String> _reciters = {
    'ar.abdulbasitmurattal': 'Abdul Basit (Murattal)',
    'ar.abdullahbasfar': 'Abdullah Basfar',
    'ar.abdurrahmaansudais': 'Abdur-Rahman As-Sudais',
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
    'ar.husary': 'Mahmoud Khalil Al-Hussary',
  };

  final List<String> _surahNames = [
    'Al-Fatihah',
    'Al-Baqarah',
    'Aal-E-Imran',
    'An-Nisa',
    'Al-Maidah',
    'Al-Anam',
    'Al-Araf',
    'Al-Anfal',
    'At-Tawbah',
    'Yunus',
    'Hud',
    'Yusuf',
    'Ar-Rad',
    'Ibrahim',
    'Al-Hijr',
    'An-Nahl',
    'Al-Isra',
    'Al-Kahf',
    'Maryam',
    'Ta-Ha',
    'Al-Anbiya',
    'Al-Hajj',
    'Al-Muminun',
    'An-Nur',
    'Al-Furqan',
    'Ash-Shuara',
    'An-Naml',
    'Al-Qasas',
    'Al-Ankabut',
    'Ar-Rum',
    'Luqman',
    'As-Sajdah',
    'Al-Ahzab',
    'Saba',
    'Fatir',
    'Ya-Sin',
    'As-Saffat',
    'Sad',
    'Az-Zumar',
    'Ghafir',
    'Fussilat',
    'Ash-Shura',
    'Az-Zukhruf',
    'Ad-Dukhan',
    'Al-Jathiyah',
    'Al-Ahqaf',
    'Muhammad',
    'Al-Fath',
    'Al-Hujurat',
    'Qaf',
    'Adh-Dhariyat',
    'At-Tur',
    'An-Najm',
    'Al-Qamar',
    'Ar-Rahman',
    'Al-Waqiah',
    'Al-Hadid',
    'Al-Mujadila',
    'Al-Hashr',
    'Al-Mumtahanah',
    'As-Saff',
    'Al-Jumuah',
    'Al-Munafiqun',
    'At-Taghabun',
    'At-Talaq',
    'At-Tahrim',
    'Al-Mulk',
    'Al-Qalam',
    'Al-Haqqah',
    'Al-Maarij',
    'Nuh',
    'Al-Jinn',
    'Al-Muzzammil',
    'Al-Muddaththir',
    'Al-Qiyamah',
    'Al-Insan',
    'Al-Mursalat',
    'An-Naba',
    'An-Naziat',
    'Abasa',
    'At-Takwir',
    'Al-Infitar',
    'Al-Mutaffifin',
    'Al-Inshiqaq',
    'Al-Buruj',
    'At-Tariq',
    'Al-Ala',
    'Al-Ghashiyah',
    'Al-Fajr',
    'Al-Balad',
    'Ash-Shams',
    'Al-Lail',
    'Ad-Duha',
    'Ash-Sharh',
    'At-Tin',
    'Al-Alaq',
    'Al-Qadr',
    'Al-Bayyinah',
    'Az-Zalzalah',
    'Al-Adiyat',
    'Al-Qariah',
    'At-Takathur',
    'Al-Asr',
    'Al-Humazah',
    'Al-Fil',
    'Quraish',
    'Al-Maun',
    'Al-Kawthar',
    'Al-Kafirun',
    'An-Nasr',
    'Al-Masad',
    'Al-Ikhlas',
    'Al-Falaq',
    'An-Nas'
  ];

  @override
  void initState() {
    super.initState();
    _loadReciter();
    _player.setLoopMode(LoopMode.off);
    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (!mounted || index == _currentAyahIndex) return;
      setState(() => _currentAyahIndex = index);
      unawaited(_saveCurrentAyah(index));
    });
  }

  Future<void> _loadReciter() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedReciter = prefs.getString('reciter');
    setState(() {
      _selectedReciter =
          _reciters.containsKey(savedReciter) ? savedReciter! : 'ar.alafasy';
    });
    final savedSurah = prefs.getInt('quran_audio_surah');
    final savedAyah = prefs.getInt('quran_audio_ayah') ?? 0;
    if (savedSurah == null || savedSurah < 1 || savedSurah > 114) return;

    try {
      if (_player.audioSource == null) {
        await _playAudio(
          savedSurah,
          initialAyahIndex: savedAyah,
          autoPlay: false,
        );
      } else {
        final ayahs =
            await _audioService.getSurahAyahs(savedSurah, _selectedReciter);
        if (!mounted) return;
        setState(() {
          _currentSurah = savedSurah;
          _currentAyahs = ayahs;
          _currentAyahIndex = _player.currentIndex ??
              savedAyah.clamp(0, ayahs.length - 1).toInt();
        });
      }
    } catch (error, stackTrace) {
      debugPrint(
          'Could not restore Quran playback details: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserFriendlyError.audio(error))),
        );
      }
    }
  }

  Future<void> _saveCurrentAyah(int? index) async {
    if (index == null) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('quran_audio_ayah', index);
    } catch (error, stackTrace) {
      debugPrint('Could not save the current Quran ayah: $error\n$stackTrace');
    }
  }

  Future<void> _saveReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reciter', reciter);
    if (!mounted) return;
    setState(() => _selectedReciter = reciter);
    final currentSurah = _currentSurah;
    if (currentSurah != null) {
      await _playAudio(
        currentSurah,
        initialAyahIndex: _currentAyahIndex ?? 0,
      );
    }
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }

  Future<void> _playAudio(
    int surahNumber, {
    int initialAyahIndex = 0,
    bool autoPlay = true,
  }) async {
    if (!mounted) return;

    try {
      await _player.stop();
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _currentSurah = surahNumber;
        _currentAyahs = const [];
        _currentAyahIndex = null;
      });

      final ayahs = await _audioService.getSurahAyahs(
        surahNumber,
        _selectedReciter,
      );
      if (initialAyahIndex < 0 || initialAyahIndex >= ayahs.length) {
        throw RangeError.range(
          initialAyahIndex,
          0,
          ayahs.length - 1,
          'initialAyahIndex',
        );
      }
      final source = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: ayahs.map((ayah) {
          return AudioSource.uri(
            ayah.audioUrl,
            tag: MediaItem(
              id: 'quran-$surahNumber-${ayah.numberInSurah}-$_selectedReciter',
              album: 'Quran recitation',
              title:
                  '${_surahNames[surahNumber - 1]} · Ayah ${ayah.numberInSurah}',
              artist: _reciters[_selectedReciter]!,
            ),
          );
        }).toList(),
      );
      await _player.setAudioSource(
        source,
        initialIndex: initialAyahIndex,
      );
      if (!mounted) return;
      setState(() {
        _currentAyahs = ayahs;
        _currentAyahIndex = initialAyahIndex;
        _isLoading = false;
      });
      await _savePlaybackSelection(surahNumber, initialAyahIndex);
      if (autoPlay) unawaited(_startPlayback());
    } catch (e, stackTrace) {
      debugPrint('Could not load Quran recitation: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentSurah = null;
          _currentAyahs = const [];
          _currentAyahIndex = null;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserFriendlyError.audio(e))),
        );
      }
    }
  }

  Future<void> _savePlaybackSelection(int surahNumber, int ayahIndex) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('quran_audio_surah', surahNumber);
      await preferences.setInt('quran_audio_ayah', ayahIndex);
    } catch (error, stackTrace) {
      debugPrint('Could not save the selected Quran recitation: '
          '$error\n$stackTrace');
    }
  }

  Future<void> _startPlayback() async {
    try {
      await _player.play();
    } catch (e, stackTrace) {
      debugPrint('Quran audio playback failed: $e\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFriendlyError.audio(e))),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _seekToAyah(int index) async {
    if (index < 0 || index >= _currentAyahs.length) return;
    await _player.seek(Duration.zero, index: index);
    if (!mounted) return;
    setState(() => _currentAyahIndex = index);
    unawaited(_startPlayback());
  }

  Future<void> _changePlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
    if (mounted) setState(() => _playbackSpeed = speed);
  }

  Future<void> _toggleLoopMode() async {
    final nextMode = switch (_loopMode) {
      LoopMode.off => LoopMode.one,
      LoopMode.one => LoopMode.all,
      LoopMode.all => LoopMode.off,
    };
    await _player.setLoopMode(nextMode);
    if (mounted) setState(() => _loopMode = nextMode);
  }

  void _showAyahPicker() {
    if (_currentAyahs.isEmpty || _currentSurah == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${context.tr('Select Ayah')} · '
                  '${_surahNames[_currentSurah! - 1]}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _currentAyahs.length,
                  itemBuilder: (context, index) {
                    final ayah = _currentAyahs[index];
                    final selected = index == _currentAyahIndex;
                    return ListTile(
                      selected: selected,
                      leading:
                          CircleAvatar(child: Text('${ayah.numberInSurah}')),
                      title: Text(
                        ayah.text,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          height: 1.8,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _seekToAyah(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaybackSpeedMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr('Playback speed'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final speed in [0.75, 1.0, 1.25, 1.5, 2.0])
              ListTile(
                title: Text('$speed×'),
                trailing:
                    speed == _playbackSpeed ? const Icon(Icons.check) : null,
                onTap: () {
                  Navigator.pop(context);
                  _changePlaybackSpeed(speed);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Reciter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reciters.entries
              .map((e) => RadioListTile<String>(
                    title: Text(e.value),
                    value: e.key,
                    groupValue: _selectedReciter,
                    onChanged: (val) {
                      if (val != null) {
                        unawaited(_saveReciter(val));
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const ArabicLabel('Audio Quran - آڈیو قرآن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.graphic_eq),
            tooltip: context.tr('Select Reciter'),
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
                  color: isPlaying
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isPlaying ? Theme.of(context).primaryColor : null,
                      child: Text(
                        '$surahNumber',
                        style: TextStyle(
                          color: isPlaying
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                    title: Text(_surahNames[index],
                        style: TextStyle(
                            fontWeight: isPlaying ? FontWeight.bold : null)),
                    subtitle: Text(
                      '${context.tr('Surah')} $surahNumber'
                      '${isPlaying && _currentAyahIndex != null && _currentAyahIndex! >= 0 && _currentAyahIndex! < _currentAyahs.length ? ' · ${context.tr('Ayah')} ${_currentAyahs[_currentAyahIndex!].numberInSurah}' : ''}',
                    ),
                    trailing: _isLoading && isPlaying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : StreamBuilder<PlayerState>(
                            stream: _player.playerStateStream,
                            builder: (context, snapshot) {
                              final playing = isPlaying &&
                                  (snapshot.data?.playing ?? false);
                              return IconButton(
                                icon: Icon(
                                  playing
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                ),
                                color: Theme.of(context).primaryColor,
                                iconSize: 32,
                                onPressed: () {
                                  if (playing) {
                                    _player.pause();
                                  } else if (isPlaying) {
                                    unawaited(_startPlayback());
                                  } else {
                                    _playAudio(surahNumber);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          if (_currentSurah != null) _buildPlayer(context, theme),
        ],
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, ThemeData theme) {
    final ayahIndex = _currentAyahIndex;
    final ayah =
        ayahIndex != null && ayahIndex >= 0 && ayahIndex < _currentAyahs.length
            ? _currentAyahs[ayahIndex]
            : null;
    final expandedHeight =
        (MediaQuery.of(context).size.height * 0.53).clamp(300.0, 440.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      height: _isPlayerExpanded ? expandedHeight : 76,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                '${_currentSurah!}',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(
              _surahNames[_currentSurah! - 1],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${_reciters[_selectedReciter]}'
              '${ayah == null ? '' : ' · ${context.tr('Ayah')} ${ayah.numberInSurah}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: context.tr(
                _isPlayerExpanded ? 'Collapse player' : 'Expand player',
              ),
              icon: Icon(
                _isPlayerExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
              ),
              onPressed: () =>
                  setState(() => _isPlayerExpanded = !_isPlayerExpanded),
            ),
          ),
          if (_isPlayerExpanded)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    if (ayah != null)
                      Card(
                        color: theme.colorScheme.primaryContainer
                            .withOpacity(0.42),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showAyahPicker,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${context.tr('Ayah')} ${ayah.numberInSurah}',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${ayahIndex! + 1}/${_currentAyahs.length}',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.playlist_play,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ArabicText(
                                  ayah.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 27,
                                    height: 1.9,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr('Tap the verse to choose an Ayah'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const LinearProgressIndicator(),
                    StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: _player.durationStream,
                          builder: (context, durationSnapshot) {
                            final duration =
                                durationSnapshot.data ?? Duration.zero;
                            final maxSeconds = duration.inSeconds > 0
                                ? duration.inSeconds.toDouble()
                                : 1.0;
                            return Column(
                              children: [
                                Slider(
                                  value: position.inSeconds
                                      .toDouble()
                                      .clamp(0.0, maxSeconds)
                                      .toDouble(),
                                  max: maxSeconds,
                                  onChanged: duration.inSeconds > 0
                                      ? (value) => _player.seek(
                                            Duration(
                                              seconds: value.toInt(),
                                            ),
                                          )
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(position)),
                                      Text(_formatDuration(duration)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: context.tr('Previous Ayah'),
                          icon: const Icon(Icons.skip_previous),
                          onPressed: ayahIndex != null && ayahIndex > 0
                              ? () => _seekToAyah(ayahIndex - 1)
                              : null,
                        ),
                        StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return IconButton(
                              tooltip: context.tr(
                                playing ? 'Pause' : 'Play',
                              ),
                              icon: Icon(
                                playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              iconSize: 58,
                              color: theme.colorScheme.primary,
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (playing) {
                                        _player.pause();
                                      } else {
                                        _startPlayback();
                                      }
                                    },
                            );
                          },
                        ),
                        IconButton(
                          tooltip: context.tr('Next Ayah'),
                          icon: const Icon(Icons.skip_next),
                          onPressed: ayahIndex != null &&
                                  ayahIndex < _currentAyahs.length - 1
                              ? () => _seekToAyah(ayahIndex + 1)
                              : null,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: context.tr('Previous Surah'),
                          icon: const Icon(Icons.first_page),
                          onPressed: _currentSurah! > 1
                              ? () => _playAudio(_currentSurah! - 1)
                              : null,
                        ),
                        IconButton(
                          tooltip: context.tr('Select Ayah'),
                          icon: const Icon(Icons.format_list_numbered),
                          onPressed: _showAyahPicker,
                        ),
                        IconButton(
                          tooltip: context.tr('Select Reciter'),
                          icon: const Icon(Icons.graphic_eq),
                          onPressed: _showReciterDialog,
                        ),
                        IconButton(
                          tooltip: context.tr('Playback speed'),
                          onPressed: _showPlaybackSpeedMenu,
                          icon: Text(
                            '$_playbackSpeed×',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: context.tr(switch (_loopMode) {
                            LoopMode.off => 'Repeat off',
                            LoopMode.one => 'Repeat Ayah',
                            LoopMode.all => 'Repeat Surah',
                          }),
                          icon: Icon(switch (_loopMode) {
                            LoopMode.off => Icons.repeat,
                            LoopMode.one => Icons.repeat_one,
                            LoopMode.all => Icons.repeat,
                          }),
                          color: _loopMode == LoopMode.off
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                          onPressed: _toggleLoopMode,
                        ),
                        IconButton(
                          tooltip: context.tr('Next Surah'),
                          icon: const Icon(Icons.last_page),
                          onPressed: _currentSurah! < 114
                              ? () => _playAudio(_currentSurah! + 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
