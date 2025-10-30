import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  late final AudioPlayer _player;
  late final Source _taskCompleted;

  AudioManager._internal() {
    _player = AudioPlayer();
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    _taskCompleted = AssetSource('audio/task_completed.mp3');
    // Pre-cache by setting the source early
    await _player.setSource(_taskCompleted);
    await _player.setVolume(1.0);
  }

  Future<void> playTaskCompleted() async {
    try {
      await _player.resume();
    } catch (e) {
      print("Audio playback error: $e");
    }
  }
}
