import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:m6_sudoku/features/sudoku/engine/generator/puzzle_generator.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/domain/usecases/game_usecases.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/sudoku_providers.dart';

part 'game_provider.g.dart';

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
        puzzle: puzzle,
        userGrid: puzzle.grid.map((row) => List<int>.from(row)).toList(),
        notes: List.generate(9, (_) => List.generate(9, (_) => <int>{})),
        timeElapsed: 0,
        mistakes: 0,
        hintsUsed: 0,
        penaltyTime: 0,
        moveHistory: [],
        redoStack: [],
        status: GameStatus.playing,
        lastPlayed: DateTime.now(),
        difficulty: difficulty,
        selectedCell: null,
        selectedNumber: null,
        isNoteMode: false,
        highlightedCells: {},
        conflictCells: {},
        hintState: null,
        lastSaved: DateTime.now(),
      ),
    );
    _startAutoSave();
  }

  Future<void> loadGame() async {
    final getGameState = ref.read(getGameStateUseCaseProvider);
    final result = await getGameState();

    state = result.fold((failure) => null, (gameState) => gameState);
    if (state != null && state!.status == GameStatus.playing) {
      _startAutoSave();
    }
  }

  void selectCell(int row, int col) {
    if (state == null) return;

    final puzzle = state!.puzzle;

    state = state!.copyWith(
      selectedCell: CellPosition(row: row, col: col),
      highlightedCells: _getHighlightedCells(row, col),
      conflictCells: _getConflicts(state!.userGrid),
      lastPlayed: DateTime.now(),
    );
  }

  void selectNumber(int number) {
    if (state == null) return;
    if (state!.selectedCell == null) return;

    final isFixed = state!.puzzle.grid[state!.selectedCell!.row][state!.selectedCell!.col] != 0;
    if (isFixed) return;

    if (state!.isNoteMode) {
      toggleNote(state!.selectedCell!.row, state!.selectedCell!.col, number);
    } else {
      setValue(state!.selectedCell!.row, state!.selectedCell!.col, number);
    }
  }

  void setValue(int row, int col, int value) {
    if (state == null) return;

    final currentState = state!;
    final puzzle = currentState.puzzle;

    if (puzzle.grid[row][col] != 0) return; // Fixed cell

    final previousValue = currentState.userGrid[row][col];
    if (previousValue == value) return;

    final newGrid = currentState.userGrid.map((row) => List<int>.from(row)).toList();
    newGrid[row][col] = value;

    final isCorrect = puzzle.solution[row][col] == value;
    final newMistakes =
        isCorrect ? currentState.mistakes : currentState.mistakes + 1;

    final newMove = Move(
      row: row,
      col: col,
      previousValue: previousValue,
      newValue: value,
      type: MoveType.value,
      timestamp: DateTime.now(),
    );

    state = state!.copyWith(
      userGrid: newGrid,
      mistakes: newMistakes,
      conflictCells: _getConflicts(newGrid),
      moveHistory: [...currentState.moveHistory, newMove],
      redoStack: [],
      lastPlayed: DateTime.now(),
      lastSaved: DateTime.now(),
    );

    if (newMistakes >= 3) {
      state = state!.copyWith(status: GameStatus.failed);
    } else if (_checkCompletion(newGrid, puzzle.solution)) {
      state = state!.copyWith(status: GameStatus.completed);
      _saveGame();
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
        currentState.notes.map((row) => List<Set<int>>.from(row)).toList();
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
      lastSaved: DateTime.now(),
    );
  }

  void clearCell(int row, int col) {
    if (state == null) return;

    final currentState = state!;

    if (currentState.puzzle.grid[row][col] != 0) return; // Fixed cell

    final previousValue = currentState.userGrid[row][col];
    if (previousValue == 0 && currentState.notes[row][col].isEmpty) return;

    final newGrid = currentState.userGrid.map((row) => List<int>.from(row)).toList();
    newGrid[row][col] = 0;

    final newNotesGrid =
        currentState.notes.map((row) => List<Set<int>>.from(row)).toList();
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
      lastSaved: DateTime.now(),
    );
  }

  Future<void> useHint() async {
    if (state == null) return;

    final currentState = state!;

    final getHint = ref.read(getHintUseCaseProvider);
    final result = await getHint(state: currentState);

    result.fold((failure) => null, (hint) {
      if (hint != null) {
        // Add penalty time (15 seconds for logical hints, 30 for direct reveal)
        final penalty = hint.hintType == HintType.directReveal ? 30 : 15;
        
        setValue(hint.row, hint.col, hint.value!);
        state = state!.copyWith(
          hintsUsed: currentState.hintsUsed + 1,
          penaltyTime: currentState.penaltyTime + penalty,
          timeElapsed: currentState.timeElapsed + penalty,
          hintState: HintState(
            type: hint.hintType,
            cell: CellPosition(row: hint.row, col: hint.col),
            value: hint.value!,
            explanation: hint.explanation,
            shownAt: DateTime.now(),
          ),
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
          lastPlayed: DateTime.now(),
          lastSaved: DateTime.now(),
        );
      }
    });
  }

  void undo() {
    if (state == null || state!.moveHistory.isEmpty) return;

    final currentState = state!;
    final lastMove = currentState.moveHistory.last;
    final previousMoves = currentState.moveHistory.sublist(
      0,
      currentState.moveHistory.length - 1,
    );

    final newGrid = currentState.userGrid.map((row) => List<int>.from(row)).toList();
    final newNotesGrid =
        currentState.notes.map((row) => List<Set<int>>.from(row)).toList();
    int newMistakes = currentState.mistakes;
    int newHintsUsed = currentState.hintsUsed;

    switch (lastMove.type) {
      case MoveType.value:
        newGrid[lastMove.row][lastMove.col] = lastMove.previousValue ?? 0;
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
        break;
      case MoveType.note:
        if (lastMove.newValue != null) {
          newNotesGrid[lastMove.row][lastMove.col].remove(lastMove.newValue);
        }
        break;
      case MoveType.hint:
        newGrid[lastMove.row][lastMove.col] = lastMove.previousValue ?? 0;
        newHintsUsed = (currentState.hintsUsed - 1).clamp(0, 999);
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
        break;
      case MoveType.clear:
        if (lastMove.previousValue != null) {
          newGrid[lastMove.row][lastMove.col] = lastMove.previousValue!;
        }
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
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
      redoStack: [lastMove, ...currentState.redoStack],
      status: GameStatus.playing,
      lastPlayed: DateTime.now(),
      lastSaved: DateTime.now(),
    );
  }

  void redo() {
    if (state == null || state!.redoStack.isEmpty) return;

    final currentState = state!;
    final nextMove = currentState.redoStack.first;
    final remainingRedo = currentState.redoStack.sublist(1);

    final newGrid = currentState.userGrid.map((row) => List<int>.from(row)).toList();
    final newNotesGrid =
        currentState.notes.map((row) => List<Set<int>>.from(row)).toList();
    int newMistakes = currentState.mistakes;
    int newHintsUsed = currentState.hintsUsed;

    switch (nextMove.type) {
      case MoveType.value:
        newGrid[nextMove.row][nextMove.col] = nextMove.newValue ?? 0;
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
        break;
      case MoveType.note:
        if (nextMove.newValue != null) {
          newNotesGrid[nextMove.row][nextMove.col].add(nextMove.newValue!);
        }
        break;
      case MoveType.hint:
        newGrid[nextMove.row][nextMove.col] = nextMove.newValue ?? 0;
        newHintsUsed = (currentState.hintsUsed - 1).clamp(0, 999);
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
        break;
      case MoveType.clear:
        if (nextMove.previousValue != null) {
          newGrid[nextMove.row][nextMove.col] = nextMove.previousValue!;
        }
        newMistakes = _calculateMistakes(newGrid, currentState.puzzle.solution);
        break;
      default:
        break;
    }

    state = currentState.copyWith(
      userGrid: newGrid,
      notes: newNotesGrid,
      mistakes: newMistakes,
      hintsUsed: newHintsUsed,
      moveHistory: [...currentState.moveHistory, nextMove],
      redoStack: remainingRedo,
      status: GameStatus.playing,
      lastPlayed: DateTime.now(),
      lastSaved: DateTime.now(),
    );
  }

  void toggleNoteMode() {
    if (state == null) return;
    state = state!.copyWith(isNoteMode: !state!.isNoteMode);
  }

  void setSelectedNumber(int? number) {
    if (state == null) return;
    state = state!.copyWith(selectedNumber: number);
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
    _saveGame();
  }

  void resume() {
    if (state == null) return;
    state = state!.copyWith(
      status: GameStatus.playing,
      lastPlayed: DateTime.now(),
    );
  }

  void _saveGame() {
    if (state == null) return;
    final saveGame = ref.read(saveGameStateUseCaseProvider);
    saveGame(state!.copyWith(lastSaved: DateTime.now()));
  }

  void _startAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (state != null && state!.status == GameStatus.playing) {
        _saveGame();
        _startAutoSave();
      }
    });
  }

  Set<CellPosition> _getHighlightedCells(int row, int col) {
    final highlighted = <CellPosition>{};

    // Highlight row
    for (int c = 0; c < 9; c++) {
      if (c != col) highlighted.add(CellPosition(row: row, col: c));
    }

    // Highlight column
    for (int r = 0; r < 9; r++) {
      if (r != row) highlighted.add(CellPosition(row: r, col: col));
    }

    // Highlight 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row || c != col) {
          highlighted.add(CellPosition(row: r, col: c));
        }
      }
    }

    return highlighted;
  }

  Set<CellPosition> _getConflicts(List<List<int>> grid) {
    final conflicts = <CellPosition>{};

    // Check rows
    for (int r = 0; r < 9; r++) {
      final seen = <int, int>{};
      for (int c = 0; c < 9; c++) {
        final val = grid[r][c];
        if (val != 0) {
          if (seen.containsKey(val)) {
            conflicts.add(CellPosition(row: r, col: seen[val]!));
            conflicts.add(CellPosition(row: r, col: c));
          } else {
            seen[val] = c;
          }
        }
      }
    }

    // Check columns
    for (int c = 0; c < 9; c++) {
      final seen = <int, int>{};
      for (int r = 0; r < 9; r++) {
        final val = grid[r][c];
        if (val != 0) {
          if (seen.containsKey(val)) {
            conflicts.add(CellPosition(row: seen[val]!, col: c));
            conflicts.add(CellPosition(row: r, col: c));
          } else {
            seen[val] = r;
          }
        }
      }
    }

    // Check 3x3 boxes
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final seen = <int, CellPosition>{};
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            final rIdx = boxRow * 3 + r;
            final cIdx = boxCol * 3 + c;
            final val = grid[rIdx][cIdx];
            if (val != 0) {
              if (seen.containsKey(val)) {
                conflicts.add(seen[val]!);
                conflicts.add(CellPosition(row: rIdx, col: cIdx));
              } else {
                seen[val] = CellPosition(row: rIdx, col: cIdx);
              }
            }
          }
        }
      }
    }

    return conflicts;
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

  void clearHintState() {
    if (state == null) return;
    state = state!.copyWith(hintState: null);
  }
}

class TimerController extends StateNotifier<int> {
  TimerController(this.ref) : super(0);

  final Ref ref;
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final gameState = ref.read(gameControllerProvider);
      if (gameState != null && gameState.status == GameStatus.playing) {
        state = state + 1;
        ref.read(gameControllerProvider.notifier).incrementTimer();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    start();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerControllerProvider = StateNotifierProvider<TimerController, int>((ref) {
  return TimerController(ref);
});