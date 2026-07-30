import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';

class PauseMenu extends ConsumerWidget {
  const PauseMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;
    final gameState = ref.watch(gameProvider);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Game Paused',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Time: ${_formatTime(gameState?.timeElapsed ?? 0)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          AppButton(
            onPressed: () {
              ref.read(gameProvider.notifier).resume();
              context.pop();
            },
            variant: AppButtonVariant.filled,
            size: AppButtonSize.large,
            icon: const Icon(Icons.play_arrow_rounded),
            child: const Text('Resume'),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          AppButton(
            onPressed: () {
              context.go(AppRoutes.home);
            },
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.large,
            icon: const Icon(Icons.home_rounded),
            child: const Text('Main Menu'),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          AppButton(
            onPressed: () {
              if (gameState != null) {
                ref.read(gameProvider.notifier).newGame(
                      Difficulty.values.firstWhere(
                        (d) => d.name == gameState!.difficulty.name,
                        orElse: () => Difficulty.easy,
                      ),
                    );
              }
              context.pop();
            },
            variant: AppButtonVariant.tonal,
            size: AppButtonSize.large,
            icon: const Icon(Icons.refresh_rounded),
            child: const Text('Restart'),
          ),
          const SizedBox(height: AppConstants.spacingLg),
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
