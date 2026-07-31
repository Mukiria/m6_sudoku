import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/shared/widgets/cards.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/sudoku_providers.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/settings/presentation/providers/settings_provider.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';

class DifficultySelectionScreen extends ConsumerWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Difficulty'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your challenge',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Expanded(
                child: ListView(
                  children:
                      Difficulty.values.map((difficulty) {
                        final index = Difficulty.values.indexOf(difficulty);
                        final isSelected =
                            settings.selectedDifficulty == difficulty.name;

                        return DifficultyCard(
                              difficulty: difficulty,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateDifficulty(difficulty.name);
                                context.push(
                                  AppRoutes.game,
                                  extra: difficulty.name,
                                );
                              },
                            )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                            .slideX(begin: 0.2, end: 0);
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;

    Color difficultyColor;
    switch (difficulty) {
      case Difficulty.easy:
        difficultyColor = extension.difficultyEasyColor;
        break;
      case Difficulty.medium:
        difficultyColor = extension.difficultyMediumColor;
        break;
      case Difficulty.hard:
        difficultyColor = extension.difficultyHardColor;
        break;
      case Difficulty.expert:
        difficultyColor = extension.difficultyExpertColor;
        break;
      case Difficulty.evil:
        difficultyColor = extension.difficultyHardColor; // Use hard color for evil
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            border: Border.all(
              color:
                  isSelected
                      ? difficultyColor
                      : theme.colorScheme.outlineVariant,
              width: isSelected ? 2.5 : 1.5,
            ),
            color:
                isSelected
                    ? difficultyColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: difficultyColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? difficultyColor
                          : difficultyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  difficulty.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : difficultyColor,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDescription(difficulty),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${difficulty.cluesCount} clues',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEstimatedTime(difficulty),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: difficultyColor,
                  size: 28,
                ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }

  String _getDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Perfect for beginners. More clues, easier patterns.';
      case Difficulty.medium:
        return 'Balanced challenge. Standard Sudoku experience.';
      case Difficulty.hard:
        return 'Requires advanced techniques. Fewer clues.';
      case Difficulty.expert:
        return 'Expert level. Minimal clues, complex logic needed.';
      case Difficulty.evil:
        return 'Evil level. Minimal clues, extremely difficult.';
    }
  }

  String _getEstimatedTime(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '5-10 min';
      case Difficulty.medium:
        return '10-20 min';
      case Difficulty.hard:
        return '20-40 min';
      case Difficulty.expert:
        return '40+ min';
      case Difficulty.evil:
        return '40+ min';
    }
  }
}
