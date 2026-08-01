import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({
    super.key,
    required this.puzzle,
    required this.userGrid,
    required this.notes,
    required this.selectedCell,
    required this.highlightedCells,
    required this.conflictCells,
    required this.isNoteMode,
    required this.onCellTap,
    required this.onCellLongPress,
  });

  final Puzzle puzzle;
  final List<List<int>> userGrid;
  final List<List<Set<int>>> notes;
  final CellPosition? selectedCell;
  final Set<CellPosition> highlightedCells;
  final Set<CellPosition> conflictCells;
  final bool isNoteMode;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<AppThemeExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth;
        final cellSize = gridSize / 9;

        return RepaintBoundary(
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            decoration: BoxDecoration(
              color: extension.gridBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: extension.subGridLineColor,
                width: 3,
              ),
            ),
            child: _BoardGrid(
              puzzle: puzzle,
              userGrid: userGrid,
              notes: notes,
              selectedCell: selectedCell,
              highlightedCells: highlightedCells,
              conflictCells: conflictCells,
              isNoteMode: isNoteMode,
              onCellTap: onCellTap,
              onCellLongPress: onCellLongPress,
              cellSize: cellSize,
              extension: extension,
              colorScheme: colorScheme,
            ),
          ),
        );
      },
    );
  }
}

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({
    required this.puzzle,
    required this.userGrid,
    required this.notes,
    required this.selectedCell,
    required this.highlightedCells,
    required this.conflictCells,
    required this.isNoteMode,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.cellSize,
    required this.extension,
    required this.colorScheme,
  });

  final Puzzle puzzle;
  final List<List<int>> userGrid;
  final List<List<Set<int>>> notes;
  final CellPosition? selectedCell;
  final Set<CellPosition> highlightedCells;
  final Set<CellPosition> conflictCells;
  final bool isNoteMode;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;
  final double cellSize;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(9, (row) {
        return Expanded(
          child: Row(
            children: List.generate(9, (col) {
              return _SudokuCell(
                key: ValueKey('cell_${row}_${col}'),
                row: row,
                col: col,
                cellSize: cellSize,
                puzzle: puzzle,
                userGrid: userGrid,
                notes: notes,
                selectedCell: selectedCell,
                highlightedCells: highlightedCells,
                conflictCells: conflictCells,
                isNoteMode: isNoteMode,
                onCellTap: onCellTap,
                onCellLongPress: onCellLongPress,
                extension: extension,
                colorScheme: colorScheme,
              );
            }),
          ),
        );
      }),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  const _SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.cellSize,
    required this.puzzle,
    required this.userGrid,
    required this.notes,
    required this.selectedCell,
    required this.highlightedCells,
    required this.conflictCells,
    required this.isNoteMode,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.extension,
    required this.colorScheme,
  });

  final int row;
  final int col;
  final double cellSize;
  final Puzzle puzzle;
  final List<List<int>> userGrid;
  final List<List<Set<int>>> notes;
  final CellPosition? selectedCell;
  final Set<CellPosition> highlightedCells;
  final Set<CellPosition> conflictCells;
  final bool isNoteMode;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final position = CellPosition(row: row, col: col);
    final isSelected = selectedCell?.row == row && selectedCell?.col == col;
    final isHighlighted = highlightedCells.contains(position);
    final isConflicted = conflictCells.contains(position);
    final isFixed = puzzle.grid[row][col] != 0;
    final userValue = userGrid[row][col];
    final value = userValue != 0 ? userValue : (isFixed ? puzzle.grid[row][col] : null);
    final cellNotes = notes[row][col];

    final (backgroundColor, borderColor, borderWidth) = _getCellDecoration(
      isConflicted: isConflicted,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isFixed: isFixed,
      extension: extension,
    );

    final textColor = colorScheme.onSurface;
    final noteColor = colorScheme.onSurfaceVariant;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCellTap(row, col),
            onLongPress: () => onCellLongPress(row, col),
            borderRadius: BorderRadius.zero,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: _buildCellContent(
              value: value,
              notes: cellNotes,
              isFixed: isFixed,
              isConflicted: isConflicted,
              isSelected: isSelected,
              textColor: textColor,
              noteColor: noteColor,
            ),
          ),
        ),
      ),
    );
  }

  static (Color, Color, double) _getCellDecoration({
    required bool isConflicted,
    required bool isSelected,
    required bool isHighlighted,
    required bool isFixed,
    required AppThemeExtension extension,
  }) {
    if (isConflicted) {
      return (extension.cellErrorBackground!, extension.cellErrorBorder!, 2.0);
    }
    if (isSelected) {
      return (extension.cellSelectedBackground!, extension.cellSelectedBorder!, 2.0);
    }
    if (isHighlighted) {
      return (extension.cellHighlightBackground!, extension.cellBorder!, 1.0);
    }
    if (isFixed && extension.cellFixedBackground != null) {
      return (extension.cellFixedBackground!, extension.cellFixedBorder!, 1.0);
    }
    return (extension.cellBackground!, extension.cellBorder!, 1.0);
  }

  static Widget _buildCellContent({
    required int? value,
    required Set<int> notes,
    required bool isFixed,
    required bool isConflicted,
    required bool isSelected,
    required Color textColor,
    required Color noteColor,
  }) {
    if (value != null) {
      return _NumberCell(
        value: value,
        isFixed: isFixed,
        isConflicted: isConflicted,
        textColor: textColor,
        isSelected: isSelected,
      );
    }

    if (notes.isNotEmpty) {
      return _NotesCell(notes: notes, noteColor: noteColor);
    }

    return const SizedBox.shrink();
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    required this.value,
    required this.isFixed,
    required this.isConflicted,
    required this.textColor,
    required this.isSelected,
  });

  final int value;
  final bool isFixed;
  final bool isConflicted;
  final Color textColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: isSelected ? 1.03 : 1.0,
        duration: AppConstants.fastAnimation,
        curve: Curves.easeOutBack,
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
            color: isConflicted ? Colors.red : textColor,
          ),
        ),
      ),
    );
  }
}

class _NotesCell extends StatelessWidget {
  const _NotesCell({
    required this.notes,
    required this.noteColor,
  });

  final Set<int> notes;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (col) {
              final number = row * 3 + col + 1;
              return SizedBox(
                width: 12,
                height: 12,
                child: notes.contains(number)
                    ? Center(
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: noteColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }),
          );
        }),
      ),
    );
  }
}