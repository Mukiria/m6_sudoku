import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../shared/widgets/sudoku_widgets.dart';
import '../../features/sudoku/presentation/providers/game_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    if (gameState == null) return const SizedBox.shrink();

    final selectedNumber = gameState.selectedNumber;
    final isNoteMode = gameState.isNoteMode;

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
                  icon: Icons.format_size_rounded,
                  label: 'Numbers',
                  isSelected: !isNoteMode,
                  onTap: () =>
                      ref.read(gameProvider.notifier).toggleNoteMode(false),
                ),
              ),
              Expanded(
                child: _buildModeButton(
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  isSelected: isNoteMode,
                  onTap: () =>
                      ref.read(gameProvider.notifier).toggleNoteMode(true),
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
                  onTap: () =>
                      ref.read(gameProvider.notifier).clearSelectedCell(),
                  color: extension.eraseButtonBackground,
                  textColor: extension.eraseButtonText,
                );
              }

              final number = index + 1;
              final isSelected = selectedNumber == number;
              final count = _getRemainingCount(gameState, number);

              return NumberButton(
                number: number,
                isSelected: isSelected,
                isEnabled: true,
                onTap: () =>
                    ref.read(gameProvider.notifier).selectNumber(number),
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
                  onTap: () => ref.read(gameProvider.notifier).useHint(),
                  color: extension.hintButtonBackground,
                  textColor: extension.hintButtonText,
                  isEnabled: hintsUsed < 3,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: () => ref.read(gameProvider.notifier).undo(),
                  color: extension.undoButtonBackground,
                  textColor: extension.undoButtonText,
                  isEnabled: gameState.undoStack.isNotEmpty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
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
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
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
            color: isEnabled ? color : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: isEnabled ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isEnabled ? textColor : textColor.withOpacity(0.3),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? textColor : textColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getRemainingCount(GameState state, int number) {
    // This would be calculated from the puzzle solution
    return 9; // Simplified
  }
}
