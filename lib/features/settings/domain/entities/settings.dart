import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(true) bool soundEnabled,
    @Default(true) bool hapticsEnabled,
    @Default(true) bool autoNotes,
    @Default(true) bool highlightErrors,
    @Default(true) bool showTimer,
    @Default(true) bool showHints,
    @Default(true) bool autoClearNotes,
    @Default(true) bool highlightRegions,
    @Default(false) bool numberFirstInput,
    @Default('easy') String selectedDifficulty,
    @Default(3) int maxHints,
    @Default(50) int maxUndoHistory,
    @Default(100) int maxPuzzleHistory,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> saveSettings(Settings settings);
  Future<Either<Failure, void>> resetSettings();
}
