import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.autoNotes = true,
    this.highlightErrors = true,
    this.showTimer = true,
    this.showHints = true,
    this.autoClearNotes = true,
    this.highlightRegions = true,
    this.numberFirstInput = false,
    this.selectedDifficulty = 'easy',
    this.maxHints = 3,
    this.maxUndoHistory = 50,
    this.maxPuzzleHistory = 100,
  });

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool autoNotes;
  final bool highlightErrors;
  final bool showTimer;
  final bool showHints;
  final bool autoClearNotes;
  final bool highlightRegions;
  final bool numberFirstInput;
  final String selectedDifficulty;
  final int maxHints;
  final int maxUndoHistory;
  final int maxPuzzleHistory;

  Settings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? autoNotes,
    bool? highlightErrors,
    bool? showTimer,
    bool? showHints,
    bool? autoClearNotes,
    bool? highlightRegions,
    bool? numberFirstInput,
    String? selectedDifficulty,
    int? maxHints,
    int? maxUndoHistory,
    int? maxPuzzleHistory,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      autoNotes: autoNotes ?? this.autoNotes,
      highlightErrors: highlightErrors ?? this.highlightErrors,
      showTimer: showTimer ?? this.showTimer,
      showHints: showHints ?? this.showHints,
      autoClearNotes: autoClearNotes ?? this.autoClearNotes,
      highlightRegions: highlightRegions ?? this.highlightRegions,
      numberFirstInput: numberFirstInput ?? this.numberFirstInput,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      maxHints: maxHints ?? this.maxHints,
      maxUndoHistory: maxUndoHistory ?? this.maxUndoHistory,
      maxPuzzleHistory: maxPuzzleHistory ?? this.maxPuzzleHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'autoNotes': autoNotes,
      'highlightErrors': highlightErrors,
      'showTimer': showTimer,
      'showHints': showHints,
      'autoClearNotes': autoClearNotes,
      'highlightRegions': highlightRegions,
      'numberFirstInput': numberFirstInput,
      'selectedDifficulty': selectedDifficulty,
      'maxHints': maxHints,
      'maxUndoHistory': maxUndoHistory,
      'maxPuzzleHistory': maxPuzzleHistory,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      soundEnabled: json['soundEnabled'] ?? true,
      hapticsEnabled: json['hapticsEnabled'] ?? true,
      autoNotes: json['autoNotes'] ?? true,
      highlightErrors: json['highlightErrors'] ?? true,
      showTimer: json['showTimer'] ?? true,
      showHints: json['showHints'] ?? true,
      autoClearNotes: json['autoClearNotes'] ?? true,
      highlightRegions: json['highlightRegions'] ?? true,
      numberFirstInput: json['numberFirstInput'] ?? false,
      selectedDifficulty: json['selectedDifficulty'] ?? 'easy',
      maxHints: json['maxHints'] ?? 3,
      maxUndoHistory: json['maxUndoHistory'] ?? 50,
      maxPuzzleHistory: json['maxPuzzleHistory'] ?? 100,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        soundEnabled,
        hapticsEnabled,
        autoNotes,
        highlightErrors,
        showTimer,
        showHints,
        autoClearNotes,
        highlightRegions,
        numberFirstInput,
        selectedDifficulty,
        maxHints,
        maxUndoHistory,
        maxPuzzleHistory,
      ];
}

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> saveSettings(Settings settings);
  Future<Either<Failure, void>> resetSettings();
}
