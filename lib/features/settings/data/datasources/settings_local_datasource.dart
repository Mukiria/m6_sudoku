import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:m6_sudoku/core/services/storage_service.dart';
import 'package:m6_sudoku/core/errors/failures.dart';
import '../../domain/entities/settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._storage);

  final StorageService _storage;

  static const String _settingsKey = 'game_settings';

  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final jsonString = _storage.getString(_settingsKey);
      if (jsonString == null) {
        return Right(_defaultSettings());
      }
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Right(Settings.fromJson(map));
    } catch (e) {
      return Left(CacheFailure('Failed to get settings: $e'));
    }
  }

  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    try {
      await _storage.setString(_settingsKey, jsonEncode(settings.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to save settings: $e'));
    }
  }

  Future<Either<Failure, void>> resetSettings() async {
    try {
      await _storage.remove(_settingsKey);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to reset settings: $e'));
    }
  }

  Settings _defaultSettings() {
    return Settings(
      themeMode: ThemeMode.system,
      soundEnabled: true,
      hapticsEnabled: true,
      autoNotes: true,
      highlightErrors: true,
      showTimer: true,
      showHints: true,
      autoClearNotes: true,
      highlightRegions: true,
      numberFirstInput: false,
    );
  }
}
