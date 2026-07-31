import 'package:dartz/dartz.dart';
import '../entities/settings.dart';
import 'package:m6_sudoku/core/errors/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> saveSettings(Settings settings);
  Future<Either<Failure, void>> resetSettings();
}
