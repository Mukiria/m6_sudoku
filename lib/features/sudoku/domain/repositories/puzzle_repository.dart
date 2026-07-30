import 'package:dartz/dartz.dart';
import '../entities/game_entities.dart';
import '../../core/errors/failures.dart';

abstract class PuzzleRepository {
  Future<Either<Failure, Puzzle>> generatePuzzle(String difficulty);

  Future<Either<Failure, Puzzle>> getPuzzle(String id);

  Future<Either<Failure, void>> savePuzzle(Puzzle puzzle);

  Future<Either<Failure, Puzzle?>> getCurrentPuzzle();

  Future<Either<Failure, void>> saveGameState(GameState state);

  Future<Either<Failure, GameState?>> getGameState();

  Future<Either<Failure, void>> clearGameState();

  Future<Either<Failure, List<Puzzle>>> getPuzzleHistory();

  Future<Either<Failure, void>> savePuzzleToHistory(Puzzle puzzle);
}
