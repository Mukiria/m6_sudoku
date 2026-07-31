import '../models/board.dart';

class UniqueSolutionValidator {
  static bool hasUniqueSolution(Board board) {
    final counter = _SolutionCounter();
    _countSolutions(board, counter, limit: 2);
    return counter.count == 1;
  }

  static void _countSolutions(
    Board board,
    _SolutionCounter counter, {
    int limit = 2,
  }) {
    if (counter.count >= limit) return;

    int index = -1;
    for (var i = 0; i < 81; i++) {
      final row = i ~/ 9;
      final col = i % 9;
      if (board.getValue(row, col) == 0) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      counter.count++;
      return;
    }

    final row = index ~/ 9;
    final col = index % 9;
    final candidates = board.getCandidates(row, col);

    for (final value in candidates) {
      board.setValue(row, col, value);
      _countSolutions(board, counter, limit: limit);
      board.setValue(row, col, 0);
      if (counter.count >= limit) return;
    }
  }

  static int countSolutions(Board board, {int maxCount = 100}) {
    final counter = _SolutionCounter();
    _countSolutions(board, counter, limit: maxCount);
    return counter.count;
  }

  static bool hasExactlyOneSolution(Board board) {
    return countSolutions(board, maxCount: 2) == 1;
  }
}

class _SolutionCounter {
  int count = 0;
}
