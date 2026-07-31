import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth;
        final cellSize = gridSize / 9;

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          decoration: BoxDecoration(
            color:
                Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.gridBackgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color:
                  Theme.of(
                    context,
                  ).extension<AppThemeExtension>()!.subGridLineColor,
              width: 3,
            ),
          ),
          child: Column(
            children: List.generate(9, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(9, (col) {
                    return _buildCell(context, row, col, cellSize);
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, int row, int col, double cellSize) {
    final extension = Theme.of(context).extension<AppThemeExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final puzzle = this.puzzle;
    final userGrid = this.userGrid;
    final notes = this.notes;
    final selectedCell = this.selectedCell;
    final highlightedCells = this.highlightedCells;
    final conflictCells = this.conflictCells;
    final isNoteMode = this.isNoteMode;

    final position = CellPosition(row: row, col: col);
    final isSelected = selectedCell?.row == row && selectedCell?.col == col;
    final isHighlighted = highlightedCells.contains(
      CellPosition(row: row, col: col),
    );
    final isConflicted = conflictCells.contains(
      CellPosition(row: row, col: col),
    );
    final isFixed = puzzle.grid[row][col] != 0;
    final value = userGrid[row][col];
    final cellNotes = notes[row][col];
    final hasError = false; // Will be calculated by game logic
    final value =
        userGrid[row][col] != 0
            ? userGrid[row][col]
            : (puzzle.grid[row][col] != 0 ? puzzle.grid[row][col] : null);
    final isFixed = puzzle.grid[row][col] != 0;
    final notes = this.notes[row][col];
    final isSelected = selectedCell?.row == row && selectedCell?.col == col;
    final isHighlighted = highlightedCells.contains(
      CellPosition(row: row, col: col),
    );
    final isConflicted = conflictCells.contains(
      CellPosition(row: row, col: col),
    );
    final isFixed = puzzle.grid[row][col] != 0;
    final value = userGrid[row][col] != 0 ? userGrid[row][col] : null;
    final notes = this.notes[row][col];

    return _buildCell(
      context,
      row,
      col,
      isSelected,
      isFixed,
      hasError: false,
      isHighlighted: isHighlighted,
      isRelated: isSelected && !isFixed,
      isConflicted: false,
      value: value,
      notes: this.notes[row][col],
      onTap: () => onCellTap(row, col),
      onLongPress: () => onCellLongPress(row, col),
    );
  }

  Widget _buildCell(
    BuildContext context,
    int row,
    int col, {
    required bool isSelected,
    required bool isFixed,
    required bool hasError,
    required bool isHighlighted,
    required bool isRelated,
    required bool isConflicted,
    required int? value,
    required List<int> notes,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final extension = Theme.of(context).extension<AppThemeExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color borderColor;
    double borderWidth = 1;

    // Determine background and border colors based on cell state
    if (false) {
      // isConflicted - TODO: implement conflict detection
      backgroundColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellErrorBackground;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellErrorBorder;
      borderWidth = 2;
    } else if (true) {
      // isSelected
      backgroundColor =
          Theme.of(
            context,
          ).extension<AppThemeExtension>()!.cellSelectedBackground;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellSelectedBorder;
      borderWidth = 2;
    } else if (false) {
      // isHighlighted
      backgroundColor =
          Theme.of(
            context,
          ).extension<AppThemeExtension>()!.cellHighlightBackground;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellBorder;
    } else if (false) {
      // isRelated
      backgroundColor =
          Theme.of(
            context,
          ).extension<AppThemeExtension>()!.cellRelatedBackground;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellBorder;
    } else if (Theme.of(
          context,
        ).extension<AppThemeExtension>()!.cellFixedBackground !=
        null) {
      backgroundColor =
          Theme.of(
            context,
          ).extension<AppThemeExtension>()!.cellFixedBackground!;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellFixedBorder!;
    } else {
      backgroundColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellBackground;
      borderColor =
          Theme.of(context).extension<AppThemeExtension>()!.cellBorder;
    }

    final textColor = colorScheme.onSurface;
    final noteColor = colorScheme.onSurfaceVariant;

    return AnimatedContainer(
          duration: AppConstants.fastAnimation,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.zero,
              child: _buildCellContent(
                value: value,
                notes: notes,
                isFixed: isFixed,
                textColor: colorScheme.onSurface,
                noteColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: AppConstants.fastAnimation,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildCellContent({
    required int? value,
    required List<int> notes,
    required bool isFixed,
    required Color textColor,
    required Color noteColor,
  }) {
    if (value != null) {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      );
    }

    if (notes.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int row = 0; row < 3; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    _buildNote(row * 3 + col + 1, notes),
                ],
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNote(int number, List<int> notes, Color noteColor) {
    if (notes.contains(number)) {
      return Text(
        number.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: noteColor,
        ),
      );
    }
    return const SizedBox(width: 10, height: 10);
  }
}

class CellPosition {
  const CellPosition({required this.row, required this.col});

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'CellPosition($row, $col)';
}
