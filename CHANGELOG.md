# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-15

### Added
- Initial release of M6 Sudoku
- Clean Architecture with Feature-first structure
- Riverpod state management with code generation
- GoRouter for declarative navigation
- Material 3 theming with light/dark mode support
- Multiple difficulty levels: Easy, Medium, Hard, Expert, Evil
- Daily challenges with new puzzles every day
- Achievement system with 20+ unlockable achievements
- Statistics tracking with charts and graphs
- Hints system with multiple hint types (direct reveal, naked single, hidden single, etc.)
- Undo/Redo functionality with full move history
- Auto-save and game state persistence
- Responsive layout for phones, tablets, and web
- Smooth animations with flutter_animate
- Audio feedback for interactions
- Performance optimizations (bitmask-based notes, optimized puzzle generation)

### Technical Details
- **Engine**: Custom Sudoku solver with MRV heuristic and backtracking
- **Generator**: Puzzle generator with fast uniqueness checking
- **Validator**: Unique solution validator with early exit optimization
- **Storage**: SharedPreferences for local data persistence
- **Testing**: Unit tests, widget tests, and integration tests

### Platforms
- Android (API 21+)
- Web (Chrome, Firefox, Safari, Edge)

## [Unreleased]

### Planned
- iOS support
- macOS support
- Windows support
- Linux support
- Cloud sync for game progress
- Multiplayer mode
- Custom puzzle import/export
- Accessibility improvements