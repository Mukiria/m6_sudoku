import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../core/services/storage_service.dart';
import '../../core/errors/failures.dart';

class StatisticsLocalDataSource {
  StatisticsLocalDataSource(this._storage);

  final StorageService _storage;

  static const String _statsKey = 'statistics';
  static const String _gamesKey = 'game_records';

  Future<Either<Failure, Statistics>> getStatistics() async {
    try {
      final jsonString = _storage.getString(_statsKey);
      if (jsonString == null) {
        return Right(_defaultStatistics());
      }
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Right(Statistics.fromJson(map));
    } catch (e) {
      return Left(CacheFailure('Failed to get statistics: $e'));
    }
  }

  Future<Either<Failure, void>> updateStatistics(Statistics statistics) async {
    try {
      await _storage.setString(_statsKey, jsonEncode(statistics.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to update statistics: $e'));
    }
  }

  Future<Either<Failure, void>> addGameRecord(GameRecord record) async {
    try {
      final gamesResult = await getRecentGames();
      final games = gamesResult.fold((_) => <GameRecord>[], (g) => g);
      final updatedGames = [record, ...games].take(100).toList();
      await _storage.setString(
        _gamesKey,
        jsonEncode(updatedGames.map((g) => g.toJson()).toList()),
      );
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to add game record: $e'));
    }
  }

  Future<Either<Failure, List<GameRecord>>> getRecentGames(
      {int limit = 10}) async {
    try {
      final jsonString = _storage.getString(_gamesKey);
      if (jsonString == null) return const Right([]);
      final list = jsonDecode(jsonString) as List;
      final games = list
          .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(games.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get recent games: $e'));
    }
  }

  Future<Either<Failure, void>> resetStatistics() async {
    try {
      await _storage.remove(_statsKey);
      await _storage.remove(_gamesKey);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to reset statistics: $e'));
    }
  }

  Statistics _defaultStatistics() {
    return Statistics(
      gamesPlayed: 0,
      gamesWon: 0,
      currentStreak: 0,
      bestStreak: 0,
      totalTimeSeconds: 0,
      hintsUsed: 0,
      mistakesMade: 0,
      bestTimesByDifficulty: {},
      gamesWonByDifficulty: {},
      gamesPlayedByDifficulty: {},
      lastPlayed: null,
    );
  }
}
