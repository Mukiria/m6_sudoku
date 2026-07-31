import 'package:m6_sudoku/core/utils/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = 'An error occurred']);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access forbidden']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Data parsing error']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}

class GameFailure extends Failure {
  const GameFailure([super.message = 'Game error occurred']);
}

class PuzzleFailure extends Failure {
  const PuzzleFailure([super.message = 'Puzzle error occurred']);
}

class SettingsFailure extends Failure {
  const SettingsFailure([super.message = 'Settings error occurred']);
}

class StatisticsFailure extends Failure {
  const StatisticsFailure([super.message = 'Statistics error occurred']);
}

class PuzzleGenerationFailure extends Failure {
  const PuzzleGenerationFailure([super.message = 'Puzzle generation failed']);
}
