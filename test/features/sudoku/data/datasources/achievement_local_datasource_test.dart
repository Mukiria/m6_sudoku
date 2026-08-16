import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/data/datasources/achievement_local_datasource.dart';

import '../../../../fakes/fake_services.dart';

void main() {
  group('AchievementLocalDataSource.incrementProgress', () {
    test('returns null while progress stays below target', () async {
      final ds = AchievementLocalDataSource(FakeStorageService());

      // 'ten_wins' has targetValue 10; a single increment shouldn't unlock it.
      final result = await ds.incrementProgress('ten_wins', 1);

      expect(result.isRight(), true);
      expect(result.fold((f) => throw Exception(f.message), (a) => a), isNull);

      final achievements = (await ds.getAchievements()).fold(
        (f) => throw Exception(f.message),
        (list) => list,
      );
      final tenWins = achievements.firstWhere((a) => a.id == 'ten_wins');
      expect(tenWins.currentProgress, 1);
      expect(tenWins.isUnlocked, false);
    });

    test(
      'returns the unlocked achievement exactly on the call that crosses the target',
      () async {
        final ds = AchievementLocalDataSource(FakeStorageService());

        // 'first_win' has targetValue 1, so the first call unlocks it.
        final result = await ds.incrementProgress('first_win', 1);

        final unlocked = result.fold(
          (f) => throw Exception(f.message),
          (a) => a,
        );
        expect(unlocked, isNotNull);
        expect(unlocked!.id, 'first_win');
        expect(unlocked.isUnlocked, true);
        expect(unlocked.unlockedAt, isNotNull);
      },
    );

    test('returns null for every call after the achievement is unlocked', () async {
      final ds = AchievementLocalDataSource(FakeStorageService());

      final first = await ds.incrementProgress('first_win', 1);
      expect(
        first.fold((f) => throw Exception(f.message), (a) => a),
        isNotNull,
      );

      final second = await ds.incrementProgress('first_win', 1);
      expect(
        second.fold((f) => throw Exception(f.message), (a) => a),
        isNull,
      );
    });

    test('clamps progress at targetValue and unlocks exactly once for multi-step achievements', () async {
      final ds = AchievementLocalDataSource(FakeStorageService());

      // 'ten_wins' has targetValue 10.
      for (var i = 0; i < 9; i++) {
        final result = await ds.incrementProgress('ten_wins', 1);
        expect(
          result.fold((f) => throw Exception(f.message), (a) => a),
          isNull,
        );
      }

      final unlockResult = await ds.incrementProgress('ten_wins', 1);
      final unlocked = unlockResult.fold(
        (f) => throw Exception(f.message),
        (a) => a,
      );
      expect(unlocked, isNotNull);
      expect(unlocked!.currentProgress, 10);

      final overflowResult = await ds.incrementProgress('ten_wins', 5);
      expect(
        overflowResult.fold((f) => throw Exception(f.message), (a) => a),
        isNull,
      );
    });
  });
}
