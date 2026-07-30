import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../shared/widgets/buttons.dart';
import '../../features/sudoku/presentation/providers/game_provider.dart';
import '../../features/statistics/presentation/providers/statistics_provider.dart';

class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({
    super.key,
    required this.time,
    required this.mistakes,
    required this.hintsUsed,
    required this.difficulty,
  });

  final int time;
  final int mistakes;
  final int hintsUsed;
  final String difficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;

    Color difficultyColor;
    switch (difficulty) {
      case 'easy':
        difficultyColor = extension.difficultyEasyColor;
        break;
      case 'medium':
        difficultyColor = extension.difficultyMediumColor;
        break;
      case 'hard':
        difficultyColor = extension.difficultyHardColor;
        break;
      case 'expert':
        difficultyColor = extension.difficultyExpertColor;
        break;
      default:
        difficultyColor = colorScheme.primary;
    }

    // Record the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).recordGame(
            difficulty: difficulty,
            timeSeconds: time,
            mistakes: mistakes,
            hintsUsed: hintsUsed,
            completed: true,
          );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              difficultyColor.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Completion Animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: difficultyColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: difficultyColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1000.ms),

                const SizedBox(height: AppConstants.spacingXl),

                Text(
                  'Puzzle Complete!',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: AppConstants.spacingSm),

                Text(
                  '${difficulty.capitalize()} difficulty solved',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: AppConstants.spacingXl),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompletionStat(
                      theme,
                      icon: Icons.timer_rounded,
                      label: 'Time',
                      value: _formatTime(time),
                      color: extension.timerTextColor,
                      delay: 500,
                    ),
                    _buildCompletionStat(
                      theme,
                      icon: Icons.close_rounded,
                      label: 'Mistakes',
                      value: '$mistakes/3',
                      color: extension.mistakeIndicatorColor,
                      delay: 600,
                    ),
                    _buildCompletionStat(
                      theme,
                      icon: Icons.lightbulb_rounded,
                      label: 'Hints',
                      value: '$hintsUsed/3',
                      color: extension.hintIndicatorColor,
                      delay: 700,
                    ),
                  ],
                ),

                const Spacer(),

                // Buttons
                Column(
                  children: [
                    AppButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).newGame(
                              Difficulty.values.firstWhere(
                                (d) => d.name == difficulty,
                                orElse: () => Difficulty.easy,
                              ),
                            );
                        context.pop();
                      },
                      variant: AppButtonVariant.filled,
                      size: AppButtonSize.large,
                      icon: const Icon(Icons.refresh_rounded),
                      child: const Text('Play Again'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 800.ms)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: AppConstants.spacingMd),
                    AppButton(
                      onPressed: () => context.go(AppRoutes.home),
                      variant: AppButtonVariant.outlined,
                      size: AppButtonSize.large,
                      icon: const Icon(Icons.home_rounded),
                      child: const Text('Main Menu'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 900.ms)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: AppConstants.spacingMd),
                    AppButton(
                      onPressed: () => context.go(AppRoutes.statistics),
                      variant: AppButtonVariant.tonal,
                      size: AppButtonSize.large,
                      icon: const Icon(Icons.bar_chart_rounded),
                      child: const Text('View Statistics'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1000.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int delay,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.3, end: 0);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}
