import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  buttonClick,
  win,
  error,
  hint,
  pause,
  resume,
}

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  double _volume = 1.0;

  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(_volume);
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _player.setVolume(0);
    } else {
      _player.setVolume(_volume);
    }
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    if (!_isMuted) {
      _player.setVolume(_volume);
    }
  }

  Future<void> play(SoundType type) async {
    if (_isMuted) return;

    try {
      final assetPath = _getAssetPath(type);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Silently fail if sound file not found
      debugPrint('Failed to play sound: $e');
    }
  }

  String _getAssetPath(SoundType type) {
    switch (type) {
      case SoundType.buttonClick:
        return 'audio/click.mp3';
      case SoundType.win:
        return 'audio/win.mp3';
      case SoundType.error:
        return 'audio/error.mp3';
      case SoundType.hint:
        return 'audio/hint.mp3';
      case SoundType.pause:
        return 'audio/pause.mp3';
      case SoundType.resume:
        return 'audio/resume.mp3';
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}