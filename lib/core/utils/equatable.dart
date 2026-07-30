class Equatable {
  const Equatable();

  List<Object?> get props => const [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equatable && _propsEqual(other);
  }

  bool _propsEqual(Equatable other) {
    final props1 = props;
    final props2 = other.props;
    if (props1.length != props2.length) return false;
    for (var i = 0; i < props1.length; i++) {
      if (props1[i] != props2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() {
    final propsString = props.map((p) => p.toString()).join(', ');
    return '$runtimeType($propsString)';
  }
}
