import 'package:dartz/dartz.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';
import 'settings_local_datasource.dart';
import '../../core/errors/failures.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<Either<Failure, Settings>> getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) {
    return _dataSource.saveSettings(settings);
  }

  @override
  Future<Either<Failure, void>> resetSettings() {
    return _dataSource.resetSettings();
  }
}
