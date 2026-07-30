import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:m6_sudoku/features/sudoku/engine/generator/puzzle_generator.dart';
import '../../domain/usecases/game_usecases.dart';

part 'game_provider.g.dart';

class GameState {
  GameState({
    required this.puzzleId,
    required this.userGrid,
    required this.notes,
    required this.timeElapsed,
    required this.mistakes,
    required this.hintsUsed,
    required this.moveHistory,
    required this.status,
    required this.lastPlayed,
    required this.difficulty,
  });

  final String puzzleId;
  final List<List<int>> userGrid;
  final List<List<Set<int>>> notes;
  final int timeElapsed;
  final int mistakes;
  final int hintsUsed;
  final List<Move> moveHistory;
  final GameStatus status;
  final DateTime lastPlayed;
  final Difficulty difficulty;

  GameState copyWith({
    String? puzzleId,
    List<List<int>>? userGrid,
    List<List<Set<int>>>? notes,
    int? timeElapsed,
    int? mistakes,
    int? hintsUsed,
    List<Move>? moveHistory,
    GameStatus? status,
    DateTime? lastPlayed,
    Difficulty? difficulty,
  }) {
    return GameState(
      puzzleId: puzzleId ?? this.puzzleId,
      userGrid: userGrid ?? this.userGrid,
      notes: notes ?? this.notes,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      moveHistory: moveHistory ?? this.moveHistory,
      status: status ?? this.status,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

@freezed
class Move with _$Move {
  const factory Move({
    required int row,
    required int col,
    required int? previousValue,
    required int? newValue,
    required MoveType type,
    required DateTime timestamp,
  }) = _Move;
}

enum MoveType {
  value,
  note,
  hint,
  undo,
  clear,
}

enum GameStatus {
  playing,
  paused,
  completed,
  failed,
}

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  evil;

  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.medium:
        return 'medium';
      case Difficulty.hard:
        return 'hard';
      case Difficulty.expert:
        return 'expert';
      case Difficulty.evil:
        return 'evil';
    }
  }
}

@riverpod
class GameController extends _$GameController {
  @override
  GameState? build() => null;

  Future<void> newGame(Difficulty difficulty) async {
    final generatePuzzle = ref.read(generatePuzzleUseCaseProvider);
    final result = await generatePuzzle(difficulty.name);

    state = result.fold(
      (failure) => throw Exception(failure.message),
      (puzzle) => GameState(
        puzzleId: puzzle.id,
        userGrid: puzzle.grid.map((row) => List.from(row)).toList(),
        notes: List.generate(9, (_) => List.generate(9, (_) => <int>{})),
        timeElapsed: 0,
        mistakes: 0,
        hintsUsed: 0,
        moveHistory: [],
        status: GameStatus.playing,
        lastPlayed: DateTime.now(),
        difficulty: difficulty,
      ),
    );
  }

  Future<void> loadGame() async {
    final getGameState = ref.read(getGameStateUseCaseProvider);
    final result = await getGameState();

    state = result.fold(
      (failure) => null,
      (gameState) => gameState,
    );
  }

  void setValue(int row, int col, int value) {
    if (state == null) return;

    final currentState = state!;
    final puzzle = _getPuzzle(currentState.puzzleId);
    if (puzzle == null) return;

    if (puzzle.grid[row][col] != 0) return; // Fixed cell

    final previousValue = currentState.userGrid[row][col];
    if (previousValue == value) return;

    final newGrid = currentState.userGrid.map((row) => List.from(row)).toList();
    newGrid[row][col] = value;

    final isCorrect = puzzle.solution[row][col] == value;
    final newMistakes =
        isCorrect ? currentState.mistakes : currentState.mistakes + 1;

    state = currentState.copyWith(
      userGrid: newGrid,
      mistakes: newMistakes,
      moveHistory: [
        ...currentState.moveHistory,
        Move(
          row: row,
          col: col,
          previousValue: previousValue,
          newValue: value,
          type: MoveType.value,
          timestamp: DateTime.now(),
        ),
      ],
      lastPlayed: DateTime.now(),
    );

    if (newMistakes >= 3) {
      state = state!.copyWith(status: GameStatus.failed);
    } else if (_checkCompletion(newGrid, puzzle.solution)) {
      state = state!.copyWith(status: GameStatus.completed);
    }
  }

  void toggleNote(int row, int col, int note) {
    if (state == null) return;

    final currentState = state!;
    final currentNotes = currentState.notes[row][col];
    final newNotes = Set<int>.from(currentNotes);

    if (newNotes.contains(note)) {
      newNotes.remove(note);
    } else {
      newNotes.add(note);
    }

    final newNotesGrid =
        currentState.notes.map((row) => List.from(row)).toList();
    newNotesGrid[row][col] = newNotes;

    state = currentState.copyWith(
      notes: newNotesGrid,
      moveHistory: [
        ...currentState.moveHistory,
        Move(
          row: row,
          col: col,
          previousValue: null,
          newValue: note,
          type: MoveType.note,
          timestamp: DateTime.now(),
        ),
      ],
      lastPlayed: DateTime.now(),
    );
  }

