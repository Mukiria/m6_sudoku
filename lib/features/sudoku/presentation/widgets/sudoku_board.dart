import 'package:flutter/material.dart';
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
        return Center(
          child: SizedBox(
            width: gridSize,
            height: gridSize,
            child: RepaintBoundary(
              child: _SudokuBoardView(
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SudokuBoardView extends StatelessWidget {
  const _SudokuBoardView({
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
    return CustomPaint(
      painter: _SudokuGridPainter(
        selectedCell: selectedCell,
        highlightedCells: highlightedCells,
        conflictCells: conflictCells,
        extension: extension,
        colorScheme: colorScheme,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final col = index % 9;
          final position = CellPosition(row: row, col: col);
          final isFixed = puzzle.grid[row][col] != 0;
          final userValue = userGrid[row][col];
          final value =
              userValue != 0
                  ? userValue
                  : (isFixed ? puzzle.grid[row][col] : null);
          final cellNotes = notes[row][col];
          final isSelected = selectedCell == position;
          final isHighlighted = highlightedCells.contains(position);
          final isConflicted = conflictCells.contains(position);

          return _SudokuCell(
            key: ValueKey('cell_$row$col'),
            row: row,
            col: col,
            value: value,
            cellNotes: cellNotes,
            isFixed: isFixed,
            isSelected: isSelected,
            isHighlighted: isHighlighted,
            isConflicted: isConflicted,
            isNoteMode: isNoteMode,
            onCellTap: onCellTap,
            onCellLongPress: onCellLongPress,
            extension: extension,
            colorScheme: colorScheme,
          );
        },
      ),
    );
  }
}

class _SudokuGridPainter extends CustomPainter {
  _SudokuGridPainter({
    required this.selectedCell,
    required this.highlightedCells,
    required this.conflictCells,
    required this.extension,
    required this.colorScheme,
  });

  final CellPosition? selectedCell;
  final Set<CellPosition> highlightedCells;
  final Set<CellPosition> conflictCells;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 9;
    const thinLineWidth = 1.0;
    const thickLineWidth = 3.0;

    final thinPaint =
        Paint()
          ..color = extension.cellBorder
          ..strokeWidth = thinLineWidth
          ..style = PaintingStyle.stroke;

    final thickPaint =
        Paint()
          ..color = extension.subGridLineColor
          ..strokeWidth = thickLineWidth
          ..style = PaintingStyle.stroke;

    final selectedRow = selectedCell?.row;
    final selectedCol = selectedCell?.col;

    for (int i = 0; i <= 9; i++) {
      final offset = i * cellSize;
      final isThick = i % 3 == 0;
      final paint = isThick ? thickPaint : thinPaint;

      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }

    if (selectedCell != null) {
      _drawHighlights(canvas, size, cellSize, selectedRow!, selectedCol!);
    }
  }

  void _drawHighlights(
    Canvas canvas,
    Size size,
    double cellSize,
    int selectedRow,
    int selectedCol,
  ) {
    final highlightPaint =
        Paint()
          ..color = extension.cellHighlightBackground
          ..style = PaintingStyle.fill;

    final relatedPaint =
        Paint()
          ..color = extension.cellRelatedBackground
          ..style = PaintingStyle.fill;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final position = CellPosition(row: row, col: col);
        if (highlightedCells.contains(position)) {
          final rect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          if (row == selectedRow && col == selectedCol) {
            canvas.drawRect(rect, highlightPaint);
          } else if (row == selectedRow ||
              col == selectedCol ||
              (row ~/ 3 == selectedRow ~/ 3 && col ~/ 3 == selectedCol ~/ 3)) {
            canvas.drawRect(rect, relatedPaint);
          }
        }
      }
    }

    if (conflictCells.isNotEmpty) {
      final conflictPaint =
          Paint()
            ..color = extension.cellErrorBackground.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
      for (final pos in conflictCells) {
        final rect = Rect.fromLTWH(
          pos.col * cellSize,
          pos.row * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(rect, conflictPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuGridPainter oldDelegate) {
    return oldDelegate.selectedCell != selectedCell ||
        oldDelegate.highlightedCells != highlightedCells ||
        oldDelegate.conflictCells != conflictCells ||
        oldDelegate.extension != extension;
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
    required this.isNoteMode,
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
  final bool isNoteMode;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellLongPress;
  final AppThemeExtension extension;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, borderColor) = _getCellDecoration();

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(color: backgroundColor),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCellTap(row, col),
            onLongPress: () => onCellLongPress(row, col),
            borderRadius: BorderRadius.zero,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: _buildCellContent(),
          ),
        ),
      ),
    );
  }

  (Color, Color) _getCellDecoration() {
    if (isConflicted) {
      return (extension.cellErrorBackground, extension.cellErrorBorder);
    }
    if (isSelected) {
      return (extension.cellSelectedBackground, extension.cellSelectedBorder);
    }
    if (isHighlighted) {
      return (extension.cellHighlightBackground, Colors.transparent);
    }
    if (isFixed) {
      return (extension.cellFixedBackground, Colors.transparent);
    }
    return (extension.cellBackground, Colors.transparent);
  }

  Widget _buildCellContent() {
    if (value != null) {
      return _NumberCell(
        value: value!,
        isFixed: isFixed,
        isConflicted: isConflicted,
        isSelected: isSelected,
        extension: extension,
      );
    }

    if (cellNotes.isNotEmpty) {
      return _NotesCell(notes: cellNotes, extension: extension);
    }

    return const SizedBox.shrink();
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    required this.value,
    required this.isFixed,
    required this.isConflicted,
    required this.isSelected,
    required this.extension,
  });

  final int value;
  final bool isFixed;
  final bool isConflicted;
  final bool isSelected;
  final AppThemeExtension extension;

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
            fontSize: 28,
            fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
            color:
                isConflicted
                    ? Colors.redAccent
                    : (isFixed ? Colors.white : Colors.lightBlueAccent),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _NotesCell extends StatelessWidget {
  const _NotesCell({required this.notes, required this.extension});

  final Set<int> notes;
  final AppThemeExtension extension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth;
        final noteSize = cellSize / 3;
        final fontSize = (noteSize * 0.55).clamp(8.0, 14.0);

        return Padding(
          padding: EdgeInsets.all(cellSize * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (row) {
              return SizedBox(
                height: noteSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (col) {
                    final number = row * 3 + col + 1;
                    final showNote = notes.contains(number);
                    return SizedBox(
                      width: noteSize,
                      child: Center(
                        child:
                            showNote
                                ? Text(
                                  number.toString(),
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade400,
                                    height: 1.0,
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
