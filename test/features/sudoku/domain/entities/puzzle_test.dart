import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';

void main() {
  group('Puzzle', () {
    late List<List<int>> validGrid;
    late List<List<int>> validSolution;

    setUp(() {
      validGrid = List.generate(9, (i) => List.generate(9, (j) => 0));
      validSolution = List.generate(
        9,
        (i) => List.generate(9, (j) => ((i * 3 + i ~/ 3 + j) % 9) + 1),
      );
      // Set some initial values
      validGrid[0][0] = 5;
      validGrid[0][1] = 3;
      validGrid[1][0] = 6;
    });

    test('creates Puzzle with all required fields', () {
      final puzzle = Puzzle(
        id: 'puzzle-1',
        grid: List.generate(9, (i) => List.filled(9, 0)),
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'medium',
        cluesCount: 30,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(puzzle.id, equals('puzzle-1'));
      expect(puzzle.difficulty, equals('medium'));
      expect(puzzle.cluesCount, equals(30));
      expect(puzzle.createdAt, equals(DateTime(2024, 1, 1)));
      expect(puzzle.timeElapsed, isNull);
      expect(puzzle.mistakes, isNull);
      expect(puzzle.hintsUsed, isNull);
      expect(puzzle.isCompleted, isNull);
    });

    test('copyWith updates only specified fields', () {
      final puzzle = Puzzle(
        id: 'puzzle-1',
        grid: List.generate(9, (i) => List.filled(9, 0)),
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'easy',
        cluesCount: 36,
        createdAt: DateTime.now(),
        timeElapsed: 100,
        mistakes: 1,
        hintsUsed: 1,
        isCompleted: false,
      );

      final updated = puzzle.copyWith(
        timeElapsed: 200,
        mistakes: 2,
        isCompleted: true,
      );

      expect(updated.timeElapsed, equals(200));
      expect(updated.mistakes, equals(2));
      expect(updated.isCompleted, isTrue);
      expect(updated.id, equals(puzzle.id));
      expect(updated.difficulty, equals('easy'));
    });

    test('toJson and fromJson roundtrip', () {
      final puzzle = Puzzle(
        id: 'test-puzzle-1',
        grid: List.generate(9, (i) => List.generate(9, (j) => (i + j) % 9)),
        solution: List.generate(
          9,
          (i) => List.generate(9, (j) => (i + j) % 9 + 1),
        ),
        difficulty: 'hard',
        cluesCount: 26,
        createdAt: DateTime(2024, 6, 15),
        timeElapsed: 120,
        mistakes: 2,
        hintsUsed: 1,
        isCompleted: true,
      );

      final json = puzzle.toJson();
      final restored = Puzzle.fromJson(json);

      expect(restored.id, equals(puzzle.id));
      expect(restored.grid, equals(puzzle.grid));
      expect(restored.solution, equals(puzzle.solution));
      expect(restored.difficulty, equals('hard'));
      expect(restored.cluesCount, equals(26));
      expect(restored.timeElapsed, equals(120));
      expect(restored.mistakes, equals(2));
      expect(restored.hintsUsed, equals(1));
      expect(restored.isCompleted, isTrue);
    });

    test('isValid validates grid correctly', () {
      // Valid grid
      final validGrid = List.generate(
        9,
        (i) => List.generate(9, (j) => ((i * 3 + i ~/ 3 + j) % 9) + 1),
      );
      final validPuzzle = Puzzle(
        id: 'valid',
        grid: validGrid,
        solution: validGrid,
        difficulty: 'medium',
        cluesCount: 27,
        createdAt: DateTime.now(),
      );
      expect(validPuzzle.isValid, isTrue);

      // Invalid grid - duplicate in row
      final invalidGrid = List.generate(9, (i) => List.filled(9, 0));
      invalidGrid[0][0] = 5;
      invalidGrid[0][1] = 5;
      final invalidPuzzle = Puzzle(
        id: 'invalid',
        grid: invalidGrid,
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'medium',
        cluesCount: 2,
        createdAt: DateTime.now(),
      );
      expect(invalidPuzzle.isValid, isFalse);
    });

    test('isComplete checks if grid is full and valid', () {
      final emptyGrid = List.generate(9, (i) => List.filled(9, 0));
      final emptyPuzzle = Puzzle(
        id: 'empty',
        grid: emptyGrid,
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'easy',
        cluesCount: 0,
        createdAt: DateTime.now(),
      );
      expect(emptyPuzzle.isComplete, isFalse);

      final fullValidGrid = List.generate(
        9,
        (i) => List.generate(9, (j) => ((i * 3 + i ~/ 3 + j) % 9) + 1),
      );
      final completePuzzle = Puzzle(
        id: 'complete',
        grid: fullValidGrid,
        solution: fullValidGrid,
        difficulty: 'medium',
        cluesCount: 27,
        createdAt: DateTime.now(),
      );
      expect(completePuzzle.isComplete, isTrue);
    });

    test('flatGrid and flatSolution flatten correctly', () {
      final grid = [
        [1, 2, 3, 0, 0, 0, 0, 0, 0],
        [4, 5, 6, 0, 0, 0, 0, 0, 0],
        [7, 8, 9, 0, 0, 0, 0, 0, 0],
        List.filled(9, 0),
        List.filled(9, 0),
        List.filled(9, 0),
        List.filled(9, 0),
        List.filled(9, 0),
        List.filled(9, 0),
      ];

      final puzzle = Puzzle(
        id: 'test',
        grid: grid,
        solution: grid,
        difficulty: 'easy',
        cluesCount: 9,
        createdAt: DateTime.now(),
      );

      expect(puzzle.flatGrid.length, equals(81));
      expect(puzzle.flatSolution.length, equals(81));
      expect(puzzle.flatGrid[0], equals(1));
      expect(puzzle.flatGrid[1], equals(2));
      expect(puzzle.flatGrid[3], equals(0));
    });

    test('filledCount counts non-zero cells', () {
      final grid = List.generate(9, (i) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[0][1] = 3;
      grid[4][4] = 7;

      final puzzle = Puzzle(
        id: 'test',
        grid: grid,
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'easy',
        cluesCount: 3,
        createdAt: DateTime.now(),
      );

      expect(puzzle.filledCount, equals(3));
    });

    test('equality works correctly', () {
      final p1 = Puzzle(
        id: 'p1',
        grid: List.generate(9, (i) => List.filled(9, 0)),
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'easy',
        cluesCount: 36,
        createdAt: DateTime(2024, 1, 1),
      );

      final p2 = Puzzle(
        id: 'p1',
        grid: List.generate(9, (i) => List.filled(9, 0)),
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'easy',
        cluesCount: 36,
        createdAt: DateTime(2024, 1, 1),
      );

      final p3 = Puzzle(
        id: 'p2',
        grid: List.generate(9, (i) => List.filled(9, 0)),
        solution: List.generate(9, (i) => List.filled(9, 0)),
        difficulty: 'medium',
        cluesCount: 30,
        createdAt: DateTime.now(),
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });

    test('serialization preserves all fields', () {
      final puzzle = Puzzle(
        id: 'serial-test',
        grid: List.generate(9, (i) => List.generate(9, (j) => i + j)),
        solution: List.generate(9, (i) => List.generate(9, (j) => i + j + 1)),
        difficulty: 'expert',
        cluesCount: 22,
        createdAt: DateTime(2024, 12, 25),
        timeElapsed: 300,
        mistakes: 2,
        hintsUsed: 1,
        isCompleted: true,
      );

      final json = puzzle.toJson();
      expect(json['id'], equals('serial-test'));
      expect(json['difficulty'], equals('expert'));
      expect(json['cluesCount'], equals(22));
      expect(json['timeElapsed'], equals(300));
      expect(json['mistakes'], equals(2));
      expect(json['hintsUsed'], equals(1));
      expect(json['isCompleted'], isTrue);
    });
  });
}
