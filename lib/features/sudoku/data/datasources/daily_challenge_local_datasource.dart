import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/daily_challenge.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/board.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';
import 'package:m6_sudoku/features/sudoku/engine/generator/puzzle_generator.dart';
import 'package:m6_sudoku/core/errors/failures.dart';
import 'package:m6_sudoku/core/services/storage_service.dart';

class DailyChallengeLocalDataSource {
  DailyChallengeLocalDataSource(this._storage);

  final StorageService _storage;

  static const String _dailyChallengeKey = 'daily_challenge_';
  static const String _dailyStatsKey = 'daily_challenge_stats';

  Future<Either<Failure, DailyChallenge>> getOrGenerateDailyChallenge() async {
    final today = _getTodayDateString();
    
    // Check if today's challenge already exists
    final existing = await _getDailyChallenge(today);
    if (existing != null) {
      return Right(existing);
    }

    // Generate new puzzle for today
    final puzzle = _generateDailyPuzzle(today);
    final challenge = DailyChallenge(
      date: today,
      puzzle: puzzle,
      isCompleted: false,
      timeElapsed: null,
      mistakes: null,
      hintsUsed: null,
    );

    await _saveDailyChallenge(challenge);
    return Right(challenge);
  }

  Future<DailyChallenge?> _getDailyChallenge(String date) async {
    try {
      final jsonString = _storage.getString('$_dailyChallengeKey$date');
      if (jsonString == null) return null;
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return DailyChallenge.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveDailyChallenge(DailyChallenge challenge) async {
    await _storage.setString(
      '$_dailyChallengeKey${challenge.date}',
      jsonEncode(challenge.toJson()),
    );
  }

  Future<Either<Failure, void>> completeDailyChallenge({
    required String date,
    required int timeElapsed,
    required int mistakes,
    required int hintsUsed,
  }) async {
    try {
      final existing = await _getDailyChallenge(date);
      if (existing == null) {
        return Left(NotFoundFailure('Daily challenge not found'));
      }
      if (existing.isCompleted) {
        return Left(ValidationFailure('Daily challenge already completed'));
      }

      final completed = existing.copyWith(
        isCompleted: true,
        timeElapsed: timeElapsed,
        mistakes: mistakes,
        hintsUsed: hintsUsed,
        completedAt: DateTime.now(),
      );

      await _saveDailyChallenge(completed);
      await _updateStats(completed);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to complete daily challenge: $e'));
    }
  }

  Future<void> _updateStats(DailyChallenge challenge) async {
    try {
      final stats = await _getStats();
      final newStats = stats.copyWith(
        totalPlayed: stats.totalPlayed + 1,
        totalCompleted: stats.totalCompleted + (challenge.isCompleted ? 1 : 0),
        currentStreak: challenge.isCompleted ? stats.currentStreak + 1 : 0,
        bestStreak: challenge.isCompleted && (stats.currentStreak + 1) > stats.bestStreak
            ? stats.currentStreak + 1
            : stats.bestStreak,
        lastPlayedDate: DateTime.now(),
      );
      await _storage.setString(_dailyStatsKey, jsonEncode(newStats.toJson()));
    } catch (_) {
      // Silently fail
    }
  }

  Future<DailyChallengeStats> _getStats() async {
    try {
      final jsonString = _storage.getString(_dailyStatsKey);
      if (jsonString == null) return _defaultStats();
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return DailyChallengeStats.fromJson(map);
    } catch (_) {
      return _defaultStats();
    }
  }

  DailyChallengeStats _defaultStats() {
    return const DailyChallengeStats(
      totalPlayed: 0,
      totalCompleted: 0,
      currentStreak: 0,
      bestStreak: 0,
      lastPlayedDate: null,
    );
  }

  Future<Either<Failure, DailyChallengeStats>> getStats() async {
    return Right(await _getStats());
  }

  Future<bool> isDailyChallengeCompleted(String date) async {
    final challenge = await _getDailyChallenge(date);
    return challenge?.isCompleted ?? false;
  }

  Puzzle _generateDailyPuzzle(String date) {
    // Generate deterministic seed from date
    final seed = _dateToSeed(date);
    
    // Use the puzzle generator with seed
    final generator = PuzzleGenerator(seed: seed);
    final board = generator.generatePuzzleWithDifficulty(Difficulty.medium);
    
    // Convert board to puzzle format
    final grid = List.generate(9, (r) => List.generate(9, (c) => board.getValue(r, c)));
    final solution = _getSolutionFromBoard(board);
    
    return Puzzle(
      id: 'daily_$date',
      grid: grid,
      solution: solution,
      difficulty: 'medium',
      cluesCount: board.getFilledCount,
      createdAt: DateTime.now(),
    );
  }

  int _dateToSeed(String date) {
    // Convert YYYY-MM-DD to integer seed
    final parts = date.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    // Create deterministic seed: YYYYMMDD
    return year * 10000 + month * 100 + day;
  }

  List<List<int>> _getSolutionFromBoard(Board board) {
    return List.generate(9, (r) => List.generate(9, (c) => board.getValue(r, c)));
  }

  String _getTodayDateString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}