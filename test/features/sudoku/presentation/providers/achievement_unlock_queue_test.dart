import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m6_sudoku/features/sudoku/domain/entities/achievement.dart';
import 'package:m6_sudoku/features/sudoku/presentation/providers/sudoku_providers.dart';

Achievement _achievement(String id) => Achievement(
  id: id,
  name: id,
  description: id,
  icon: '🏆',
  category: AchievementCategory.wins,
  targetValue: 1,
  currentProgress: 1,
  isUnlocked: true,
  isSecret: false,
);

void main() {
  group('AchievementUnlockQueue', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('starts empty', () {
      expect(container.read(achievementUnlockQueueProvider), isEmpty);
    });

    test('push appends and preserves unlock order', () {
      final notifier = container.read(achievementUnlockQueueProvider.notifier);

      notifier.push(_achievement('first_win'));
      notifier.push(_achievement('ten_wins'));

      final queue = container.read(achievementUnlockQueueProvider);
      expect(queue.map((a) => a.id).toList(), ['first_win', 'ten_wins']);
    });

    test('popFirst removes only the front entry', () {
      final notifier = container.read(achievementUnlockQueueProvider.notifier);
      notifier.push(_achievement('first_win'));
      notifier.push(_achievement('ten_wins'));

      notifier.popFirst();

      final queue = container.read(achievementUnlockQueueProvider);
      expect(queue.map((a) => a.id).toList(), ['ten_wins']);
    });

    test('popFirst on an empty queue is a no-op', () {
      final notifier = container.read(achievementUnlockQueueProvider.notifier);
      expect(() => notifier.popFirst(), returnsNormally);
      expect(container.read(achievementUnlockQueueProvider), isEmpty);
    });
  });
}
