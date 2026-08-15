import 'package:flutter/material.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';

/// The floating stat card: difficulty, mistake count, timer, and pause.
/// Undo lives in [NumberPad]'s action row now, so this widget only needs
/// to display state — it has no Riverpod dependency of its own.
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.difficulty,
    required this.timeElapsed,
    required this.mistakes,
    required this.onPause,
  });

  final String difficulty;
  final int timeElapsed;
  final int mistakes;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            difficulty.capitalize(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Mistake: $mistakes/3',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(timeElapsed),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          IconButton(
            onPressed: onPause,
            icon: const Icon(Icons.pause_rounded),
            tooltip: 'Pause',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
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
