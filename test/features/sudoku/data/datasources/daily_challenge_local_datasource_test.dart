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

    test(
      'getOrGenerateDailyChallenge is idempotent for the same store',
      () async {
        final ds = DailyChallengeLocalDataSource(FakeStorageService());
        final first = await ds.getOrGenerateDailyChallenge();
        final second = await ds.getOrGenerateDailyChallenge();

        final challenge1 = first.fold(
          (f) => throw Exception(f.message),
          (c) => c,
        );
        final challenge2 = second.fold(
          (f) => throw Exception(f.message),
          (c) => c,
        );

        expect(challenge1.puzzle.grid, challenge2.puzzle.grid);
      },
    );

    test(
      'the generated puzzle carries a real, complete solution (not the blanked-out puzzle itself)',
      () async {
        // Regression: _generateDailyPuzzle used to read the "solution" off
        // the same board the blanked puzzle was derived from, so it was
        // mostly zeros — every entered digit was judged a mistake because
        // it could never equal solution[row][col].
        final ds = DailyChallengeLocalDataSource(FakeStorageService());
        final result = await ds.getOrGenerateDailyChallenge();
        final challenge = result.fold(
          (f) => throw Exception(f.message),
          (c) => c,
        );
        final solution = challenge.puzzle.solution;
        final grid = challenge.puzzle.grid;

        // A real solution has no blanks and every row/column/box contains
        // each digit 1-9 exactly once.
        for (final row in solution) {
          expect(row.contains(0), false);
        }
        const complete = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        for (var r = 0; r < 9; r++) {
          expect(solution[r].toSet(), complete);
        }
        for (var c = 0; c < 9; c++) {
          expect(solution.map((row) => row[c]).toSet(), complete);
        }
        for (var boxRow = 0; boxRow < 3; boxRow++) {
          for (var boxCol = 0; boxCol < 3; boxCol++) {
            final box = <int>{};
            for (var r = boxRow * 3; r < boxRow * 3 + 3; r++) {
              for (var c = boxCol * 3; c < boxCol * 3 + 3; c++) {
                box.add(solution[r][c]);
              }
            }
            expect(box, complete);
          }
        }

        // Every given clue in the puzzle must agree with the solution.
        for (var r = 0; r < 9; r++) {
          for (var c = 0; c < 9; c++) {
            if (grid[r][c] != 0) {
              expect(grid[r][c], solution[r][c]);
            }
          }
        }
      },
    );

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
