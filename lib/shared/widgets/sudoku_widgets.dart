import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';

class SudokuCell extends StatelessWidget {
  const SudokuCell({
    super.key,
    required this.value,
    required this.notes,
    required this.isSelected,
    required this.isFixed,
    required this.hasError,
    required this.isHighlighted,
    required this.isRelated,
    required this.onTap,
    this.onLongPress,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  final int? value;
  final List<int> notes;
  final bool isSelected;
  final bool isFixed;
  final bool hasError;
  final bool isHighlighted;
  final bool isRelated;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color borderColor;
    double borderWidth = 1;

    if (hasError) {
      backgroundColor = extension.cellErrorBackground;
      borderColor = extension.cellErrorBorder;
      borderWidth = 2;
    } else if (isSelected) {
      backgroundColor = extension.cellSelectedBackground;
      borderColor = extension.cellSelectedBorder;
      borderWidth = 2;
    } else if (isHighlighted) {
      backgroundColor = extension.cellHighlightBackground;
      borderColor = extension.cellBorder;
    } else if (isRelated) {
      backgroundColor = extension.cellRelatedBackground;
      borderColor = extension.cellBorder;
    } else if (isFixed) {
      backgroundColor = extension.cellFixedBackground;
      borderColor = extension.cellFixedBorder;
    } else {
      backgroundColor = extension.cellBackground;
      borderColor = extension.cellBorder;
    }

    final textColor = isFixed ? colorScheme.onSurface : colorScheme.primary;
    final noteColor = colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.zero,
          child: _buildContent(textColor, noteColor),
        ),
      ),
    )
        .animate(
          target: isSelected ? 1 : 0,
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: animationDuration,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildContent(Color textColor, Color noteColor) {
    if (value != null) {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: isFixed ? FontWeight.w600 : FontWeight.w500,
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
                    _buildNote(row * 3 + col + 1, noteColor),
                ],
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNote(int number, Color noteColor) {
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

class NumberButton extends StatelessWidget {
  const NumberButton({
    super.key,
    required this.number,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    this.count,
    this.showCount = false,
  });

  final int number;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;
  final int? count;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (!isEnabled) {
      backgroundColor = extension.numberButtonDisabledBackground;
      textColor = extension.numberButtonDisabledText;
      borderColor = colorScheme.outlineVariant;
    } else if (isSelected) {
      backgroundColor = extension.numberButtonSelectedBackground;
      textColor = extension.numberButtonSelectedText;
      borderColor = extension.numberButtonSelectedBackground;
    } else {
      backgroundColor = extension.numberButtonBackground;
      textColor = extension.numberButtonText;
      borderColor = colorScheme.outlineVariant;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: extension.numberButtonSelectedBackground
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (showCount && count != null && count! > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? extension.numberButtonSelectedBackground
                              : colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
          duration: const Duration(milliseconds: 100),
        );
  }
}

class NoteButton extends StatelessWidget {
  const NoteButton({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? extension.noteButtonSelectedBackground
                : extension.noteButtonBackground,
            border: Border.all(
              color: isSelected
                  ? extension.noteButtonSelectedBackground
                  : colorScheme.outlineVariant,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? extension.noteButtonSelectedText
                    : extension.noteButtonText,
              ),
            ),
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
          duration: const Duration(milliseconds: 100),
        );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.variant = ActionButtonVariant.primary,
    this.isLoading = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final ActionButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color iconColor;

    switch (variant) {
      case ActionButtonVariant.primary:
        backgroundColor = extension.hintButtonBackground;
        textColor = extension.hintButtonText;
        iconColor = extension.hintButtonText;
        break;
      case ActionButtonVariant.secondary:
        backgroundColor = extension.undoButtonBackground;
        textColor = extension.undoButtonText;
        iconColor = extension.undoButtonText;
        break;
      case ActionButtonVariant.destructive:
        backgroundColor = extension.eraseButtonBackground;
        textColor = extension.eraseButtonText;
        iconColor = extension.eraseButtonText;
        break;
    }

    if (!isEnabled) {
      backgroundColor = colorScheme.onSurface.withOpacity(0.12);
      textColor = colorScheme.onSurface.withOpacity(0.38);
      iconColor = colorScheme.onSurface.withOpacity(0.38);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme(
                      data: IconThemeData(color: iconColor, size: 20),
                      child: icon,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

enum ActionButtonVariant {
  primary,
  secondary,
  destructive,
}
