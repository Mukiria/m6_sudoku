import '../models/board.dart';
import '../models/cell.dart';

class SudokuSolver {
  static bool solve(Board board) {
    return _backtrack(board, 0);
  }

  static bool _backtrack(Board board, int index) {
    if (index >= 81) return true;

    final row = index ~/ 9;
    final col = index % 9;

    if (board.getValue(row, col) != 0) {
      return _backtrack(board, index + 1);
    }

    final candidates = board.getCandidates(row, col);
    _shuffle(candidates);

    for (final value in candidates) {
      board.setValue(row, col, value);
      if (_backtrack(board, index + 1)) return true;
      board.setValue(row, col, 0);
    }

    return false;
  }

  static List<int> _getEmptyCells(Board board) {
    final empty = <int>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board.getValue(r, c) == 0) {
          empty.add(r * 9 + c);
        }
      }
    }
    return empty;
  }

  static bool solveWithCandidates(Board board) {
    final emptyCells = _getEmptyCells(board);
    return _backtrackWithMRV(board, emptyCells);
  }

  static bool _backtrackWithMRV(Board board, List<int> emptyCells) {
    if (emptyCells.isEmpty) return true;

    emptyCells.sort((a, b) {
      final ca = board.getCandidates(a ~/ 9, a % 9).length;
      final cb = board.getCandidates(b ~/ 9, b % 9).length;
      return ca.compareTo(cb);
    });

    final index = emptyCells.removeAt(0);
    final row = index ~/ 9;
    final col = index % 9;

    final candidates = board.getCandidates(row, col);
    _shuffle(candidates);

    for (final value in candidates) {
      board.setValue(row, col, value);
      if (_backtrackWithMRV(board, emptyCells)) return true;
      board.setValue(row, col, 0);
    }

    emptyCells.insert(0, index);
    return false;
  }

  static void _shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = DateTime.now().microsecondsSinceEpoch % (i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
