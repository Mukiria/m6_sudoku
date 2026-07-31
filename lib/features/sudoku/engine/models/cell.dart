class Cell {
  const Cell({
    required this.row,
    required this.col,
    this.value = 0,
    this.candidates = const <int>[],
    this.isGiven = false,
  });

  final int row;
  final int col;
  final int value;
  final List<int> candidates;
  final bool isGiven;

  bool get isEmpty => value == 0;
  bool get isFilled => value != 0;

  Cell copyWith({int? value, List<int>? candidates, bool? isGiven}) {
    return Cell(
      row: row,
      col: col,
      value: value ?? this.value,
      candidates: candidates ?? this.candidates,
      isGiven: isGiven ?? this.isGiven,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell &&
        other.row == row &&
        other.col == col &&
        other.value == value &&
        other.isGiven == isGiven;
  }

  @override
  int get hashCode => Object.hash(row, col, value, isGiven);

  @override
  String toString() => 'Cell($row, $col, value: $value, given: $isGiven)';
}
