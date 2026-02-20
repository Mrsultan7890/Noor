import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSound(String sound) async {
    try {
      await _player.play(AssetSource('sounds/$sound.mp3'));
    } catch (e) {
      // Silently fail if sound not found
    }
  }

  static Future<void> playClick() => playSound('button_click');
  static Future<void> playCorrect() => playSound('correct');
  static Future<void> playWrong() => playSound('wrong');
  static Future<void> playLevelComplete() => playSound('level_complete');
  static Future<void> playStarCollect() => playSound('star_collect');
  static Future<void> playCardFlip() => playSound('card_flip');
}
