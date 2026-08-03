class Cell {
  const Cell({
    required this.row,
    required this.col,
    this.value = 0,
    this.candidates = 0,
    this.isGiven = false,
  });

  final int row;
  final int col;
  final int value;
  final int candidates;
  final bool isGiven;

  bool get isEmpty => value == 0;
  bool get isFilled => value != 0;

  Cell copyWith({int? value, int? candidates, bool? isGiven}) {
    return Cell(
      row: row,
      col: col,
      value: value ?? this.value,
      candidates: candidates ?? this.candidates,
      isGiven: isGiven ?? this.isGiven,
    );
  }

  List<int> getCandidatesList() {
    final list = <int>[];
    var mask = candidates;
    while (mask != 0) {
      final bit = mask & -mask;
      list.add(_bitToDigit(bit));
      mask &= mask - 1;
    }
    return list;
  }

  static int _bitToDigit(int bit) {
    switch (bit) {
      case 0x001:
        return 1;
      case 0x002:
        return 2;
      case 0x004:
        return 3;
      case 0x008:
        return 4;
      case 0x010:
        return 5;
      case 0x020:
        return 6;
      case 0x040:
        return 7;
      case 0x080:
        return 8;
      case 0x100:
        return 9;
      default:
        return 0;
    }
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

const int allCandidates = 0x1FF; // bits 0-8 set (1-9)
