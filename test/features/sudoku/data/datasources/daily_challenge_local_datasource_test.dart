import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/data/datasources/daily_challenge_local_datasource.dart';

import '../../../../fakes/fake_services.dart';

void main() {
  group('DailyChallengeLocalDataSource', () {
    test(
      'two independent stores generate the identical puzzle for today (same puzzle for everyone)',
      () async {
        final dsA = DailyChallengeLocalDataSource(FakeStorageService());
        final dsB = DailyChallengeLocalDataSource(FakeStorageService());

        final resultA = await dsA.getOrGenerateDailyChallenge();
        final resultB = await dsB.getOrGenerateDailyChallenge();

        final challengeA = resultA.fold(
          (f) => throw Exception(f.message),
          (c) => c,
        );
        final challengeB = resultB.fold(
          (f) => throw Exception(f.message),
          (c) => c,
        );

        expect(challengeA.date, challengeB.date);
        expect(challengeA.puzzle.grid, challengeB.puzzle.grid);
        expect(challengeA.puzzle.solution, challengeB.puzzle.solution);
      },
    );

    test('getOrGenerateDailyChallenge is idempotent for the same store', () async {
      final ds = DailyChallengeLocalDataSource(FakeStorageService());
      final first = await ds.getOrGenerateDailyChallenge();
      final second = await ds.getOrGenerateDailyChallenge();

      final challenge1 = first.fold((f) => throw Exception(f.message), (c) => c);
      final challenge2 = second.fold((f) => throw Exception(f.message), (c) => c);

      expect(challenge1.puzzle.grid, challenge2.puzzle.grid);
    });

    test('completing the challenge persists stats and blocks replay', () async {
      final ds = DailyChallengeLocalDataSource(FakeStorageService());
      final generated = await ds.getOrGenerateDailyChallenge();
      final challenge = generated.fold(
        (f) => throw Exception(f.message),
        (c) => c,
      );

      final completeResult = await ds.completeDailyChallenge(
        date: challenge.date,
        timeElapsed: 120,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(completeResult.isRight(), true);
      expect(await ds.isDailyChallengeCompleted(challenge.date), true);

      final stats = (await ds.getStats()).fold(
        (f) => throw Exception(f.message),
        (s) => s,
      );
      expect(stats.totalCompleted, 1);
      expect(stats.currentStreak, 1);

      // Replaying (completing again) must be rejected — no double credit.
      final replayResult = await ds.completeDailyChallenge(
        date: challenge.date,
        timeElapsed: 60,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(replayResult.isLeft(), true);
    });
  });
}
