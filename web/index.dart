library game_of_life;

//import 'package:polymer/polymer.dart';
import 'package:quiver/iterables.dart';
import 'dart:math';
import 'dart:async';
import 'dart:html';

// TODO add @published to configure them.
const int CELL_SIDE = 5;
const int NUMBER_OF_ACROSS_CELLS = 100;
const int NUMBER_OF_DOWN_CELLS = 100;
const int MILLISECONDS = 100;

// TODO custom-tag?
class World {
  Cells _cells;
  CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  World(this._canvas, { number_of_across_cells: NUMBER_OF_ACROSS_CELLS, number_of_down_cells: NUMBER_OF_DOWN_CELLS }) : this._cells = new Cells() {
    _canvas..width = CELL_SIDE * NUMBER_OF_ACROSS_CELLS..height = CELL_SIDE * NUMBER_OF_DOWN_CELLS;
    _ctx = _canvas.getContext("2d");
    _render();
  }

  void toggle() {
    _isPlaying ? pause() : resume();
  }

  void _start() {
    new Timer.periodic(const Duration(milliseconds: MILLISECONDS), (Timer timer) {
      if (!_isPlaying) timer.cancel();
      _tick();
    });
  }

  void resume() {
    _isPlaying = true;
    _start();
  }

  void pause() {
    _isPlaying = false;
  }

  void _tick() {
    _cells.transit();
    _render();
  }

  void reset() {
    pause();
    _cells = new Cells();
    _render();
  }

  void _render() {
    _cells._cells.forEach((list){
      list.forEach((cell) {
        _ctx
          ..fillStyle = cell.isLiving ? '#eeeeee' : '#000000'
          ..fillRect(cell.pointX, cell.pointY, cell.side, cell.side)
          ..strokeStyle = '#000000'
          ..lineWidth = 1
          ..strokeRect(cell.pointX, cell.pointY, cell.side, cell.side);
      });
    });
  }
}

class Cells {
  List<List<Cell>> _cells;
  Map<Cell, List<Cell>> _neighbors;
  List<List<int>> _neighborRelativeCoordinates = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];

  Cells() : this._cells = _buildCells() {
    _neighbors = _buildNeighbors();
  }

  void transit() {
    _cells.forEach((list){
      list.forEach((cell) {
        cell.setNextState(_neighbors[cell]);
      });
    });
    _cells.forEach((list){
      list.forEach((cell) {
        cell.transit();
      });
    });
  }

  static List<List<Cell>> _buildCells() {
    var random = new Random();
    var cells = new List<List<Cell>>(NUMBER_OF_ACROSS_CELLS);
    range(NUMBER_OF_ACROSS_CELLS).forEach((x) {
      cells[x] = new List<Cell>(NUMBER_OF_DOWN_CELLS);
      range(NUMBER_OF_DOWN_CELLS).forEach((y) {
        cells[x][y] = new Cell(x, y, random.nextBool());
      });
    });
    return cells;
  }

  Map<Cell, List<Cell>> _buildNeighbors() {
    Map<Cell, List<Cell>> neighbors = {};
    for (int x = 0; x < _cells.length; x++) {
      for (int y = 0; y < _cells[x].length; y++) {
        Cell key = _cells[x][y];
        List<Cell> value = new List();
        _neighborRelativeCoordinates.forEach((List l) {
          if (((x + l.first >= 0) && (x + l.first < (NUMBER_OF_ACROSS_CELLS))) && (((y + l.last) >= 0) && ((y + l.last) < (NUMBER_OF_DOWN_CELLS)))) { // isInCellsRange
            value.add(_cells[x + l.first][y + l.last]);
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

  Cell(int x, int y, bool isLiving, {this.side: CELL_SIDE}) :
    pointX = x * CELL_SIDE, pointY = y * CELL_SIDE, _currentState = isLiving ? #live : #dead;

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

void main() {
  var world = new World(querySelector('#world'));
  var playButton = querySelector('#play');
  playButton.onClick.listen((e) {
    world.toggle();
    e.target.text = world._isPlaying ? 'Pause' : 'Resume';
  });
  querySelector('#reset').onClick.listen((e) {
    world.reset();
    playButton.text = 'Start';
  });
}