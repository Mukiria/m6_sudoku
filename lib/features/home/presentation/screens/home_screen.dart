import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/m6-splash-screen.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingXl),

                  // Title
                  Semantics(
                        label: AppConstants.appName,
                        child: Image.asset(
                          'assets/images/m6-sudokulogotype.png',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),

                  const SizedBox(height: AppConstants.spacingXl),

                  // Continue Game or New Game
                  Consumer(
                    builder: (context, ref, child) {
                      final gameState = ref.watch(gameControllerProvider);
                      final hasSavedGame =
                          gameState != null &&
                          gameState.status != GameStatus.completed &&
                          gameState.status != GameStatus.failed;

                      return Column(
                        children: [
                          if (hasSavedGame) ...[
                            AppButton(
                                  onPressed:
                                      () => _continueGame(
                                        context,
                                        ref,
                                        gameState!,
                                      ),
                                  variant: AppButtonVariant.filled,
                                  size: AppButtonSize.large,
                                  backgroundColor:
                                      AppThemeExtension.brandOrange,
                                  foregroundColor: Colors.white,
                                  child: const Text('Continue Game'),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 200.ms)
                                .slideX(begin: -0.2, end: 0),
                            const SizedBox(height: AppConstants.spacingMd),
                          ],
                          AppButton(
                                onPressed:
                                    () => context.push(
                                      AppRoutes.difficultySelection,
                                    ),
                                variant: AppButtonVariant.filled,
                                size: AppButtonSize.large,
                                backgroundColor: AppThemeExtension.brandOrange,
                                foregroundColor: Colors.white,
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
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

                  const SizedBox(height: AppConstants.spacingMd),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                              icon: Icons.bar_chart_rounded,
                              label: 'Statistics',
                              onPressed:
                                  () => context.push(AppRoutes.statistics),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 500.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _QuickActionButton(
                              icon: Icons.settings_rounded,
                              label: 'Settings',
                              onPressed: () => context.push(AppRoutes.settings),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Version
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continueGame(BuildContext context, WidgetRef ref, GameState gameState) {
    ref.read(gameControllerProvider.notifier).continueGame(gameState);
    context.push(AppRoutes.game);
  }
}

/// A "frosted glass" quick-action tile: sized to fit its icon+label content
/// (rather than a fixed button height) so it never overflows, and styled
/// for legibility over the busy home backdrop image.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
