import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';
import '../models/board.dart';
import '../validator/unique_solution_validator.dart';
import '../solver/sudoku_solver.dart';
import 'dart:math';

class PuzzleGenerator {
  PuzzleGenerator({this.seed});

  final int? seed;

  Board generateCompleteGrid() {
    final board = Board();
    SudokuSolver.solve(board);
    return board;
  }

  Board generatePuzzle({int clues = 30, int maxAttempts = 500}) {
    final fullGrid = generateCompleteGrid();
    return _removeClues(fullGrid, clues, maxAttempts);
  }

  Board _removeClues(Board fullGrid, int targetClues, int maxAttempts) {
    Board bestBoard = fullGrid.copy();
    int bestClues = 81;

    final random = _FastRandom(seed);
    final positions = List<int>.generate(81, (i) => i);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final board = fullGrid.copy();
      _shuffle(positions, random);

      int clues = 81;

      for (final pos in positions) {
        if (clues <= targetClues) break;

        final row = pos ~/ 9;
        final col = pos % 9;

        if (board.getValue(row, col) == 0) continue;

        final originalValue = board.getValue(row, col);
        board.setValue(row, col, 0);

        if (UniqueSolutionValidator.hasUniqueSolution(board)) {
          clues--;
        } else {
          board.setValue(row, col, originalValue);
        }
      }

      if (clues < bestClues) {
        bestClues = clues;
        bestBoard = board;
      }

      if (clues <= targetClues) break;
    }

    return bestBoard;
  }

  Board generatePuzzleWithDifficulty(Difficulty difficulty) {
    int clues;
    switch (difficulty) {
      case Difficulty.easy:
        clues = 36;
        break;
      case Difficulty.medium:
        clues = 30;
        break;
      case Difficulty.hard:
        clues = 26;
        break;
      case Difficulty.expert:
        clues = 22;
        break;
      case Difficulty.evil:
        clues = 20;
        break;
    }
    return generatePuzzle(clues: clues);
  }

  static void _shuffle(List<int> list, _FastRandom random) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}

class _FastRandom {
  int _seed;

  _FastRandom([int? seed]) : _seed = seed ?? DateTime.now().microsecondsSinceEpoch;

  int nextInt(int max) {
    _seed = (_seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_seed % max).abs();
  }
}