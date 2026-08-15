import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/features/settings/presentation/providers/settings_provider.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';

/// The row of circular icon buttons above the stat card: back, quick theme
/// cycle, statistics, and settings. Statistics/Settings pause the game
/// timer for the trip and resume it on return.
class GameTopBar extends ConsumerWidget {
  const GameTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm,
        AppConstants.spacingMd,
        0,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.palette_outlined,
            tooltip: 'Theme',
            onTap: () => _cycleTheme(context, ref),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          _CircleIconButton(
            icon: Icons.leaderboard_rounded,
            tooltip: 'Statistics',
            onTap: () => _visit(context, ref, AppRoutes.statistics),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          _CircleIconButton(
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            onTap: () => _visit(context, ref, AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Future<void> _visit(BuildContext context, WidgetRef ref, String route) async {
    ref.read(timerControllerProvider.notifier).pause();
    await context.push(route);
    ref.read(timerControllerProvider.notifier).start();
  }

  void _cycleTheme(BuildContext context, WidgetRef ref) {
    const order = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final current = ref.read(settingsProvider).themeMode;
    final next = order[(order.indexOf(current) + 1) % order.length];
    ref.read(settingsProvider.notifier).updateThemeMode(next);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme: ${next.name.capitalize()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

extension _ThemeModeCapitalize on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
