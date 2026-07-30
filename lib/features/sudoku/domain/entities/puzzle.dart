import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'puzzle.freezed.dart';
part 'puzzle.g.dart';

@freezed
class Puzzle with _$Puzzle {
  const factory Puzzle({
    required String id,
    required List<List<int>> grid,
    required List<List<int>> solution,
    required String difficulty,
    required int cluesCount,
    required DateTime createdAt,
    int? timeElapsed,
    int? mistakes,
    int? hintsUsed,
    bool? isCompleted,
  }) = _Puzzle;

  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  const Puzzle._();

  bool get isValid => _isValidGrid(grid);

  List<int> get flatGrid => grid.expand((row) => row).toList();

  List<int> get flatSolution => solution.expand((row) => row).toList();

  int get filledCount => flatGrid.where((v) => v != 0).length;

  bool get isComplete => filledCount == 81 && _isValidGrid(grid);

  bool _isValidGrid(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      final rowSet = <int>{};
      final colSet = <int>{};
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] != 0) {
          if (rowSet.contains(grid[i][j])) return false;
          rowSet.add(grid[i][j]);
        }
        if (grid[j][i] != 0) {
          if (colSet.contains(grid[j][i])) return false;
          colSet.add(grid[j][i]);
        }
      }
    }

    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final boxSet = <int>{};
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final val = grid[boxRow * 3 + i][boxCol * 3 + j];
            if (val != 0) {
              if (boxSet.contains(val)) return false;
              boxSet.add(val);
            }
          }
        }
      }
    }
    return true;
  }
}

@freezed
class GameState with _$GameState {
  const factory GameState({
    required String puzzleId,
    required List<List<int>> userGrid,
    required List<List<Set<int>>> notes,
    required int timeElapsed,
    required int mistakes,
    required int hintsUsed,
    required List<Move> moveHistory,
    required GameStatus status,
    required DateTime lastPlayed,
    required Difficulty difficulty,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  const GameState._();

  int get filledCount =>
      userGrid.expand((row) => row).where((v) => v != 0).length;

  bool get isComplete => filledCount == 81;

  int get progressPercentage => (filledCount / 81 * 100).round();
}

@freezed
class Move with _$Move {
  const factory Move({
    required int row,
    required int col,
    required int? previousValue,
    required int? newValue,
    required MoveType type,
    required DateTime timestamp,
  }) = _Move;

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
}

enum MoveType {
  value,
  note,
  hint,
  undo,
  clear,
}

enum GameStatus {
  playing,
  paused,
  completed,
  failed,
}

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
}

extension DifficultyExtension on Difficulty {
  static Difficulty fromString(String s) {
    switch (s.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      case 'expert':
        return Difficulty.expert;
      default:
        return Difficulty.medium;
    }
  }

  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.medium:
        return 'medium';
      case Difficulty.hard:
        return 'hard';
      case Difficulty.expert:
        return 'expert';
    }
  }

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  int get cluesCount {
    switch (this) {
      case Difficulty.easy:
        return 36;
      case Difficulty.medium:
        return 30;
      case Difficulty.hard:
        return 26;
      case Difficulty.expert:
        return 22;
    }
  }
}
