import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m6_sudoku/core/services/storage_service.dart';
import 'package:m6_sudoku/features/sudoku/data/datasources/puzzle_local_datasource.dart';
import 'package:m6_sudoku/features/sudoku/data/repositories/puzzle_repository_impl.dart';
import 'package:m6_sudoku/features/sudoku/domain/repositories/puzzle_repository.dart';
import 'package:m6_sudoku/features/sudoku/domain/usecases/game_usecases.dart';
import 'package:m6_sudoku/features/sudoku/engine/generator/puzzle_generator.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize storage service in main.dart');
});

final puzzleGeneratorProvider = Provider<PuzzleGenerator>((ref) {
  return PuzzleGenerator();
});

final puzzleLocalDataSourceProvider = Provider<PuzzleLocalDataSource>((ref) {
  final storage = ref.read(storageServiceProvider);
  return PuzzleLocalDataSource(storage);
});

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  final dataSource = ref.read(puzzleLocalDataSourceProvider);
  return PuzzleRepositoryImpl(dataSource);
});

final generatePuzzleUseCaseProvider = Provider<GeneratePuzzleUseCase>((ref) {
  final repo = ref.read(puzzleRepositoryProvider);
  return GeneratePuzzleUseCase(repo);
});

final getGameStateUseCaseProvider = Provider<GetGameStateUseCase>((ref) {
  final repo = ref.read(puzzleRepositoryProvider);
  return GetGameStateUseCase(repo);
});

final saveGameStateUseCaseProvider = Provider<SaveGameStateUseCase>((ref) {
  final repo = ref.read(puzzleRepositoryProvider);
  return SaveGameStateUseCase(repo);
});

final validateMoveUseCaseProvider = Provider<ValidateMoveUseCase>((ref) {
  return ValidateMoveUseCase();
});

final checkCompletionUseCaseProvider = Provider<CheckCompletionUseCase>((ref) {
  return CheckCompletionUseCase();
});

final getHintUseCaseProvider = Provider<GetHintUseCase>((ref) {
  final repo = ref.read(puzzleRepositoryProvider);
  return GetHintUseCase(repo);
});