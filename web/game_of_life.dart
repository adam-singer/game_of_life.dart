library game_of_life;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'the_world.dart';

@CustomTag('game-of-life')
class GameOfLife extends PolymerElement with Observable {
  @published int cellSide = 5;
  @published int numberOfAcrossCells = 100;
  @published int numberOfDownCells = 100;

  @observable String toggleButtonName = 'Start';
  TheWorld _theWorld;

  GameOfLife.created() : super.created();

  void enteredView() {
    super.enteredView();
    this._theWorld = shadowRoot.querySelector('#world');
  }

  void toggle() {
    this._theWorld.toggle();
    toggleButtonName = this._theWorld.isRunning ? 'Pause' : 'Resume';
  }

  void reset() {
     _theWorld.reset();
     toggleButtonName = 'Start';
  }
}
