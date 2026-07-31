import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/shared/widgets/sudoku_widgets.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({
    super.key,
    required this.selectedNumber,
    required this.onNumberSelected,
    required this.onNoteModeToggle,
    required this.isNoteMode,
    required this.counts,
    required this.disabledNumbers,
  });

  final int? selectedNumber;
  final void Function(int) onNumberSelected;
  final void Function() onNoteModeToggle;
  final bool isNoteMode;
  final Map<int, int> counts;
  final Set<int> disabledNumbers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    if (gameState == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildModeButton(
                  context: context,
                  icon: Icons.format_size_rounded,
                  label: 'Numbers',
                  isSelected: !isNoteMode,
                  onTap: () => onNoteModeToggle(),
                ),
              ),
              Expanded(
                child: _buildModeButton(
                  context: context,
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  isSelected: isNoteMode,
                  onTap: () => onNoteModeToggle(),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Number Buttons
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              if (index == 9) {
                return _buildActionButton(
                  icon: Icons.backspace_rounded,
                  label: 'Erase',
                  onTap: () {
                    if (gameState.selectedCell != null) {
                      ref.read(gameControllerProvider.notifier).clearCell(
                        gameState.selectedCell!.row,
                        gameState.selectedCell!.col,
                      );
                    }
                  },
                  color: extension.eraseButtonBackground!,
                  textColor: extension.eraseButtonText!,
                );
              }

              final number = index + 1;
              final isSelected = selectedNumber == number;
              final count = counts[number] ?? 9;
              final isDisabled = disabledNumbers.contains(number);

              return NumberButton(
                number: number,
                isSelected: isSelected,
                isEnabled: !isDisabled,
                onTap: () => onNumberSelected(number),
                count: count,
                showCount: true,
              );
            },
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.lightbulb_rounded,
                  label: 'Hint',
                  onTap: () => ref.read(gameControllerProvider.notifier).useHint(),
                  color: extension.hintButtonBackground!,
                  textColor: extension.hintButtonText!,
                  isEnabled: gameState.hintsUsed < 3,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: () => ref.read(gameControllerProvider.notifier).undo(),
                  color: extension.undoButtonBackground!,
                  textColor: extension.undoButtonText!,
                  isEnabled: gameState.moveHistory.isNotEmpty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color:
                  isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isEnabled ? color : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: isEnabled ? color : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isEnabled ? textColor : textColor.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isEnabled ? textColor : textColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}