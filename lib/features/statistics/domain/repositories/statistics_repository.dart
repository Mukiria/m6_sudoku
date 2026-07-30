import 'package:dartz/dartz.dart';
import '../entities/settings.dart';
import '../../core/errors/failures.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, Statistics>> getStatistics();

  Future<Either<Failure, void>> updateStatistics(Statistics statistics);

  Future<Either<Failure, void>> addGameRecord(GameRecord record);

  Future<Either<Failure, void>> resetStatistics();

  Future<Either<Failure, List<GameRecord>>> getRecentGames({int limit = 10});
}
