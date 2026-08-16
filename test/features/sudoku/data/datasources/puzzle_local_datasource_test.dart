import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/data/datasources/puzzle_local_datasource.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';

import '../../../../fakes/fake_services.dart';

GameState _buildGameState({int? saveVersion}) {
  final grid = List.generate(9, (i) => List.generate(9, (j) => 0));
  final solution = List.generate(
    9,
    (i) => List.generate(9, (j) => ((i + j) % 9) + 1),
  );
  final puzzle = Puzzle(
    id: 'test-puzzle',
    grid: grid,
    solution: solution,
    difficulty: 'easy',
    cluesCount: 30,
    createdAt: DateTime(2026, 1, 1),
  );

  var state = GameState(
    puzzleId: puzzle.id,
    puzzle: puzzle,
    userGrid: grid,
    notes: List.generate(9, (_) => List.generate(9, (_) => <int>{})),
    timeElapsed: 42,
    mistakes: 1,
    hintsUsed: 0,
    penaltyTime: 0,
    moveHistory: const [],
    redoStack: const [],
    status: GameStatus.playing,
    lastPlayed: DateTime(2026, 1, 1),
    difficulty: Difficulty.easy,
    selectedCell: null,
    selectedNumber: null,
    isNoteMode: false,
    highlightedCells: const {},
    conflictCells: const {},
    hintState: null,
    lastSaved: DateTime(2026, 1, 1),
  );
  if (saveVersion != null) {
    state = state.copyWith(saveVersion: saveVersion);
  }
  return state;
}

void main() {
  group('PuzzleLocalDataSource game state save format', () {
    test('saveGameState stamps the current save version', () async {
      final ds = PuzzleLocalDataSource(FakeStorageService());
      await ds.saveGameState(_buildGameState(saveVersion: 999));

      final result = await ds.getGameState();
      final loaded = result.fold((f) => throw Exception(f.message), (s) => s);

      expect(loaded, isNotNull);
      expect(loaded!.saveVersion, GameState.currentSaveVersion);
    });

    test('round-trips the rest of the game state correctly', () async {
      final ds = PuzzleLocalDataSource(FakeStorageService());
      final original = _buildGameState();
      await ds.saveGameState(original);

      final result = await ds.getGameState();
      final loaded = result.fold((f) => throw Exception(f.message), (s) => s);

      expect(loaded!.puzzleId, original.puzzleId);
      expect(loaded.timeElapsed, original.timeElapsed);
      expect(loaded.mistakes, original.mistakes);
      expect(loaded.status, original.status);
    });

    test(
      'discards a save with a mismatched version instead of loading it',
      () async {
        final storage = FakeStorageService();
        final ds = PuzzleLocalDataSource(storage);

        // Simulate a save written by an older/newer app version by writing
        // valid JSON directly, bypassing saveGameState's version stamping.
        final staleJson =
            _buildGameState(
              saveVersion: GameState.currentSaveVersion + 1,
            ).toJson();
        await storage.setString('game_state', jsonEncode(staleJson));

        final result = await ds.getGameState();
        final loaded = result.fold((f) => throw Exception(f.message), (s) => s);
        expect(loaded, isNull);

        // The stale entry should have been cleared, not just skipped.
        expect(storage.getString('game_state'), isNull);
      },
    );

    test('discards corrupt JSON and clears it', () async {
      final storage = FakeStorageService();
      final ds = PuzzleLocalDataSource(storage);

      await storage.setString('game_state', '{not valid json');

      final result = await ds.getGameState();
      expect(result.isLeft(), true);
      expect(storage.getString('game_state'), isNull);
    });

    test('getGameState returns null when nothing has been saved', () async {
      final ds = PuzzleLocalDataSource(FakeStorageService());
      final result = await ds.getGameState();
      final loaded = result.fold((f) => throw Exception(f.message), (s) => s);
      expect(loaded, isNull);
    });
  });
}
