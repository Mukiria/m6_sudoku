import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../shared/widgets/buttons.dart';
import '../../features/sudoku/presentation/providers/game_provider.dart';
import '../../features/sudoku/domain/entities/puzzle.dart';
import '../../features/sudoku/presentation/widgets/number_pad.dart';
import '../../features/sudoku/presentation/widgets/game_header.dart';
import '../../features/sudoku/presentation/widgets/pause_menu.dart';
import '../../features/sudoku/presentation/widgets/sudoku_board.dart';

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
                                  .read(gameProvider.notifier)
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
