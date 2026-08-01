import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:m6_sudoku/core/constants/app_constants.dart';
import 'package:m6_sudoku/core/theme/app_theme_extension.dart';
import 'package:m6_sudoku/shared/widgets/buttons.dart';
import 'package:m6_sudoku/shared/widgets/sudoku_widgets.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/game_provider.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/puzzle.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/game_state.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/number_pad.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/game_header.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/pause_menu.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/sudoku_board.dart';
import 'package:m6_sudoku/features/sudoku/presentation/widgets/hint_overlay.dart';
import 'package:m6_sudoku/core/routing/app_router.dart';
import 'package:m6_sudoku/features/sudoku/engine/models/difficulty.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final String difficulty;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showPauseMenu = false;
  bool _hasNavigated = false;
  bool _showHintOverlay = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameControllerProvider);

      // If there's no saved game state, create a new game
      if (gameState == null || gameState.status != GameStatus.playing) {
        final difficulty = Difficulty.values.firstWhere(
          (d) => d.name == widget.difficulty,
          orElse: () => Difficulty.easy,
        );
        ref.read(gameControllerProvider.notifier).newGame(difficulty);
      }
      ref.read(timerControllerProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      _showPauseMenu = true;
      _showPauseOverlay();
    }
  }

  void _showPauseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PauseMenu(),
    ).whenComplete(() {
      _showPauseMenu = false;
      if (mounted) {
        _tabController.animateTo(0);
      }
    });
  }

  void _checkGameStatus(GameState gameState) {
    if (_hasNavigated) return;

    if (gameState.status == GameStatus.completed) {
      _hasNavigated = true;
      ref.read(timerControllerProvider.notifier).pause();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(
            AppRoutes.completion,
            extra: {
              'time': gameState.timeElapsed,
              'mistakes': gameState.mistakes,
              'hintsUsed': gameState.hintsUsed,
              'difficulty': gameState.difficulty.name,
            },
          );
        }
      });
    } else if (gameState.status == GameStatus.failed) {
      _hasNavigated = true;
      ref.read(timerControllerProvider.notifier).pause();
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You made 3 mistakes. Better luck next time!'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.go(AppRoutes.home);
            },
            child: const Text('Main Menu'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              final difficulty = Difficulty.values.firstWhere(
                (d) => d.name == widget.difficulty,
                orElse: () => Difficulty.easy,
              );
              ref.read(gameControllerProvider.notifier).newGame(difficulty);
              ref.read(timerControllerProvider.notifier).reset();
              ref.read(timerControllerProvider.notifier).start();
              _hasNavigated = false;
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _checkHintState(GameState gameState) {
    if (gameState.hintState != null && !_showHintOverlay) {
      _showHintOverlay = true;
      _showHintOverlayDialog(gameState.hintState!);
    }
  }

  void _showHintOverlayDialog(HintState hintState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HintOverlay(
        hintState: hintState,
        onDismiss: () {
          Navigator.of(context).pop();
          setState(() {
            _showHintOverlay = false;
          });
          // Clear hint state after dismissing
          ref.read(gameControllerProvider.notifier).clearHintState();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check game status after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGameStatus(gameState);
      _checkHintState(gameState);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showPauseOverlay();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GameHeader(
                difficulty: widget.difficulty,
                timeElapsed: gameState.timeElapsed,
                mistakes: gameState.mistakes,
                hintsUsed: gameState.hintsUsed,
                onPause: _showPauseOverlay,
                onHint: () => ref.read(gameControllerProvider.notifier).useHint(),
                onUndo: () => ref.read(gameControllerProvider.notifier).undo(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = constraints.maxWidth - 32;
                    return Center(
                      child: Container(
                        width: gridSize.clamp(0, AppConstants.gridSizePx),
                        height: gridSize.clamp(0, AppConstants.gridSizePx),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: extension.gridBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(
                            color: extension.subGridLineColor,
                            width: 2.5,
                          ),
                        ),
                        child: SudokuBoard(
                          puzzle: gameState.puzzle,
                          userGrid: gameState.userGrid,
                          notes: gameState.notes,
                          selectedCell: gameState.selectedCell,
                          highlightedCells: gameState.highlightedCells,
                          conflictCells: gameState.conflictCells,
                          isNoteMode: gameState.isNoteMode,
                          onCellTap:
                              (row, col) => ref
                                  .read(gameControllerProvider.notifier)
                                  .selectCell(row, col),
                          onCellLongPress:
                              (row, col) =>
                                  _showCellOptions(row, col, gameState),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              NumberPad(
                selectedNumber: gameState.selectedNumber,
                onNumberSelected:
                    (number) =>
                        ref.read(gameControllerProvider.notifier).selectNumber(number),
                onNoteModeToggle:
                    () => ref.read(gameControllerProvider.notifier).toggleNoteMode(),
                isNoteMode: gameState.isNoteMode,
                counts: _getNumberCounts(gameState),
                disabledNumbers: _getDisabledNumbers(gameState),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionButton(
                    icon: const Icon(Icons.undo_rounded),
                    label: 'Undo',
                    onPressed: () => ref.read(gameControllerProvider.notifier).undo(),
                    variant: ActionButtonVariant.secondary,
                    isEnabled: gameState.moveHistory.isNotEmpty,
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  ActionButton(
                    icon: const Icon(Icons.lightbulb_rounded),
                    label: 'Hint',
                    onPressed: () => ref.read(gameControllerProvider.notifier).useHint(),
                    variant: ActionButtonVariant.primary,
                    isEnabled: gameState.hintsUsed < 3,
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  ActionButton(
                    icon: const Icon(Icons.delete_rounded),
                    label: 'Erase',
                    onPressed: () {
                      if (gameState.selectedCell != null) {
                        ref
                            .read(gameControllerProvider.notifier)
                            .clearCell(
                              gameState.selectedCell!.row,
                              gameState.selectedCell!.col,
                            );
                      }
                    },
                    variant: ActionButtonVariant.destructive,
                    isEnabled: gameState.selectedCell != null,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  void _showCellOptions(int row, int col, GameState gameState) {
    final isFixed = gameState.puzzle.grid[row][col] != 0;
    if (isFixed) return;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cell Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).clearCell(row, col);
                    Navigator.pop(context);
                  },
                  variant: AppButtonVariant.outlined,
                  child: const Text('Clear'),
                ),
                AppButton(
                  onPressed: () {
                    // Toggle note mode for this cell
                    Navigator.pop(context);
                  },
                  variant: AppButtonVariant.filled,
                  child: Text(
                    gameState.notes[row][col].isNotEmpty
                        ? 'Clear Notes'
                        : 'Add Notes',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _getNumberCounts(GameState state) {
    final counts = <int, int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = state.userGrid[r][c];
        if (val != 0) {
          counts[val] = (counts[val] ?? 0) + 1;
        }
      }
    }
    // Return remaining counts (9 - used)
    final remaining = <int, int>{};
    for (int i = 1; i <= 9; i++) {
      remaining[i] = 9 - (counts[i] ?? 0);
    }
    return remaining;
  }

  Set<int> _getDisabledNumbers(GameState state) {
    final disabled = <int>{};
    final counts = _getNumberCounts(state);
    for (int i = 1; i <= 9; i++) {
      if ((counts[i] ?? 9) <= 0) {
        disabled.add(i);
      }
    }
    return disabled;
  }
}