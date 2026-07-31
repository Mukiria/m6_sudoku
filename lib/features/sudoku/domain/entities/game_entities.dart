import 'package:equatable/equatable.dart';

class Cell extends Equatable {
  const Cell({
    required this.row,
    required this.col,
    this.value,
    this.notes = const [],
    this.isFixed = false,
    this.hasError = false,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isRelated = false,
  });

  final int row;
  final int col;
  final int? value;
  final List<int> notes;
  final bool isFixed;
  final bool hasError;
  final bool isSelected;
  final bool isHighlighted;
  final bool isRelated;

  Cell copyWith({
    int? row,
    int? col,
    int? value,
    List<int>? notes,
    bool? isFixed,
    bool? hasError,
    bool? isSelected,
    bool? isHighlighted,
    bool? isRelated,
  }) {
    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      isFixed: isFixed ?? this.isFixed,
      hasError: hasError ?? this.hasError,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isRelated: isRelated ?? this.isRelated,
    );
  }

  bool get isEmpty => value == null && notes.isEmpty;

  bool get hasValue => value != null;

  bool get hasNotes => notes.isNotEmpty;

  @override
  List<Object?> get props => [
    row,
    col,
    value,
    notes,
    isFixed,
    hasError,
    isSelected,
    isHighlighted,
    isRelated,
  ];

  @override
  String toString() {
    return 'Cell(row: $row, col: $col, value: $value, notes: $notes, '
        'isFixed: $isFixed, hasError: $hasError, isSelected: $isSelected, '
        'isHighlighted: $isHighlighted, isRelated: $isRelated)';
  }
}

class Puzzle extends Equatable {
  const Puzzle({
    required this.id,
    required this.grid,
    required this.solution,
    required this.difficulty,
    required this.cluesCount,
    this.createdAt,
    this.completedAt,
    this.timeSpent = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.isCompleted = false,
  });

  final String id;
  final List<List<int>> grid;
  final List<List<int>> solution;
  final String difficulty;
  final int cluesCount;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final int timeSpent;
  final int mistakes;
  final int hintsUsed;
  final bool isCompleted;

  Puzzle copyWith({
    String? id,
    List<List<int>>? grid,
    List<List<int>>? solution,
    String? difficulty,
    int? cluesCount,
    DateTime? createdAt,
    DateTime? completedAt,
    int? timeSpent,
    int? mistakes,
    int? hintsUsed,
    bool? isCompleted,
  }) {
    return Puzzle(
      id: id ?? this.id,
      grid: grid ?? this.grid,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      cluesCount: cluesCount ?? this.cluesCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    grid,
    solution,
    difficulty,
    cluesCount,
    createdAt,
    completedAt,
    timeSpent,
    mistakes,
    hintsUsed,
    isCompleted,
  ];
}

enum GameStatus { playing, paused, completed, failed }

class GameState extends Equatable {
  const GameState({
    required this.puzzle,
    required this.cells,
    required this.status,
    required this.selectedCell,
    required this.selectedNumber,
    required this.isNoteMode,
    required this.timeElapsed,
    required this.mistakes,
    required this.hintsUsed,
    required this.undoStack,
    required this.redoStack,
    this.lastAction,
  });

  final Puzzle puzzle;
  final List<List<Cell>> cells;
  final GameStatus status;
  final Cell? selectedCell;
  final int? selectedNumber;
  final bool isNoteMode;
  final int timeElapsed;
  final int mistakes;
  final int hintsUsed;
  final List<GameAction> undoStack;
  final List<GameAction> redoStack;
  final GameAction? lastAction;

  GameState copyWith({
    Puzzle? puzzle,
    List<List<Cell>>? cells,
    GameStatus? status,
    Cell? selectedCell,
    int? selectedNumber,
    bool? isNoteMode,
    int? timeElapsed,
    int? mistakes,
    int? hintsUsed,
    List<GameAction>? undoStack,
    List<GameAction>? redoStack,
    GameAction? lastAction,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      cells: cells ?? this.cells,
      status: status ?? this.status,
      selectedCell: selectedCell ?? this.selectedCell,
      selectedNumber: selectedNumber ?? this.selectedNumber,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [
    puzzle,
    cells,
    status,
    selectedCell,
    selectedNumber,
    isNoteMode,
    timeElapsed,
    mistakes,
    hintsUsed,
    undoStack,
    redoStack,
    lastAction,
  ];
}

class GameAction extends Equatable {
  const GameAction({
    required this.type,
    required this.row,
    required this.col,
    this.previousValue,
    this.newValue,
    this.previousNotes,
    this.newNotes,
    this.previousMistakes,
    this.newMistakes,
  });

  final ActionType type;
  final int row;
  final int col;
  final int? previousValue;
  final int? newValue;
  final List<int>? previousNotes;
  final List<int>? newNotes;
  final int? previousMistakes;
  final int? newMistakes;

  @override
  List<Object?> get props => [
    type,
    row,
    col,
    previousValue,
    newValue,
    previousNotes,
    newNotes,
    previousMistakes,
    newMistakes,
  ];
}

enum ActionType { setValue, setNotes, clearCell, useHint, undo, redo }
