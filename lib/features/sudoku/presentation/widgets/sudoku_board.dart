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

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth;
        final cellSize = gridSize / 9;

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).extension<AppThemeExtension>()!.gridBackgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: Theme.of(context).extension<AppThemeExtension>()!.subGridLineColor,
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

    final position = CellPosition(row: row, col: col);
    final isSelected = selectedCell?.row == row && selectedCell?.col == col;
    final isHighlighted = highlightedCells.contains(position);
    final isConflicted = conflictCells.contains(position);
    final isFixed = puzzle.grid[row][col] != 0;
    final value = userGrid[row][col] != 0 ? userGrid[row][col] : (isFixed ? puzzle.grid[row][col] : null);
    final cellNotes = notes[row][col].toList()..sort();

    Color backgroundColor;
    Color borderColor;
    double borderWidth = 1;

    // Determine background and border colors based on cell state
    if (isConflicted) {
      backgroundColor = extension.cellErrorBackground!;
      borderColor = extension.cellErrorBorder!;
      borderWidth = 2;
    } else if (isSelected) {
      backgroundColor = extension.cellSelectedBackground!;
      borderColor = extension.cellSelectedBorder!;
      borderWidth = 2;
    } else if (isHighlighted) {
      backgroundColor = extension.cellHighlightBackground!;
      borderColor = extension.cellBorder!;
    } else if (isFixed && extension.cellFixedBackground != null) {
      backgroundColor = extension.cellFixedBackground!;
      borderColor = extension.cellFixedBorder!;
    } else {
      backgroundColor = extension.cellBackground!;
      borderColor = extension.cellBorder!;
    }

    final textColor = colorScheme.onSurface;
    final noteColor = colorScheme.onSurfaceVariant;

    return AnimatedContainer(
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
          child: _buildCellContent(
            value: value,
            notes: cellNotes,
            isFixed: isFixed,
            isConflicted: isConflicted,
            textColor: textColor,
            noteColor: noteColor,
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
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
    required bool isConflicted,
    required Color textColor,
    required Color noteColor,
  }) {
    if (value != null) {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
            color: isConflicted ? Colors.red : textColor,
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
                    _buildNote(row * 3 + col + 1, notes, noteColor),
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