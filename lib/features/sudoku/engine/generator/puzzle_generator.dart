import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';
import '../models/board.dart';
import '../solver/sudoku_solver.dart';

class PuzzleGenerator {
  PuzzleGenerator({this.seed});

  final int? seed;

  Board generateCompleteGrid() {
    final board = Board();
    SudokuSolver.solve(board);
    return board;
  }

  Board generatePuzzle({int clues = 30, int maxAttempts = 100}) {
    final fullGrid = generateCompleteGrid();
    return _removeClues(fullGrid, clues, maxAttempts);
  }

  Board _removeClues(Board fullGrid, int targetClues, int maxAttempts) {
    Board bestBoard = fullGrid.copy();
    int bestClues = 81;

    final random = _FastRandom(seed);
    final positions = List<int>.generate(81, (i) => i);
    final solution = fullGrid.toGrid();

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

        if (_hasUniqueSolutionFast(board, solution)) {
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

  /// Fast uniqueness check using the known solution as reference.
  /// Tries to find a solution different from the known one.
  bool _hasUniqueSolutionFast(Board board, List<List<int>> knownSolution) {
    return !_findDifferentSolution(board, knownSolution, 0);
  }

  /// Attempts to find a solution different from the known one.
  /// Returns true if a different solution exists.
  bool _findDifferentSolution(Board board, List<List<int>> knownSolution, int index) {
    if (index >= 81) {
      // Found a complete solution - check if it's different from known
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (board.getValue(r, c) != knownSolution[r][c]) {
            return true; // Different solution found
          }
        }
      }
      return false; // Same solution
    }

    final row = index ~/ 9;
    final col = index % 9;

    if (board.getValue(row, col) != 0) {
      return _findDifferentSolution(board, knownSolution, index + 1);
    }

    final candidates = board.getCandidates(row, col);
    
    // Try candidates that differ from known solution first (more likely to find alternative)
    final knownValue = knownSolution[row][col];
    final orderedCandidates = <int>[];
    
    // First try values different from known solution
    for (final v in candidates) {
      if (v != knownValue) orderedCandidates.add(v);
    }
    // Then try the known value
    if (candidates.contains(knownValue)) {
      orderedCandidates.add(knownValue);
    }

    for (final value in orderedCandidates) {
      board.setValue(row, col, value);
      if (_findDifferentSolution(board, knownSolution, index + 1)) {
        board.setValue(row, col, 0);
        return true;
      }
      board.setValue(row, col, 0);
    }

    return false;
  }

  Board generatePuzzleWithDifficulty(Difficulty difficulty) {
    int clues;
    int maxAttempts;
    switch (difficulty) {
      case Difficulty.easy:
        clues = 36;
        maxAttempts = 50;
        break;
      case Difficulty.medium:
        clues = 30;
        maxAttempts = 80;
        break;
      case Difficulty.hard:
        clues = 26;
        maxAttempts = 100;
        break;
      case Difficulty.expert:
        clues = 22;
        maxAttempts = 150;
        break;
      case Difficulty.evil:
        clues = 20;
        maxAttempts = 200;
        break;
    }
    return generatePuzzle(clues: clues, maxAttempts: maxAttempts);
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
