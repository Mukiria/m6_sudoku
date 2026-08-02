import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/core/errors/failures.dart';
import 'package:m6_sudoku/core/services/storage_service.dart';

class PuzzleLocalDataSource {
  PuzzleLocalDataSource(this._storage);

  final StorageService _storage;
  int _solutions = 0;

  static const String _puzzleKey = 'current_puzzle';
  static const String _gameStateKey = 'game_state';
  static const String _historyKey = 'puzzle_history';
  static const String _cacheKey = 'puzzle_cache_';
  static const int _maxCachedPuzzlesPerDifficulty = 10;

  Future<Either<Failure, Puzzle>> generatePuzzle(String difficulty) async {
    try {
      // Try to get a cached puzzle first
      final cached = await _getCachedPuzzle(difficulty);
      if (cached != null) {
        await _storage.setString(_puzzleKey, jsonEncode(cached.toJson()));
        return Right(cached);
      }

      // Generate new puzzle if no cache available
      final puzzle = _generatePuzzleForDifficulty(difficulty);
      await _storage.setString(_puzzleKey, jsonEncode(puzzle.toJson()));
      await _cachePuzzle(puzzle);
      return Right(puzzle);
    } catch (e) {
      return Left(PuzzleGenerationFailure('Failed to generate puzzle: $e'));
    }
  }

  Future<Puzzle?> _getCachedPuzzle(String difficulty) async {
    try {
      final jsonString = _storage.getString('$_cacheKey$difficulty');
      if (jsonString == null) return null;
      final list = jsonDecode(jsonString) as List;
      if (list.isEmpty) return null;
      final map = list.removeAt(0) as Map<String, dynamic>;
      await _storage.setString('$_cacheKey$difficulty', jsonEncode(list));
      return Puzzle.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cachePuzzle(Puzzle puzzle) async {
    try {
      final jsonString = _storage.getString('$_cacheKey${puzzle.difficulty}');
      final list = jsonString != null ? jsonDecode(jsonString) as List : <dynamic>[];
      list.insert(0, puzzle.toJson());
      if (list.length > _maxCachedPuzzlesPerDifficulty) {
        list.removeRange(_maxCachedPuzzlesPerDifficulty, list.length);
      }
      await _storage.setString('$_cacheKey${puzzle.difficulty}', jsonEncode(list));
    } catch (_) {
      // Silently fail caching
    }
  }

  Future<Either<Failure, Puzzle?>> getCurrentPuzzle() async {
    try {
      final jsonString = _storage.getString(_puzzleKey);
      if (jsonString == null) return const Right(null);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Right(Puzzle.fromJson(map));
    } catch (e) {
      return Left(CacheFailure('Failed to get current puzzle: $e'));
    }
  }

  Future<Either<Failure, void>> savePuzzle(Puzzle puzzle) async {
    try {
      await _storage.setString(_puzzleKey, jsonEncode(puzzle.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to save puzzle: $e'));
    }
  }

  Future<Either<Failure, GameState?>> getGameState() async {
    try {
      final jsonString = _storage.getString(_gameStateKey);
      if (jsonString == null) return const Right(null);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Right(GameState.fromJson(map));
    } catch (e) {
      return Left(CacheFailure('Failed to get game state: $e'));
    }
  }

  Future<Either<Failure, void>> saveGameState(GameState state) async {
    try {
      await _storage.setString(_gameStateKey, jsonEncode(state.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to save game state: $e'));
    }
  }

  Future<Either<Failure, void>> clearGameState() async {
    try {
      await _storage.remove(_gameStateKey);
      await _storage.remove(_puzzleKey);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to clear game state: $e'));
    }
  }

  Future<Either<Failure, List<Puzzle>>> getPuzzleHistory() async {
    try {
      final jsonString = _storage.getString(_historyKey);
      if (jsonString == null) return const Right([]);
      final list = jsonDecode(jsonString) as List;
      return Right(
        list.map((e) => Puzzle.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get puzzle history: $e'));
    }
  }

  Future<Either<Failure, void>> savePuzzleToHistory(Puzzle puzzle) async {
    try {
      final historyResult = await getPuzzleHistory();
      return historyResult.fold((failure) => Left(failure), (history) {
        final updated = [puzzle, ...history].take(100).toList();
        _storage.setString(
          _historyKey,
          jsonEncode(updated.map((p) => p.toJson()).toList()),
        );
        return const Right(null);
      });
    } catch (e) {
      return Left(StorageFailure('Failed to save puzzle to history: $e'));
    }
  }

  Puzzle _generatePuzzleForDifficulty(String difficulty) {
    final cluesCount = _getCluesForDifficulty(difficulty);
    final solution = _generateSolution();
    final grid = _removeNumbers(solution, cluesCount);

    return Puzzle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      grid: grid,
      solution: solution,
      difficulty: difficulty,
      cluesCount: cluesCount,
      createdAt: DateTime.now(),
    );
  }

  int _getCluesForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 36;
      case 'medium':
        return 30;
      case 'hard':
        return 26;
      case 'expert':
        return 22;
      default:
        return 30;
    }
  }

  List<List<int>> _generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    final numbers = List.generate(9, (i) => i + 1);
    numbers.shuffle(Random());

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (final num in numbers) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) {
                return true;
              }
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int c = 0; c < 9; c++) {
      if (grid[row][c] == num) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  List<List<int>> _removeNumbers(List<List<int>> solution, int cluesCount) {
    final grid = List.generate(9, (r) => List<int>.from(solution[r]));
    final cells = List<int>.generate(81, (i) => i)..shuffle(Random());

    int removed = 0;
    final toRemove = 81 - cluesCount;

    for (final cellIndex in cells) {
      if (removed >= toRemove) break;

      final row = cellIndex ~/ 9;
      final col = cellIndex % 9;

      if (grid[row][col] != 0) {
        final backup = grid[row][col];
        grid[row][col] = 0;

        if (_hasUniqueSolution(grid)) {
          removed++;
        } else {
          grid[row][col] = backup;
        }
      }
    }

    return grid;
  }

  bool _hasUniqueSolution(List<List<int>> grid) {
    _solutions = 0;
    _countSolutions(grid);
    return _solutions == 1;
  }

  void _countSolutions(List<List<int>> grid) {
    if (_solutions > 1) return;

    int? emptyRow;
    int? emptyCol;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          emptyRow = r;
          emptyCol = c;
          break;
        }
      }
      if (emptyRow != null) break;
    }

    if (emptyRow == null) {
      _solutions++;
      return;
    }

    for (int num = 1; num <= 9; num++) {
      if (_isValid(grid, emptyRow!, emptyCol!, num)) {
        grid[emptyRow!][emptyCol!] = num;
        _countSolutions(grid);
        grid[emptyRow!][emptyCol!] = 0;
        if (_solutions > 1) return;
      }
    }
  }
}