  void clearCell(int row, int col) {
    if (state == null) return;

    final currentState = state!;
    final puzzle = _getPuzzle(currentState.puzzleId);
    if (puzzle == null) return;

    if (puzzle.grid[row][col] != 0) return; // Fixed cell

    final previousValue = currentState.userGrid[row][col];
    if (previousValue == 0 && currentState.notes[row][col].isEmpty) return;

    final newGrid = currentState.userGrid.map((row) => List.from(row)).toList();
    newGrid[row][col] = 0;

    final newNotesGrid =
        currentState.notes.map((row) => List.from(row)).toList();
    newNotesGrid[row][col] = <int>{};

    state = currentState.copyWith(
      userGrid: newGrid,
      notes: newNotesGrid,
      moveHistory: [
        ...currentState.moveHistory,
        Move(
          row: row,
          col: col,
          previousValue: previousValue,
          newValue: 0,
          type: MoveType.clear,
          timestamp: DateTime.now(),
        ),
      ],
      lastPlayed: DateTime.now(),
    );
  }

  Future<void> useHint() async {
    if (state == null) return;

    final currentState = state!;
    final puzzle = _getPuzzle(currentState.puzzleId);
    if (puzzle == null) return;

    final getHint = ref.read(getHintUseCaseProvider);
    final result = await getHint(state: currentState);

    result.fold(
      (failure) => null,
      (hint) {
        if (hint != null) {
          setValue(hint.row, hint.col, hint.value!);
          state = state!.copyWith(
            hintsUsed: currentState.hintsUsed + 1,
            moveHistory: [
              ...currentState.moveHistory,
              Move(
                row: hint.row,
                col: hint.col,
                previousValue: null,
                newValue: hint.value,
                type: MoveType.hint,
                timestamp: DateTime.now(),
              ),
            ],
          );
        }
      },
    );
  }

  void undo() {
    if (state == null || state!.moveHistory.isEmpty) return;

    final currentState = state!;
    final lastMove = currentState.moveHistory.last;
    final previousMoves = currentState.moveHistory
        .sublist(0, currentState.moveHistory.length - 1);

    final newGrid = currentState.userGrid.map((row) => List.from(row)).toList();
    final newNotesGrid =
        currentState.notes.map((row) => List.from(row)).toList();
    int newMistakes = currentState.mistakes;
    int newHintsUsed = currentState.hintsUsed;

    switch (lastMove.type) {
      case MoveType.value:
        newGrid[lastMove.row][lastMove.col] = lastMove.previousValue ?? 0;
        // Recalculate mistakes
        final puzzle = _getPuzzle(currentState.puzzleId);
        if (puzzle != null) {
          newMistakes = _calculateMistakes(newGrid, puzzle.solution);
        }
        break;
      case MoveType.note:
        if (lastMove.newValue != null) {
          newNotesGrid[lastMove.row][lastMove.col].remove(lastMove.newValue);
        }
        break;
      case MoveType.hint:
        newGrid[lastMove.row][lastMove.col] = lastMove.previousValue ?? 0;
        newHintsUsed = (currentState.hintsUsed - 1).clamp(0, 999);
        final puzzle = _getPuzzle(currentState.puzzleId);
        if (puzzle != null) {
          newMistakes = _calculateMistakes(newGrid, puzzle.solution);
        }
        break;
      case MoveType.clear:
        if (lastMove.previousValue != null) {
          newGrid[lastMove.row][lastMove.col] = lastMove.previousValue!;
        }
        final puzzle = _getPuzzle(currentState.puzzleId);
        if (puzzle != null) {
          newMistakes = _calculateMistakes(newGrid, puzzle.solution);
        }
        break;
      default:
        break;
    }

    state = currentState.copyWith(
      userGrid: newGrid,
      notes: newNotesGrid,
      mistakes: newMistakes,
      hintsUsed: newHintsUsed,
      moveHistory: previousMoves,
      status: GameStatus.playing,
      lastPlayed: DateTime.now(),
    );
  }

  void incrementTimer() {
    if (state == null) return;
    if (state!.status != GameStatus.playing) return;

    state = state!.copyWith(
      timeElapsed: state!.timeElapsed + 1,
      lastPlayed: DateTime.now(),
    );
  }

  void pause() {
    if (state == null) return;
    state = state!.copyWith(status: GameStatus.paused);
  }

  void resume() {
    if (state == null) return;
    state =
        state!.copyWith(status: GameStatus.playing, lastPlayed: DateTime.now());
  }

  Puzzle? _getPuzzle(String puzzleId) {
    // In a real app, this would come from repository
    return null;
  }

  bool _checkCompletion(List<List<int>> grid, List<List<int>> solution) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  int _calculateMistakes(List<List<int>> grid, List<List<int>> solution) {
    int mistakes = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] != 0 && grid[r][c] != solution[r][c]) {
          mistakes++;
        }
      }
    }
    return mistakes;
  }
}

@riverpod
class TimerController extends _$TimerController {
  @override
  Stream<int> build() {
    return Stream.periodic(const Duration(seconds: 1), (count) => count + 1);
  }
}

final gameProvider = StateNotifierProvider<GameController, GameState?>((ref) {
  return GameController(ref);
});
