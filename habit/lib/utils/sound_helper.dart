import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  
  static Future<void> playCompletionSound() async {
    // In production, load from assets/sounds/completion.mp3
    await _player.setAsset('assets/sounds/completion.mp3');
    await _player.play();
  }
  
  static Future<void> playGoalAchievedSound() async {
    await _player.setAsset('assets/sounds/goal.mp3');
    await _player.play();
  }
  
  static Future<void> playAlarmSound(String tone) async {
    String assetPath;
    switch (tone) {
      case 'Sabah kuşu':
        assetPath = 'assets/sounds/morning_bird.mp3';
        break;
      default:
        assetPath = 'assets/sounds/default_alarm.mp3';
    }
    await _player.setAsset(assetPath);
    await _player.play();
  }
  
  static Future<void> vibrate() async {
    if (await Vibration.hasVibrator() == true) {
      await Vibration.vibrate(duration: 50);
    }
  }
  
  static void dispose() {
    _player.dispose();
  }
}