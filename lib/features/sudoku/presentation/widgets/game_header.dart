import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';

class GameHeader extends ConsumerWidget {
  const GameHeader({
    super.key,
    required this.difficulty,
    required this.timeElapsed,
    required this.mistakes,
    required this.hintsUsed,
    required this.onPause,
    required this.onHint,
  });

  final String difficulty;
  final int timeElapsed;
  final int mistakes;
  final int hintsUsed;
  final VoidCallback onPause;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(extension).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  difficulty.capitalize(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(extension),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: extension.timerBackground,
                  borderRadius:
                      BorderRadius.circular(AppConstants.largeBorderRadius),
                ),
                child: Text(
                  _formatTime(timeElapsed),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: extension.timerText,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onPause,
                icon: const Icon(Icons.pause_rounded),
                tooltip: 'Pause',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                icon: Icons.close_rounded,
                value: '$mistakes/3',
                color: extension.mistakeIndicatorColor,
                label: 'Mistakes',
              ),
              const SizedBox(width: AppConstants.spacingLg),
              _buildStatItem(
                icon: Icons.lightbulb_rounded,
                value: '$hintsUsed/3',
                color: extension.hintIndicatorColor,
                label: 'Hints',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(AppThemeExtension extension) {
    switch (difficulty) {
      case 'easy':
        return extension.difficultyEasyColor;
      case 'medium':
        return extension.difficultyMediumColor;
      case 'hard':
        return extension.difficultyHardColor;
      case 'expert':
        return extension.difficultyExpertColor;
      default:
        return extension.difficultyMediumColor;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
