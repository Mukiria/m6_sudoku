import '../models/board.dart';
import '../models/cell.dart';
import '../validator/unique_solution_validator.dart';
import '../solver/sudoku_solver.dart';

class PuzzleGenerator {
  PuzzleGenerator({this.seed});

  final int? seed;

  Board generateCompleteGrid() {
    final board = Board();
    SudokuSolver.solve(board);
    return board;
  }

  Board generatePuzzle({
    int clues = 30,
    int maxAttempts = 100,
  }) {
    final fullGrid = generateCompleteGrid();
    return _removeClues(fullGrid, clues, maxAttempts);
  }

  Board _removeClues(Board fullGrid, int targetClues, int maxAttempts) {
    Board bestBoard = fullGrid.copy();
    int bestClues = 81;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final board = fullGrid.copy();
      final positions = List<int>.generate(81, (i) => i)..shuffle();

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
}

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  evil;
}

extension ListShuffle<T> on List<T> {
  void shuffle() {
    for (var i = length - 1; i > 0; i--) {
      final j = DateTime.now().microsecondsSinceEpoch % (i + 1);
      final temp = this[i];
      this[i] = this[j];
      this[j] = temp;
    }
  }
}
