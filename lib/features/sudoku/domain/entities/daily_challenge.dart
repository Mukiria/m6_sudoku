import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';

part 'daily_challenge.freezed.dart';
part 'daily_challenge.g.dart';

@freezed
class DailyChallenge with _$DailyChallenge {
  const factory DailyChallenge({
    required String date,
    required Puzzle puzzle,
    required bool isCompleted,
    required int? timeElapsed,
    required int? mistakes,
    required int? hintsUsed,
    DateTime? completedAt,
  }) = _DailyChallenge;

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeFromJson(json);
}

@freezed
class DailyChallengeStats with _$DailyChallengeStats {
  const factory DailyChallengeStats({
    required int totalPlayed,
    required int totalCompleted,
    required int currentStreak,
    required int bestStreak,
    required DateTime? lastPlayedDate,
  }) = _DailyChallengeStats;

  factory DailyChallengeStats.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeStatsFromJson(json);
}
