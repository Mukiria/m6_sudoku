import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/features/home/presentation/screens/home_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/game_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/difficulty_selection_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/completion_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/puzzle_loading_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/daily_challenge_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/screens/achievement_screen.dart';
import 'package:m6_sudoku/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:m6_sudoku/features/settings/presentation/screens/settings_screen.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/pause_menu.dart';
import 'package:riverpod/riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    // Custom page transitions
    pageBuilder: (context, state, child) {
      return CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Different transitions for different routes
          final routeName = state.matchedLocation;
          
          if (routeName == AppRoutes.game || routeName == AppRoutes.completion) {
            // Slide up for game screens
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          } else if (routeName == AppRoutes.achievements || routeName == AppRoutes.dailyChallenge) {
            // Fade + scale for modal-like screens
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          } else {
            // Default fade for other screens
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          }
        },
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.difficultySelection,
        name: 'difficulty',
        builder: (context, state) => const DifficultySelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) {
          final difficulty = state.extra as String?;
          return GameScreen(
            difficulty: difficulty ?? AppConstants.difficultyEasy,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.pause,
        name: 'pause',
        builder: (context, state) => const PauseMenu(),
      ),
      GoRoute(
        path: AppRoutes.completion,
        name: 'completion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CompletionScreen(
            time: extra?['time'] as int? ?? 0,
            mistakes: extra?['mistakes'] as int? ?? 0,
            hintsUsed: extra?['hintsUsed'] as int? ?? 0,
            difficulty:
                extra?['difficulty'] as String? ?? AppConstants.difficultyEasy,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.puzzleLoading,
        name: 'puzzleLoading',
        builder: (context, state) {
          final difficulty = state.extra as String?;
          return PuzzleLoadingScreen(
            difficulty: difficulty ?? AppConstants.difficultyEasy,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dailyChallenge,
        name: 'dailyChallenge',
        builder: (context, state) => const DailyChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
});

class AppRoutes {
  static const String home = '/';
  static const String difficultySelection = '/difficulty';
  static const String game = '/game';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String pause = '/pause';
  static const String completion = '/completion';
  static const String puzzleLoading = '/loading';
  static const String dailyChallenge = '/daily';
  static const String achievements = '/achievements';

  static String get homeRoute => home;
  static String get difficultyRoute => difficultySelection;
  static String get gameRoute => game;
  static String get statisticsRoute => statistics;
  static String get settingsRoute => settings;
  static String get pauseRoute => pause;
  static String get completionRoute => completion;
  static String get puzzleLoadingRoute => puzzleLoading;
  static String get dailyChallengeRoute => dailyChallenge;
  static String get achievementsRoute => achievements;
}
