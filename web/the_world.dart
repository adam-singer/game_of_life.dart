//part of game_of_life;
import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';
import 'cells.dart';

@CustomTag('the-world')
class TheWorld extends CanvasElement with Polymer, Observable {
  @published int cellSide = 5;
  @published int numberOfAcrossCells = 100;
  @published int numberOfDownCells = 100;

  Cells _cells;
  CanvasRenderingContext2D _context;
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  static const int MILLISECONDS = 100;

  TheWorld.created() : super.created() {
    _cells = new Cells(cellSide, numberOfAcrossCells, numberOfDownCells);
  }

  void enteredView() {
    super.enteredView();
    width = cellSide * numberOfAcrossCells;
    height = cellSide * numberOfDownCells;
    _context = getContext("2d");
    _context
      ..strokeStyle = '#000000'
      ..lineWidth = 1;
    _renderAll(_cells);
  }

  void toggle() {
    _isRunning ? _pause() : _resume();
  }

  void reset() {
    _pause();
    _cells = new Cells(cellSide, numberOfAcrossCells, numberOfDownCells);
    _renderAll(_cells);
  }

  void _start() {
    new Timer.periodic(const Duration(milliseconds: MILLISECONDS), (Timer timer) {
      if (!_isRunning) timer.cancel();
      _tick();
    });
  }

  void _resume() {
    _isRunning = true;
    _start();
  }

  void _pause() {
    _isRunning = false;
  }

  void _tick() {
    _cells.transit();
    _renderAll(_cells);
  }

  // TODO nasty
  void _renderAll(Cells cells) {
    cells.cells.forEach((list) {
      list.forEach((cell) {
        _context
          ..fillStyle = cell.isLiving ? '#eeeeee' : '#000000' // TODO don't change on each stroke
          ..fillRect(cell.pointX, cell.pointY, cell.side, cell.side)
          ..strokeRect(cell.pointX, cell.pointY, cell.side, cell.side);
      });
    });
  }

}
