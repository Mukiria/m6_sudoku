import 'cell.dart';

class Board {
  Board({List<List<Cell>>? cells}) : _cells = cells ?? _createEmptyGrid();

  static List<List<Cell>> _createEmptyGrid() {
    return List.generate(
      9,
      (r) => List.generate(9, (c) => Cell(row: r, col: c)),
    );
  }

  final List<List<Cell>> _cells;

  List<List<Cell>> get cells => _cells;

  Cell getCell(int row, int col) => _cells[row][col];

  void setCell(int row, int col, Cell cell) {
    _cells[row][col] = cell;
  }

  int getValue(int row, int col) => _cells[row][col].value;

  void setValue(int row, int col, int value) {
    _cells[row][col] = _cells[row][col].copyWith(value: value);
  }

  List<int> getRow(int row) => _cells[row].map((c) => c.value).toList();

  List<int> getCol(int col) => _cells.map((row) => row[col].value).toList();

  List<int> getBox(int boxRow, int boxCol) {
    final values = <int>[];
    for (var r = boxRow * 3; r < boxRow * 3 + 3; r++) {
      for (var c = boxCol * 3; c < boxCol * 3 + 3; c++) {
        values.add(_cells[r][c].value);
      }
    }
    return values;
  }

  List<int> getBoxAt(int row, int col) {
    return getBox(row ~/ 3, col ~/ 3);
  }

  bool isValidPlacement(int row, int col, int value) {
    if (value < 1 || value > 9) return false;
    if (_cells[row][col].isGiven) return false;

    for (var c = 0; c < 9; c++) {
      if (c != col && _cells[row][c].value == value) return false;
    }

    for (var r = 0; r < 9; r++) {
      if (r != row && _cells[r][col].value == value) return false;
    }

    final boxRow = row ~/ 3;
    final boxCol = col ~/ 3;
    for (var r = boxRow * 3; r < boxRow * 3 + 3; r++) {
      for (var c = boxCol * 3; c < boxCol * 3 + 3; c++) {
        if (r != row && c != col && _cells[r][c].value == value) return false;
      }
    }

    return true;
  }

  List<int> getCandidates(int row, int col) {
    if (_cells[row][col].value != 0) return [];
    final candidates = <int>[];
    for (var v = 1; v <= 9; v++) {
      if (isValidPlacement(row, col, v)) {
        candidates.add(v);
      }
    }
    return candidates;
  }

  void updateCandidates() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (_cells[r][c].value == 0) {
          _cells[r][c] = _cells[r][c].copyWith(candidates: getCandidates(r, c));
        }
      }
    }
  }

  bool get isComplete {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (_cells[r][c].value == 0) return false;
      }
    }
    return true;
  }

  bool get isValid {
    for (var r = 0; r < 9; r++) {
      final rowVals = getRow(r).where((v) => v != 0).toList();
      if (rowVals.length != rowVals.toSet().length) return false;
    }
    for (var c = 0; c < 9; c++) {
      final colVals = getCol(c).where((v) => v != 0).toList();
      if (colVals.length != colVals.toSet().length) return false;
    }
    for (var br = 0; br < 3; br++) {
      for (var bc = 0; bc < 3; bc++) {
        final boxVals = getBox(br, bc).where((v) => v != 0).toList();
        if (boxVals.length != boxVals.toSet().length) return false;
      }
    }
    return true;
  }

  int get filledCount =>
      _cells.expand((row) => row).where((c) => c.value != 0).length;

  int get givenCount =>
      _cells.expand((row) => row).where((c) => c.isGiven).length;

  Board copy() {
    return Board(
      cells:
          _cells.map((row) => row.map((c) => c.copyWith()).toList()).toList(),
    );
  }

  List<List<int>> toGrid() =>
      _cells.map((row) => row.map((c) => c.value).toList()).toList();

  static Board fromGrid(List<List<int>> grid) {
    final board = Board();
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final value = grid[r][c];
        board._cells[r][c] = Cell(
          row: r,
          col: c,
          value: value,
          isGiven: value != 0,
        );
      }
    }
    return board;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var r = 0; r < 9; r++) {
      if (r % 3 == 0 && r != 0) buffer.writeln('------+-------+------');
      for (var c = 0; c < 9; c++) {
        if (c % 3 == 0 && c != 0) buffer.write('| ');
        buffer.write('${_cells[r][c].value == 0 ? '.' : _cells[r][c].value} ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
