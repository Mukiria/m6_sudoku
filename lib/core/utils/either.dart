abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) left, T Function(R right) right);

  bool get isLeft => fold((_) => true, (_) => false);

  bool get isRight => fold((_) => false, (_) => true);

  L? get left => fold((l) => l, (_) => null);

  R? get right => fold((_) => null, (r) => r);

  Either<L2, R> mapLeft<L2>(L2 Function(L left) fn) {
    return fold((l) => Left(fn(l)), (r) => Right(r));
  }

  Either<L, R2> mapRight<R2>(R2 Function(R right) fn) {
    return fold((l) => Left(l), (r) => Right(fn(r)));
  }

  Either<L2, R2> flatMap<L2, R2>(Either<L2, R2> Function(R right) fn) {
    return fold((l) => Left(l as L2), (r) => fn(r));
  }

  Either<L2, R> flatMapLeft<L2>(Either<L2, R> Function(L left) fn) {
    return fold((l) => fn(l), (r) => Right(r));
  }

  Either<L, R2> flatMapRight<R2>(Either<L, R2> Function(R right) fn) {
    return fold((l) => Left(l), (r) => fn(r));
  }
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L left) left, T Function(R right) right) {
    return left(value);
  }

  @override
  String toString() => 'Left($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Left<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L left) left, T Function(R right) right) {
    return right(value);
  }

  @override
  String toString() => 'Right($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Right<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

extension EitherExtension<L, R> on Either<L, R> {
  Either<L, R2> mapRight<R2>(R2 Function(R right) fn) => mapRight(fn);

  Either<L2, R> mapLeft<L2>(L2 Function(L left) fn) => mapLeft(fn);

  Future<Either<L, R2>> asyncMap<R2>(Future<R2> Function(R right) fn) async {
    return fold((l) => Left(l), (r) async => Right(await fn(r)));
  }
}
