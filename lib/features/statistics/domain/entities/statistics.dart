import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics.freezed.dart';
part 'statistics.g.dart';

@freezed
class Statistics with _$Statistics {
  const factory Statistics({
    required int gamesPlayed,
    required int gamesWon,
    required int currentStreak,
    required int bestStreak,
    required int totalTimeSeconds,
    required int hintsUsed,
    required int mistakesMade,
    required Map<String, int> bestTimesByDifficulty,
    required Map<String, int> gamesWonByDifficulty,
    required Map<String, int> gamesPlayedByDifficulty,
    required DateTime? lastPlayed,
  }) = _Statistics;

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);

  const Statistics._();

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;

  String get formattedTotalTime {
    final hours = totalTimeSeconds ~/ 3600;
    final minutes = (totalTimeSeconds % 3600) ~/ 60;
    final seconds = totalTimeSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String getAverageTime(int gamesWon, int totalTime) {
    if (gamesWon == 0) return 'N/A';
    final avgSeconds = totalTime ~/ gamesWon;
    final minutes = avgSeconds ~/ 60;
    final seconds = avgSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

@freezed
class GameRecord with _$GameRecord {
  const factory GameRecord({
    required String id,
    required DateTime date,
    required String difficulty,
    required int timeSeconds,
    required int mistakes,
    required int hintsUsed,
    required bool completed,
  }) = _GameRecord;

  factory GameRecord.fromJson(Map<String, dynamic> json) =>
      _$GameRecordFromJson(json);
}
