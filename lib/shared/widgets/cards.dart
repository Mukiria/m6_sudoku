import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.elevation = 1,
    this.color,
    this.borderColor,
    this.borderRadius = 16,
    this.onTap,
    this.inkColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? inkColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: elevation,
      margin: margin,
      color: color ?? colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: borderColor ?? colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: inkColor ?? colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: inkColor?.withValues(alpha: 0.05) ??
            colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendIsPositive,
    this.onTap,
  });

  final String title;
  final String value;
  final Widget? icon;
  final Color? iconColor;
  final String? trend;
  final bool? trendIsPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;

    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? colorScheme.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                        color: iconColor ?? colorScheme.primary, size: 20),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trendIsPositive == true
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 14,
                  color: trendIsPositive == true
                      ? Colors.green
                      : (trendIsPositive == false
                          ? Colors.red
                          : colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: trendIsPositive == true
                        ? Colors.green
                        : (trendIsPositive == false
                            ? Colors.red
                            : colorScheme.onSurfaceVariant),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
    this.cluesCount,
    this.bestTime,
    this.completionRate,
  });

  final String difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  final int? cluesCount;
  final int? bestTime;
  final double? completionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;

    Color difficultyColor;
    String difficultyLabel;

    switch (difficulty) {
      case 'easy':
        difficultyColor = extension.difficultyEasyColor;
        difficultyLabel = 'Easy';
        break;
      case 'medium':
        difficultyColor = extension.difficultyMediumColor;
        difficultyLabel = 'Medium';
        break;
      case 'hard':
        difficultyColor = extension.difficultyHardColor;
        difficultyLabel = 'Hard';
        break;
      case 'expert':
        difficultyColor = extension.difficultyExpertColor;
        difficultyLabel = 'Expert';
        break;
      default:
        difficultyColor = colorScheme.primary;
        difficultyLabel = difficulty.capitalize();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? difficultyColor : colorScheme.outlineVariant,
                width: isSelected ? 2.5 : 1.5,
              ),
              color: isSelected
                  ? difficultyColor.withValues(alpha: 0.1)
                  : colorScheme.surface,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: difficultyColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? difficultyColor
                            : difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        difficultyLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : difficultyColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: difficultyColor,
                        size: 24,
                      )
                          .animate()
                          .scale(duration: 200.ms, curve: Curves.elasticOut),
                  ],
                ),
                const SizedBox(height: 16),
                if (cluesCount != null) ...[
                  _buildInfoRow(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Clues',
                    value: cluesCount.toString(),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                ],
                if (bestTime != null) ...[
                  _buildInfoRow(
                    icon: Icons.timer_rounded,
                    label: 'Best Time',
                    value: _formatTime(bestTime!),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                ],
                if (completionRate != null) ...[
                  _buildInfoRow(
                    icon: Icons.percent_rounded,
                    label: 'Completion',
                    value: '${(completionRate! * 100).toStringAsFixed(0)}%',
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 200.ms,
        );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.7)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
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

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
