abstract class AppException implements Exception {
  const AppException([this.message = 'An error occurred', this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error',
    super.code = 'SERVER_ERROR',
  ]);
}

class CacheException extends AppException {
  const CacheException([
    super.message = 'Cache error',
    super.code = 'CACHE_ERROR',
  ]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network error',
    super.code = 'NETWORK_ERROR',
  ]);
}

class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Validation error',
    super.code = 'VALIDATION_ERROR',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Not found',
    super.code = 'NOT_FOUND',
  ]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Unauthorized',
    super.code = 'UNAUTHORIZED',
  ]);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'Forbidden',
    super.code = 'FORBIDDEN',
  ]);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Timeout', super.code = 'TIMEOUT']);
}

class ParseException extends AppException {
  const ParseException([
    super.message = 'Parse error',
    super.code = 'PARSE_ERROR',
  ]);
}

class StorageException extends AppException {
  const StorageException([
    super.message = 'Storage error',
    super.code = 'STORAGE_ERROR',
  ]);
}

class PermissionException extends AppException {
  const PermissionException([
    super.message = 'Permission denied',
    super.code = 'PERMISSION_DENIED',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Unknown error',
    super.code = 'UNKNOWN_ERROR',
  ]);
}

class GameException extends AppException {
  const GameException([
    super.message = 'Game error',
    super.code = 'GAME_ERROR',
  ]);
}

class PuzzleException extends AppException {
  const PuzzleException([
    super.message = 'Puzzle error',
    super.code = 'PUZZLE_ERROR',
  ]);
}

class SettingsException extends AppException {
  const SettingsException([
    super.message = 'Settings error',
    super.code = 'SETTINGS_ERROR',
  ]);
}

class StatisticsException extends AppException {
  const StatisticsException([
    super.message = 'Statistics error',
    super.code = 'STATISTICS_ERROR',
  ]);
}
