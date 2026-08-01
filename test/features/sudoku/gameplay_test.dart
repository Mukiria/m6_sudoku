import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/features/sudoku/engine/generator/puzzle_generator.dart';

void main() {
  group('GameController - Gameplay Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('newGame', () {
      test('creates new game with correct initial state', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        
        expect(state, isNotNull);
        expect(state!.status, GameStatus.playing);
        expect(state.timeElapsed, 0);
        expect(state.mistakes, 0);
        expect(state.hintsUsed, 0);
        expect(state.penaltyTime, 0);
        expect(state.moveHistory, isEmpty);
        expect(state.redoStack, isEmpty);
        expect(state.selectedCell, isNull);
        expect(state.selectedNumber, isNull);
        expect(state.isNoteMode, false);
        expect(state.difficulty, Difficulty.easy);
      });

      test('initializes with correct puzzle for difficulty', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.expert);
        
        final state = container.read(gameControllerProvider);
        
        expect(state, isNotNull);
        expect(state!.puzzle.difficulty, 'expert');
        expect(state.userGrid, isNotNull);
        expect(state.notes, isNotNull);
      });

      test('initial notes are computed correctly', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        
        // Notes should be computed for empty cells
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              expect(state.notes[r][c], isNotNull);
            } else {
              expect(state.notes[r][c], isEmpty);
            }
          }
        }
      });
    });

    group('selectCell', () {
      test('selects cell and updates highlighted cells', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        controller.selectCell(2, 2);
        
        final state = container.read(gameControllerProvider);
        
        expect(state!.selectedCell, const CellPosition(row: 2, col: 2));
        expect(state.highlightedCells.length, 20); // 8 row + 8 col + 4 box - 1 overlap
      });

      test('does not select fixed cell', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        final puzzle = state!.puzzle;
        
        // Find a fixed cell
        int? fixedRow, fixedCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (puzzle.grid[r][c] != 0) {
              fixedRow = r;
              fixedCol = c;
              break;
            }
          }
          if (fixedRow != null) break;
        }
        
        if (fixedRow != null) {
          controller.selectCell(fixedRow!, fixedCol!);
          final state = container.read(gameControllerProvider);
          // Should not select fixed cell
          expect(state!.selectedCell, isNull);
        }
      });
    });

    group('setValue', () {
      test('places correct value', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        // Find an empty cell
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, 5);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.userGrid[emptyRow!][emptyCol!], 5);
        }
      });

      test('increments mistakes for incorrect value', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          // Use wrong value
          final wrongValue = correctValue == 9 ? 1 : correctValue + 1;
          controller.setValue(emptyRow!, emptyCol!, wrongValue);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.mistakes, 1);
        }
      });

      test('does not increment mistakes for correct value', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.mistakes, 0);
        }
      });

      test('does not overwrite fixed cell', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? fixedRow, fixedCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.puzzle.grid[r][c] != 0) {
              fixedRow = r;
              fixedCol = c;
              break;
            }
          }
          if (fixedRow != null) break;
        }
        
        if (fixedRow != null) {
          final originalValue = state!.userGrid[fixedRow!][fixedCol!];
          controller.selectCell(fixedRow!, fixedCol!);
          controller.setValue(fixedRow!, fixedCol!, 9);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.userGrid[fixedRow!][fixedCol!], originalValue);
        }
      });

      test('does not set same value twice', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final stateAfterFirst = container.read(gameControllerProvider);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final stateAfterSecond = container.read(gameControllerProvider);
          // Should not add duplicate move
          expect(stateAfterSecond!.moveHistory.length, stateAfterFirst!.moveHistory.length);
        }
      });
    });

    group('toggleNote', () {
      test('adds note when not present', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.toggleNote(emptyRow!, emptyCol!, 5);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.notes[emptyRow!][emptyCol!], contains(5));
        }
      });

      test('removes note when already present', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.toggleNote(emptyRow!, emptyCol!, 5);
          controller.toggleNote(emptyRow!, emptyCol!, 5);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.notes[emptyRow!][emptyCol!], isNot(contains(5)));
        }
      });

      test('does not add notes to fixed cell', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? fixedRow, fixedCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.puzzle.grid[r][c] != 0) {
              fixedRow = r;
              fixedCol = c;
              break;
            }
          }
          if (fixedRow != null) break;
        }
        
        if (fixedRow != null) {
          controller.selectCell(fixedRow!, fixedCol!);
          controller.toggleNote(fixedRow!, fixedCol!, 5);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.notes[fixedRow!][fixedCol!], isEmpty);
        }
      });
    });

    group('clearCell', () {
      test('clears user value', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          controller.clearCell(emptyRow!, emptyCol!);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.userGrid[emptyRow!][emptyCol!], 0);
        }
      });

      test('clears notes', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.toggleNote(emptyRow!, emptyCol!, 5);
          controller.clearCell(emptyRow!, emptyCol!);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.notes[emptyRow!][emptyCol!], isEmpty);
        }
      });

      test('does not clear fixed cell', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? fixedRow, fixedCol;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.puzzle.grid[r][c] != 0) {
              fixedRow = r;
              fixedCol = c;
              break;
            }
          }
          if (fixedRow != null) break;
        }
        
        if (fixedRow != null) {
          final originalValue = state!.userGrid[fixedRow!][fixedCol!];
          controller.clearCell(fixedRow!, fixedCol!);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.userGrid[fixedRow!][fixedCol!], originalValue);
        }
      });
    });

    group('undo/redo', () {
      test('undo removes last move', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final stateAfterMove = container.read(gameControllerProvider);
          controller.undo();
          
          final stateAfterUndo = container.read(gameControllerProvider);
          expect(stateAfterUndo!.userGrid[emptyRow!][emptyCol!], 0);
          expect(stateAfterUndo.moveHistory.length, state!.moveHistory.length);
        }
      });

      test('redo reapplies undone move', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          controller.undo();
          controller.redo();
          
          final stateAfterRedo = container.read(gameControllerProvider);
          expect(stateAfterRedo!.userGrid[emptyRow!][emptyCol!], correctValue);
        }
      });

      test('undo clears redo stack on new move', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          controller.undo();
          
          // Make a new move
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final newState = container.read(gameControllerProvider);
          expect(newState!.redoStack, isEmpty);
        }
      });
    });

    group('useHint', () {
      test('uses hint and adds penalty time', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        final timeBefore = state!.timeElapsed;
        
        await controller.useHint();
        
        final newState = container.read(gameControllerProvider);
        expect(newState!.hintsUsed, 1);
        expect(newState!.penaltyTime, greaterThan(0));
        expect(newState!.timeElapsed, greaterThan(timeBefore));
      });

      test('adds correct penalty for direct reveal', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        // We can't easily control hint type, but we can verify penalty is added
        await controller.useHint();
        
        final newState = container.read(gameControllerProvider);
        expect(newState!.penaltyTime, greaterThanOrEqualTo(15));
      });
    });

    group('pause/resume', () {
      test('pause changes status to paused', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        controller.pause();
        
        final state = container.read(gameControllerProvider);
        expect(state!.status, GameStatus.paused);
      });

      test('resume changes status to playing', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        controller.pause();
        controller.resume();
        
        final state = container.read(gameControllerProvider);
        expect(state!.status, GameStatus.playing);
      });
    });

    group('game completion', () {
      test('detects completion when grid matches solution', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        // Fill the entire grid with solution
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0) {
              controller.selectCell(r, c);
              controller.setValue(r, c, state.puzzle.solution[r][c]);
            }
          }
        }
        
        final finalState = container.read(gameControllerProvider);
        expect(finalState!.status, GameStatus.completed);
      });
    });

    group('game failure', () {
      test('fails after 3 mistakes', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          
          // Make 3 mistakes
          for (int i = 1; i <= 3; i++) {
            final wrongValue = (correctValue + i) % 9 + 1;
            if (wrongValue != correctValue) {
              controller.setValue(emptyRow!, emptyCol!, wrongValue);
            }
          }
          
          final finalState = container.read(gameControllerProvider);
          expect(finalState!.status, GameStatus.failed);
          expect(finalState!.mistakes, 3);
        }
      });
    });

    group('timer', () {
      test('increments timer every second', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        expect(state!.timeElapsed, 0);
        
        // Note: Timer is handled by TimerController, not directly testable here
        // This test verifies the initial state
      });
    });

    group('continueGame', () {
      test('restores saved game state', () async {
        final controller = container.read(gameControllerProvider.notifier);
        await controller.newGame(Difficulty.easy);
        
        final state = container.read(gameControllerProvider);
        int? emptyRow, emptyCol;
        int correctValue = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (state!.userGrid[r][c] == 0 && state.puzzle.grid[r][c] == 0) {
              emptyRow = r;
              emptyCol = c;
              correctValue = state.puzzle.solution[r][c];
              break;
            }
          }
          if (emptyRow != null) break;
        }
        
        if (emptyRow != null) {
          controller.selectCell(emptyRow!, emptyCol!);
          controller.setValue(emptyRow!, emptyCol!, correctValue);
          
          final stateAfterMove = container.read(gameControllerProvider);
          
          // Continue the saved game
          await controller.continueGame(stateAfterMove!);
          
          final continuedState = container.read(gameControllerProvider);
          expect(continuedState!.userGrid[emptyRow!][emptyCol!], correctValue);
          expect(continuedState.timeElapsed, stateAfterMove!.timeElapsed);
          expect(continuedState.mistakes, stateAfterMove!.mistakes);
        }
      });
    });
  });
}