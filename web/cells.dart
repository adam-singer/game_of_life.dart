//part of game_of_life;
// TODO use math library : Point<T extends num> class http://api.dartlang.org/docs/releases/latest/dart_math/Point.html
import 'package:quiver/iterables.dart';
import 'dart:math';

class Cells {
  List<List<Cell>> cells;
  Map<Cell, List<Cell>> _neighbors;
  final List<List<int>> _neighborRelativeCoordinates = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];

  Cells(int cellSide, int numberOfAcrossCells, int numberOfDownCells) : this.cells = _buildCells(cellSide, numberOfAcrossCells, numberOfDownCells) {
    _neighbors = _buildNeighbors(numberOfAcrossCells, numberOfDownCells);
  }

  void transit() {
    cells.forEach((list) {
      list.forEach((cell) {
        cell.setNextState(_neighbors[cell]);
      });
    });
    cells.forEach((list) {
      list.forEach((cell) {
        cell.transit();
      });
    });
  }

  static List<List<Cell>> _buildCells(cellSide, numberOfAcrossCells, numberOfDownCells) {
    var random = new Random();
    var cells = new List<List<Cell>>(numberOfAcrossCells);
    range(numberOfAcrossCells).forEach((x) {
      cells[x] = new List<Cell>(numberOfDownCells);
      range(numberOfDownCells).forEach((y) {
        cells[x][y] = new Cell(x, y, cellSide, random.nextBool());
      });
    });
    return cells;
  }

  Map<Cell, List<Cell>> _buildNeighbors(numberOfAcrossCells, numberOfDownCells) {
    Map<Cell, List<Cell>> neighbors = {};
    for (int x = 0; x < cells.length; x++) {
      for (int y = 0; y < cells[x].length; y++) {
        Cell key = cells[x][y];
        List<Cell> value = new List();
        _neighborRelativeCoordinates.forEach((List l) {
          if (((x + l.first >= 0) && (x + l.first < (numberOfAcrossCells))) && (((y + l.last) >= 0) && ((y + l.last) < (numberOfDownCells)))) { // isInCellsRange
            value.add(cells[x + l.first][y + l.last]);
          }
        });
        neighbors[key] = value;
      }
    }
    return neighbors;
  }
}

class Cell {
  final int side;
  final int pointX;
  final int pointY;
  // states = [#live, #dying, #dead, #aboring];
  Symbol _currentState;
  bool get isLiving => _currentState == #live || _currentState == #dying;

  Cell(int x, int y, int side, bool isLiving) :
    this.side = side,
    pointX = x * side, pointY = y * side, _currentState = isLiving ? #live : #dead;

  void setNextState(List<Cell> cells) {
    int i = cells.where((cell) => cell.isLiving).toList().length;
    if (isLiving) {
      if (_toDying(i)) _currentState = #dying;
    } else {
      if (_toAboring(i)) _currentState = #aboring;
    }
  }

  void transit() {
    if (_currentState == #dying) {
      _currentState = #dead;
    } else if (_currentState == #aboring) {
      _currentState = #live;
    } else {
      // do nothing
    }
  }

  bool _isUnderPopulation(n) => n <= 1;
  bool _isOverCrowding(n) => n >= 4;
  bool _toDying(n) => _isUnderPopulation(n) || _isOverCrowding(n);
  bool _toAboring(n) => n == 3;
}