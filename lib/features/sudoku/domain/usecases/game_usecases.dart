import 'package:dartz/dartz.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/core/errors/failures.dart';
import 'package:m6_sudoku/features/sudoku/domain/repositories/puzzle_repository.dart';

class HintCell {
  const HintCell({
    required this.row,
    required this.col,
    required this.value,
    required this.isFixed,
  });

  final int row;
  final int col;
  final int value;
  final bool isFixed;
}

class GeneratePuzzleUseCase {
  GeneratePuzzleUseCase(this._repository);

  final PuzzleRepository _repository;

  Future<Either<Failure, Puzzle>> call(String difficulty) {
    return _repository.generatePuzzle(difficulty);
  }
}

class ValidateMoveUseCase {
  ValidateMoveUseCase();

  Either<Failure, bool> call({
    required List<List<int>> grid,
    required int row,
    required int col,
    required int value,
  }) {
    if (value < 1 || value > 9) {
      return const Left(ValidationFailure('Value must be between 1 and 9'));
    }

    if (row < 0 || row >= 9 || col < 0 || col >= 9) {
      return const Left(ValidationFailure('Invalid cell position'));
    }

    if (grid[row][col] != 0) {
      return const Left(ValidationFailure('Cell is already filled'));
    }

    for (int c = 0; c < 9; c++) {
      if (c != col && grid[row][c] == value) {
        return const Right(false);
      }
    }

    for (int r = 0; r < 9; r++) {
      if (r != row && grid[r][col] == value) {
        return const Right(false);
      }
    }

    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;

    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (r != row && c != col && grid[r][c] == value) {
          return const Right(false);
        }
      }
    }

    return const Right(true);
  }
}

class CheckCompletionUseCase {
  CheckCompletionUseCase();

  Either<Failure, bool> call({
    required List<List<int>> grid,
    required List<List<int>> solution,
  }) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] != solution[r][c]) {
          return const Right(false);
        }
      }
    }
    return const Right(true);
  }
}

class GetHintUseCase {
  GetHintUseCase(this._repository);

  final PuzzleRepository _repository;

  Future<Either<Failure, HintCell?>> call({required GameState state}) async {
    final puzzle = state.puzzle;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (state.userGrid[r][c] == 0 && puzzle.grid[r][c] == 0) {
          final solutionValue = puzzle.solution[r][c];
          return Right(HintCell(
            row: r,
            col: c,
            value: solutionValue,
            isFixed: false,
          ));
        }
      }
    }
    return const Right(null);
  }
}

class GetGameStateUseCase {
  GetGameStateUseCase(this._repository);

  final PuzzleRepository _repository;

  Future<Either<Failure, GameState?>> call() {
    return _repository.getGameState();
  }
}

class SaveGameStateUseCase {
  SaveGameStateUseCase(this._repository);

  final PuzzleRepository _repository;

  Future<Either<Failure, void>> call(GameState state) {
    return _repository.saveGameState(state);
  }
}
