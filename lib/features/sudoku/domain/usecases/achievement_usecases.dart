import 'package:dartz/dartz.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/achievement.dart';
import 'package:m6_sudoku/features/sudoku/domain/repositories/achievement_repository.dart';
import 'package:m6_sudoku/core/errors/failures.dart';

class GetAchievementsUseCase {
  GetAchievementsUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, List<Achievement>>> call() {
    return _repository.getAchievements();
  }
}

class UnlockAchievementUseCase {
  UnlockAchievementUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, void>> call(String id) {
    return _repository.unlockAchievement(id);
  }
}

class UpdateAchievementProgressUseCase {
  UpdateAchievementProgressUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, void>> call(String id, int progress) {
    return _repository.updateProgress(id, progress);
  }
}

class IncrementAchievementProgressUseCase {
  IncrementAchievementProgressUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, void>> call(String id, int amount) {
    return _repository.incrementProgress(id, amount);
  }
}

class GetUnlockedAchievementsUseCase {
  GetUnlockedAchievementsUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, List<Achievement>>> call() {
    return _repository.getUnlockedAchievements();
  }
}

class GetLockedAchievementsUseCase {
  GetLockedAchievementsUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<Failure, List<Achievement>>> call() {
    return _repository.getLockedAchievements();
  }
}