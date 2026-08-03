import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m6_sudoku/core/audio/audio_manager.dart';
import 'package:m6_sudoku/features/settings/presentation/providers/settings_provider.dart';

final audioManagerProvider = Provider<AudioManager>((ref) {
  return AudioManager.instance;
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final audioManager = ref.read(audioManagerProvider);
  final settings = ref.read(settingsProvider);

  // Sync mute state with settings
  audioManager.setMuted(!settings.soundEnabled);

  return AudioService(audioManager);
});

class AudioService {
  AudioService(this._audioManager);

  final AudioManager _audioManager;

  Future<void> initialize() async {
    await _audioManager.initialize();
  }

  void playClick() => _audioManager.play(SoundType.buttonClick);
  void playWin() => _audioManager.play(SoundType.win);
  void playError() => _audioManager.play(SoundType.error);
  void playHint() => _audioManager.play(SoundType.hint);
  void playPause() => _audioManager.play(SoundType.pause);
  void playResume() => _audioManager.play(SoundType.resume);

  void setMuted(bool muted) => _audioManager.setMuted(muted);
  void setVolume(double volume) => _audioManager.setVolume(volume);

  bool get isMuted => _audioManager.isMuted;
  double get volume => _audioManager.volume;
}
