import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildSettingTile(
                context,
                icon: Icons.palette_rounded,
                title: 'Theme',
                subtitle: settings.themeMode.capitalize(),
                onTap: () => _showThemeDialog(context, ref),
              ),
            ],
          ),
          _buildSection(
            context,
            'Game',
            [
              _buildSettingTile(
                context,
                icon: Icons.difficulty_rounded,
                title: 'Default Difficulty',
                subtitle: settings.selectedDifficulty.capitalize(),
                onTap: () => _showDifficultyDialog(context, ref),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.auto_awesome_rounded,
                title: 'Auto Notes',
                subtitle: 'Automatically fill in notes for empty cells',
                value: settings.autoNotes,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleAutoNotes(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.error_outline_rounded,
                title: 'Highlight Errors',
                subtitle: 'Show incorrect numbers in red',
                value: settings.highlightErrors,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .toggleHighlightErrors(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.visibility_rounded,
                title: 'Highlight Related',
                subtitle: 'Highlight cells in same row, column, and box',
                value: settings.highlightRelated,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .toggleHighlightRelated(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.format_list_numbered_rounded,
                title: 'Number First Input',
                subtitle: 'Select number first, then tap cell',
                value: settings.numberFirstInput,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .toggleNumberFirstInput(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.notes_rounded,
                title: 'Auto Clear Notes',
                subtitle: 'Remove notes when placing a number',
                value: settings.autoClearNotes,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .toggleAutoClearNotes(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Feedback',
            [
              _buildSwitchTile(
                context,
                icon: Icons.volume_up_rounded,
                title: 'Sound Effects',
                subtitle: 'Play sounds for actions and events',
                value: settings.soundEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleSound(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: settings.hapticsEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleHaptics(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Display',
            [
              _buildSwitchTile(
                context,
                icon: Icons.timer_rounded,
                title: 'Show Timer',
                subtitle: 'Display timer during gameplay',
                value: settings.showTimer,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleShowTimer(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.lightbulb_rounded,
                title: 'Show Hints',
                subtitle: 'Allow using hints during gameplay',
                value: settings.showHints,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleShowHints(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.save_rounded,
                title: 'Auto Save',
                subtitle: 'Automatically save game progress',
                value: settings.autoSave,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleAutoSave(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Data',
            [
              _buildSettingTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: 'Reset Statistics',
                subtitle: 'Clear all game statistics and history',
                onTap: () => _showResetDialog(context, ref),
                isDestructive: true,
              ),
              _buildSettingTile(
                context,
                icon: Icons.restore_rounded,
                title: 'Reset Settings',
                subtitle: 'Restore all settings to defaults',
                onTap: () => _showResetSettingsDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              _buildSettingTile(
                context,
                icon: Icons.info_rounded,
                title: 'Version',
                subtitle: 'M6 Sudoku ${AppConstants.appVersion}',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.star_rounded,
                title: 'Rate App',
                subtitle: 'Enjoying M6 Sudoku? Rate us!',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacingMd,
            bottom: AppConstants.spacingSm,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
        const SizedBox(height: AppConstants.spacingLg),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.read(settingsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.difficulties.map((difficulty) {
            return RadioListTile<String>(
              title: Text(AppConstants.difficultyNames[difficulty]!),
              value: difficulty,
              groupValue: settings.selectedDifficulty,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateDifficulty(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
            'This will permanently delete all your game statistics and history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Reset statistics
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistics reset')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'This will restore all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
