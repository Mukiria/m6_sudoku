import 'package:dartz/dartz.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';
import '../../core/errors/failures.dart';

class GetStatisticsUseCase {
  GetStatisticsUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<Either<Failure, Statistics>> call() {
    return _repository.getStatistics();
  }
}

class UpdateStatisticsUseCase {
  UpdateStatisticsUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<Either<Failure, void>> call(Statistics statistics) {
    return _repository.updateStatistics(statistics);
  }
}

class AddGameRecordUseCase {
  AddGameRecordUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<Either<Failure, void>> call(GameRecord record) {
    return _repository.addGameRecord(record);
  }
}

class ResetStatisticsUseCase {
  ResetStatisticsUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.resetStatistics();
  }
}

class GetRecentGamesUseCase {
  GetRecentGamesUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<Either<Failure, List<GameRecord>>> call({int limit = 10}) {
    return _repository.getRecentGames(limit: limit);
  }
}
