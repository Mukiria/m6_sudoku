import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/daily_challenge.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';

void main() {
  group('DailyChallenge', () {
    late Puzzle testPuzzle;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 6, 15);
      final grid = List.generate(9, (i) => List.generate(9, (j) => 0));
      final solution = List.generate(
        9,
        (i) => List.generate(9, (j) => ((i + j) % 9) + 1),
      );

      testPuzzle = Puzzle(
        id: 'daily_2024-06-15',
        grid: List.generate(9, (i) => List.generate(9, (j) => 0)),
        solution: solution,
        difficulty: 'medium',
        cluesCount: 30,
        createdAt: DateTime(2024, 6, 15),
      );
    });

    group('DailyChallenge', () {
      test('creates DailyChallenge with all fields', () {
        final challenge = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: false,
          timeElapsed: null,
          mistakes: null,
          hintsUsed: null,
        );

        expect(challenge.date, equals('2024-06-15'));
        expect(challenge.puzzle, equals(testPuzzle));
        expect(challenge.isCompleted, isFalse);
        expect(challenge.timeElapsed, isNull);
        expect(challenge.mistakes, isNull);
        expect(challenge.hintsUsed, isNull);
        expect(challenge.completedAt, isNull);
      });

      test('creates completed DailyChallenge with all stats', () {
        final completedAt = DateTime(2024, 6, 15, 14, 30);
        final challenge = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: true,
          timeElapsed: 450,
          mistakes: 1,
          hintsUsed: 0,
          completedAt: completedAt,
        );

        expect(challenge.isCompleted, isTrue);
        expect(challenge.timeElapsed, equals(450));
        expect(challenge.mistakes, equals(1));
        expect(challenge.hintsUsed, equals(0));
        expect(challenge.completedAt, equals(completedAt));
      });

      test('copyWith updates only specified fields', () {
        final challenge = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: false,
          timeElapsed: null,
          mistakes: null,
          hintsUsed: null,
        );

        final completed = challenge.copyWith(
          isCompleted: true,
          timeElapsed: 300,
          mistakes: 1,
          hintsUsed: 2,
          completedAt: DateTime(2024, 6, 15, 15, 0),
        );

        expect(completed.isCompleted, isTrue);
        expect(completed.timeElapsed, equals(300));
        expect(completed.mistakes, equals(1));
        expect(completed.hintsUsed, equals(2));
        expect(completed.completedAt, isNotNull);
        expect(completed.date, equals('2024-06-15'));
        expect(completed.puzzle, equals(testPuzzle));
      });

      test('toJson and fromJson roundtrip', () {
        final challenge = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: true,
          timeElapsed: 450,
          mistakes: 1,
          hintsUsed: 0,
          completedAt: DateTime(2024, 6, 15, 14, 30),
        );

        final json = challenge.toJson();
        final restored = DailyChallenge.fromJson(json);

        expect(restored.date, equals(challenge.date));
        expect(restored.puzzle.id, equals(challenge.puzzle.id));
        expect(restored.isCompleted, equals(challenge.isCompleted));
        expect(restored.timeElapsed, equals(challenge.timeElapsed));
        expect(restored.mistakes, equals(challenge.mistakes));
        expect(restored.hintsUsed, equals(challenge.hintsUsed));
        expect(restored.completedAt, equals(challenge.completedAt));
      });

      test('equality works correctly', () {
        final c1 = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: false,
          timeElapsed: null,
          mistakes: null,
          hintsUsed: null,
        );

        final c2 = DailyChallenge(
          date: '2024-06-15',
          puzzle: testPuzzle,
          isCompleted: false,
          timeElapsed: null,
          mistakes: null,
          hintsUsed: null,
        );

        final c3 = DailyChallenge(
          date: '2024-06-16',
          puzzle: testPuzzle,
          isCompleted: false,
          timeElapsed: null,
          mistakes: null,
          hintsUsed: null,
        );

        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
        expect(c1, isNot(equals(c3)));
      });
    });
  });

  group('DailyChallengeStats', () {
    test('creates with default values', () {
      const stats = DailyChallengeStats(
        totalPlayed: 0,
        totalCompleted: 0,
        currentStreak: 0,
        bestStreak: 0,
        lastPlayedDate: null,
      );

      expect(stats.totalPlayed, equals(0));
      expect(stats.totalCompleted, equals(0));
      expect(stats.currentStreak, equals(0));
      expect(stats.bestStreak, equals(0));
      expect(stats.lastPlayedDate, isNull);
    });

    test('copyWith updates only specified fields', () {
      final stats = DailyChallengeStats(
        totalPlayed: 10,
        totalCompleted: 5,
        currentStreak: 3,
        bestStreak: 7,
        lastPlayedDate: DateTime(2024, 6, 1),
      );

      final updated = stats.copyWith(
        totalPlayed: 11,
        totalCompleted: 6,
        currentStreak: 4,
      );

      expect(updated.totalPlayed, equals(11));
      expect(updated.totalCompleted, equals(6));
      expect(updated.currentStreak, equals(4));
      expect(updated.bestStreak, equals(7));
      expect(updated.lastPlayedDate, equals(DateTime(2024, 6, 1)));
    });

    test('toJson and fromJson roundtrip', () {
      final stats = DailyChallengeStats(
        totalPlayed: 25,
        totalCompleted: 15,
        currentStreak: 5,
        bestStreak: 10,
        lastPlayedDate: DateTime(2024, 6, 15, 14, 30),
      );

      final json = stats.toJson();
      final restored = DailyChallengeStats.fromJson(json);

      expect(restored.totalPlayed, equals(25));
      expect(restored.totalCompleted, equals(15));
      expect(restored.currentStreak, equals(5));
      expect(restored.bestStreak, equals(10));
      expect(restored.lastPlayedDate, equals(DateTime(2024, 6, 15, 14, 30)));
    });

    test('equality works correctly', () {
      final s1 = DailyChallengeStats(
        totalPlayed: 10,
        totalCompleted: 5,
        currentStreak: 3,
        bestStreak: 7,
        lastPlayedDate: DateTime(2024, 6, 1),
      );

      final s2 = DailyChallengeStats(
        totalPlayed: 10,
        totalCompleted: 5,
        currentStreak: 3,
        bestStreak: 7,
        lastPlayedDate: DateTime(2024, 6, 1),
      );

      final s3 = DailyChallengeStats(
        totalPlayed: 11,
        totalCompleted: 5,
        currentStreak: 3,
        bestStreak: 7,
        lastPlayedDate: DateTime(2024, 6, 1),
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}
