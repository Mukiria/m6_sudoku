import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/sudoku_widgets.dart';
import '../../features/sudoku/presentation/providers/game_provider.dart';
import '../../features/sudoku/domain/entities/puzzle.dart';
import '../../features/sudoku/presentation/widgets/number_pad.dart';
import '../../features/sudoku/presentation/widgets/game_header.dart';
import '../../features/sudoku/presentation/widgets/pause_menu.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final difficulty = Difficulty.values.firstWhere(
        (d) => d.name == widget.difficulty,
        orElse: () => Difficulty.easy,
      );
      ref.read(gameProvider.notifier).newGame(difficulty);
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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final timer = ref.watch(timerControllerProvider);
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
                onHint: () => ref.read(gameProvider.notifier).useHint(),
                onUndo: () => ref.read(gameProvider.notifier).undo(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = constraints.maxWidth - 32;
                    return Center(
                      child: Container(
                        width: gridSize.clamp(0, AppConstants.gridSize),
                        height: gridSize.clamp(0, AppConstants.gridSize),
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
                        child: _buildGrid(gameState, extension),
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
                        ref.read(gameProvider.notifier).selectNumber(number),
                onNoteModeToggle:
                    () => ref.read(gameProvider.notifier).toggleNoteMode(),
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
                    onPressed: () => ref.read(gameProvider.notifier).undo(),
                    variant: ActionButtonVariant.secondary,
                    isEnabled: gameState.moveHistory.isNotEmpty,
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  ActionButton(
                    icon: const Icon(Icons.lightbulb_rounded),
                    label: 'Hint',
                    onPressed: () => ref.read(gameProvider.notifier).useHint(),
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
                            .read(gameProvider.notifier)
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

  Widget _buildGrid(GameState gameState, AppThemeExtension extension) {
    return Column(
      children: List.generate(9, (row) {
        return Expanded(
          child: Row(
            children: List.generate(9, (col) {
              final cell = gameState.cells[row][col];
              final isSubGridBorder = col % 3 == 0 || row % 3 == 0;

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            col % 3 == 2
                                ? extension.subGridLineColor
                                : extension.gridLineColor,
                        width: col % 3 == 2 ? 2 : 1,
                      ),
                      bottom: BorderSide(
                        color:
                            row % 3 == 2
                                ? extension.subGridLineColor
                                : extension.gridLineColor,
                        width: row % 3 == 2 ? 2 : 1,
                      ),
                    ),
                  ),
                  child: SudokuCell(
                    value: cell.value,
                    notes: cell.notes,
                    isSelected: cell.isSelected,
                    isFixed: cell.isFixed,
                    hasError: cell.hasError,
                    isHighlighted: cell.isHighlighted,
                    isRelated: cell.isRelated,
                    onTap:
                        () => ref
                            .read(gameProvider.notifier)
                            .selectCell(row, col),
                    onLongPress: () => _showCellOptions(row, col, gameState),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Map<int, int> _getNumberCounts(GameState gameState) {
    final counts = <int, int>{};
    for (int i = 1; i <= 9; i++) {
      counts[i] = 0;
    }

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final value = gameState.cells[r][c].value;
        if (value != null) {
          counts[value] = (counts[value] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  Set<int> _getDisabledNumbers(GameState gameState) {
    final disabled = <int>{};
    final counts = _getNumberCounts(gameState);

    for (int i = 1; i <= 9; i++) {
      if (counts[i] != null && counts[i]! >= 9) {
        disabled.add(i);
      }
    }
    return disabled;
  }

  void _showCellOptions(int row, int col, GameState gameState) {
    final cell = gameState.cells[row][col];
    if (cell.isFixed) return;

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
                        ref.read(gameProvider.notifier).clearCell(row, col);
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
                        cell.notes.isNotEmpty ? 'Clear Notes' : 'Add Notes',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
