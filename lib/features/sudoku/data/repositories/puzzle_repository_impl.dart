import 'package:dartz/dartz.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../datasources/puzzle_local_datasource.dart';
import '../../core/errors/failures.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  PuzzleRepositoryImpl(this._dataSource);

  final PuzzleLocalDataSource _dataSource;

  @override
  Future<Either<Failure, Puzzle>> generatePuzzle(String difficulty) {
    return _dataSource.generatePuzzle(difficulty);
  }

  @override
  Future<Either<Failure, Puzzle>> getPuzzle(String id) {
    return _dataSource.getCurrentPuzzle().then(
          (result) => result.fold(
            (failure) => Left(failure),
            (puzzle) => puzzle != null
                ? Right(puzzle)
                : Left(NotFoundFailure('Puzzle not found')),
          ),
        );
  }

  @override
  Future<Either<Failure, void>> savePuzzle(Puzzle puzzle) {
    return _dataSource.savePuzzle(puzzle);
  }

  @override
  Future<Either<Failure, Puzzle?>> getCurrentPuzzle() {
    return _dataSource.getCurrentPuzzle();
  }

  @override
  Future<Either<Failure, void>> saveGameState(GameState state) {
    return _dataSource.saveGameState(state);
  }

  @override
  Future<Either<Failure, GameState?>> getGameState() {
    return _dataSource.getGameState();
  }

  @override
  Future<Either<Failure, void>> clearGameState() {
    return _dataSource.clearGameState();
  }

  @override
  Future<Either<Failure, List<Puzzle>>> getPuzzleHistory() {
    return _dataSource.getPuzzleHistory();
  }

  @override
  Future<Either<Failure, void>> savePuzzleToHistory(Puzzle puzzle) {
    return _dataSource.savePuzzleToHistory(puzzle);
  }
}
