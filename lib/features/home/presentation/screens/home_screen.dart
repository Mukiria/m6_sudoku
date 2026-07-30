import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_entities.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingXl),

              // Title
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppConstants.spacingSm),

              Text(
                'Classic Sudoku Experience',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppConstants.spacingXl),

              // Continue Game or New Game
              Consumer(
                builder: (context, ref, child) {
                  final gameState = ref.watch(gameProvider);
                  final hasSavedGame = gameState != null &&
                      gameState.status != GameStatus.completed &&
                      gameState.status != GameStatus.failed;

                  return Column(
                    children: [
                      if (hasSavedGame) ...[
                        AppButton(
                          onPressed: () =>
                              _continueGame(context, ref, gameState!),
                          variant: AppButtonVariant.filled,
                          size: AppButtonSize.large,
                          child: const Text('Continue Game'),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 200.ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: AppConstants.spacingMd),
                      ],
                      AppButton(
                        onPressed: () =>
                            context.push(AppRoutes.difficultySelection),
                        variant: AppButtonVariant.filled,
                        size: AppButtonSize.large,
                        icon: const Icon(Icons.add_rounded),
                        child: const Text('New Game'),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 300.ms)
                          .slideX(begin: 0.2, end: 0),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: AppConstants.spacingMd),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: () => context.push(AppRoutes.statistics),
                      variant: AppButtonVariant.outlined,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 24),
                          SizedBox(height: 4),
                          Text('Statistics'),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: AppButton(
                      onPressed: () => context.push(AppRoutes.settings),
                      variant: AppButtonVariant.outlined,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings_rounded, size: 24),
                          SizedBox(height: 4),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),

              const Spacer(),

              // Version
              Text(
                'Version ${AppConstants.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _continueGame(BuildContext context, WidgetRef ref, GameState gameState) {
    context.push(AppRoutes.game, extra: gameState.difficulty.name);
  }
}
