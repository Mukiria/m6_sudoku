import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/settings.dart';
import '../domain/usecases/settings_usecases.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, Settings>((ref) {
  return SettingsController(ref);
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
});

class SettingsController extends StateNotifier<Settings> {
  SettingsController(this._ref) : super(const Settings()) {
    _loadSettings();
  }

  final Ref _ref;

  Future<void> _loadSettings() async {
    final getSettings = _ref.read(getSettingsUseCaseProvider);
    final result = await getSettings();
    result.fold(
      (failure) => debugPrint('Failed to load settings: $failure'),
      (settings) => state = settings,
    );
  }

  Future<void> updateThemeMode(String themeMode) async {
    final newSettings = state.copyWith(themeMode: themeMode);
    await _saveSettings(newSettings);
  }

  Future<void> updateDifficulty(String difficulty) async {
    final newSettings = state.copyWith(selectedDifficulty: difficulty);
    await _saveSettings(newSettings);
  }

  Future<void> toggleSound(bool enabled) async {
    final newSettings = state.copyWith(soundEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleHaptics(bool enabled) async {
    final newSettings = state.copyWith(hapticsEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleAutoNotes(bool enabled) async {
    final newSettings = state.copyWith(autoNotes: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleHighlightErrors(bool enabled) async {
    final newSettings = state.copyWith(highlightErrors: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleShowTimer(bool enabled) async {
    final newSettings = state.copyWith(showTimer: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleShowHints(bool enabled) async {
    final newSettings = state.copyWith(showHints: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleAutoClearNotes(bool enabled) async {
    final newSettings = state.copyWith(autoClearNotes: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleHighlightRegions(bool enabled) async {
    final newSettings = state.copyWith(highlightRegions: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleNumberFirstInput(bool enabled) async {
    final newSettings = state.copyWith(numberFirstInput: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> setMaxHintsPerGame(int value) async {
    final newSettings = state.copyWith(maxHintsPerGame: value.clamp(0, 10));
    await _saveSettings(newSettings);
  }

  Future<void> toggleAutoSave(bool enabled) async {
    final newSettings = state.copyWith(autoSave: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleShowMistakes(bool enabled) async {
    final newSettings = state.copyWith(showMistakes: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleHighlightRelated(bool enabled) async {
    final newSettings = state.copyWith(highlightRelated: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleAutoNotesEnabled(bool enabled) async {
    final newSettings = state.copyWith(autoNotesEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleHapticFeedbackEnabled(bool enabled) async {
    final newSettings = state.copyWith(hapticFeedbackEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleSoundEffectsEnabled(bool enabled) async {
    final newSettings = state.copyWith(soundEffectsEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> toggleAutoSaveEnabled(bool enabled) async {
    final newSettings = state.copyWith(autoSaveEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(Settings settings) async {
    final saveSettings = _ref.read(saveSettingsUseCaseProvider);
    final result = await saveSettings(settings);
    result.fold(
      (failure) => debugPrint('Failed to save settings: $failure'),
      (_) => state = settings,
    );
  }

  Future<void> resetToDefaults() async {
    final resetSettings = _ref.read(resetSettingsUseCaseProvider);
    final result = await resetSettings();
    result.fold(
      (failure) => debugPrint('Failed to reset settings: $failure'),
      (_) => state = const Settings(),
    );
  }
}
