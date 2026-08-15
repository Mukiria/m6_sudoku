import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';

/// Caps the rendered board size on very large screens (tablets, desktop)
/// so cells stay comfortably readable instead of growing unbounded.
const double _maxBoardSize = 900.0;

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
        final maxWidth = constraints.maxWidth;
        final maxHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : maxWidth;
        final side = math.min(maxWidth, maxHeight).clamp(0.0, _maxBoardSize);
        final cellSize = side / AppConstants.gridSize;

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: extension.gridBackgroundColor,
                  border: Border.all(
                    color: extension.subGridLineColor,
                    width: 2.0,
                  ),
                ),
                child: _SudokuBoardView(
                  puzzle: puzzle,
                  userGrid: userGrid,
                  notes: notes,
                  selectedCell: selectedCell,
                  highlightedCells: highlightedCells,
                  conflictCells: conflictCells,
                  cellSize: cellSize,
                  onCellTap: onCellTap,
                  onCellLongPress: onCellLongPress,
                  extension: extension,
                  colorScheme: colorScheme,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders the 81 cells in a single [GridView.builder] so every column and
/// row shares one layout pass — this is what guarantees the grid is a
/// perfect square with perfectly aligned borders. Grid lines are drawn as
/// part of each cell's own border (see [_SudokuCell]) rather than by a
/// separate overlay, so they can never drift out of alignment with the
/// cells they outline.
class _SudokuBoardView extends StatelessWidget {
  const _SudokuBoardView({
    required this.puzzle,
    required this.userGrid,
    required this.notes,
    required this.selectedCell,
    required this.highlightedCells,
    required this.conflictCells,
    required this.cellSize,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.extension,
    required this.colorScheme,
  });

  final Puzzle puzzle;
  final List<List<int>> userGrid;
  final List<List<Set<int>>> notes;
  final CellPosition? selectedCell;
  final Set<CellPosition> highlightedCells;
  final Set<CellPosition> conflictCells;
  final double cellSize;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.gridSize,
      ),
      itemCount: AppConstants.totalCells,
      itemBuilder: (context, index) {
        final row = index ~/ AppConstants.gridSize;
        final col = index % AppConstants.gridSize;
        final position = CellPosition(row: row, col: col);
        final isFixed = puzzle.grid[row][col] != 0;
        final userValue = userGrid[row][col];
        final value =
            userValue != 0
                ? userValue
                : (isFixed ? puzzle.grid[row][col] : null);

        return _SudokuCell(
          key: ValueKey('cell_$row$col'),
          row: row,
          col: col,
          value: value,
          cellNotes: notes[row][col],
          isFixed: isFixed,
          isSelected: selectedCell == position,
          isHighlighted: highlightedCells.contains(position),
          isConflicted: conflictCells.contains(position),
          cellSize: cellSize,
          onCellTap: onCellTap,
          onCellLongPress: onCellLongPress,
          extension: extension,
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _SudokuCell extends StatelessWidget {
  const _SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.cellNotes,
    required this.isFixed,
    required this.isSelected,
    required this.isHighlighted,
    required this.isConflicted,
    required this.cellSize,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.extension,
    required this.colorScheme,
  });

  final int row;
  final int col;
  final int? value;
  final Set<int> cellNotes;
  final bool isFixed;
  final bool isSelected;
  final bool isHighlighted;
  final bool isConflicted;
  final double cellSize;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Background color and border are the only things that change with
    // selection state — the cell's footprint never changes, so selection
    // and highlighting can never shift neighboring cells or push the grid
    // out of alignment.
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(color: _backgroundColor(), border: _border()),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCellTap(row, col),
            onLongPress: () => onCellLongPress(row, col),
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: colorScheme.primary.withValues(alpha: 0.06),
            child: Center(child: _buildContent()),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (isConflicted) return extension.cellErrorBackground;
    if (isSelected) return extension.cellSelectedBackground;
    if (isHighlighted) return extension.cellRelatedBackground;
    if (isFixed) return extension.cellFixedBackground;
    return extension.cellBackground;
  }

  /// Thin lines between cells, thick lines every three cells to mark the
  /// 3x3 boxes. Only the right/bottom edges are drawn — the last row/column
  /// of a box relies on the outer board border instead — so no two cells
  /// ever draw overlapping edges of differing widths.
  Border _border() {
    final thin = BorderSide(color: extension.cellBorder, width: 1.0);
    final thick = BorderSide(color: extension.subGridLineColor, width: 2.0);

    return Border(
      right:
          col == AppConstants.gridSize - 1
              ? BorderSide.none
              : ((col + 1) % AppConstants.subGridSize == 0 ? thick : thin),
      bottom:
          row == AppConstants.gridSize - 1
              ? BorderSide.none
              : ((row + 1) % AppConstants.subGridSize == 0 ? thick : thin),
    );
  }

  Widget _buildContent() {
    if (value != null) {
      return _NumberCell(
        value: value!,
        isFixed: isFixed,
        isConflicted: isConflicted,
        cellSize: cellSize,
      );
    }

    if (cellNotes.isNotEmpty) {
      return SizedBox(
        width: cellSize,
        height: cellSize,
        child: _NotesGrid(notes: cellNotes, cellSize: cellSize),
      );
    }

    return const SizedBox.shrink();
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    required this.value,
    required this.isFixed,
    required this.isConflicted,
    required this.cellSize,
  });

  final int value;
  final bool isFixed;
  final bool isConflicted;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final fontSize = (cellSize * 0.38).clamp(11.0, 26.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
          color:
              isConflicted
                  ? Colors.redAccent
                  : (isFixed ? Colors.white : Colors.lightBlueAccent),
          height: 1.0,
        ),
      ),
    );
  }
}

/// A clean 3x3 mini-grid of candidate notes, laid out with [Table] so every
/// slot gets an exact, equal share of the cell — no two notes can ever
/// collide, and each digit sits in the same spot regardless of which other
/// notes are present.
class _NotesGrid extends StatelessWidget {
  const _NotesGrid({required this.notes, required this.cellSize});

  final Set<int> notes;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final unit = cellSize / AppConstants.subGridSize;
    final fontSize = (unit * 0.6).clamp(7.0, 13.0);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: List.generate(AppConstants.subGridSize, (r) {
        return TableRow(
          children: List.generate(AppConstants.subGridSize, (c) {
            final number = r * AppConstants.subGridSize + c + 1;
            final showNote = notes.contains(number);

            return SizedBox(
              height: unit,
              child:
                  showNote
                      ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            height: 1.0,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            );
          }),
        );
      }),
    );
  }
}
