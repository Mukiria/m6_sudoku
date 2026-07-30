import 'package:dartz/dartz.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';
import '../../core/errors/failures.dart';

class GetSettingsUseCase {
  GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, Settings>> call() {
    return _repository.getSettings();
  }
}

class SaveSettingsUseCase {
  SaveSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(Settings settings) {
    return _repository.saveSettings(settings);
  }
}

class ResetSettingsUseCase {
  ResetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.resetSettings();
  }
}
