import 'package:sit/game/minesweeper/save.dart';

import '../model/mode.dart';
import '../model/screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter/foundation.dart";
import 'package:logger/logger.dart';
import '../model/board.dart';
import '../model/cell.dart';

// Debug Tool
final logger = Logger();

class GameLogic extends StateNotifier<GameStates> {
  GameLogic(this.ref) : super(GameStates());
  final StateNotifierProviderRef ref;

  // Generating Mines When First Click
  bool firstClick = true;
  int mineNum = -1;

  void initGame({required GameMode gameMode}) {
    state.mode = gameMode;
    state.gameOver = false;
    state.goodGame = false;
    state.board = Board(rows: state.mode.gameRows, columns: state.mode.gameColumns);
    mineNum = state.mode.gameMines;
    firstClick = true;
    if (kDebugMode) {
      logger.log(Level.info, "Game Init Finished");
    }
  }

  // TODO: finish this
  void fromSave(Board save) {
    state.mode = GameMode.easy;
    state.gameOver = false;
    state.goodGame = false;
    state.board = save;
    mineNum = save.mines;
    firstClick = true;
    if (kDebugMode) {
      logger.log(Level.info, "Game from save");
    }
  }

  bool get gameOver => state.gameOver;

  void initScreen({required width, required, height, required mode}) {
    state.screen = Screen(screenWidth: width, screenHeight: height, gameMode: mode);
  }

  Cell getCell({required row, required col}) {
    return state.board.getCell(row: row, col: col);
  }

  void _changeCell({required Cell cell, required CellState state}) {
    this.state.board.changeCell(row: cell.row, col: cell.col, state: state);
  }

  void dig({required Cell cell}) {
    if (firstClick) {
      state.board.randomMines(number: mineNum, clickRow: cell.row, clickCol: cell.col);
      firstClick = false;
    }
    if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.blank);
      // Check Game State
      if (cell.mine) {
        state.gameOver = true;
      } else {
        _digAroundIfSafe(cell: cell);
        if (checkWin()) {
          state.goodGame = true;
        }
      }
    } else {
      assert(false, "$cell");
    }
  }

  void _digAroundIfSafe({required Cell cell}) {
    if (cell.minesAround == 0) {
      for (final neighbor in state.board.iterateAround(cell: cell)) {
        if (neighbor.state == CellState.covered && neighbor.minesAround == 0) {
          _changeCell(cell: neighbor, state: CellState.blank);
          _digAroundIfSafe(cell: neighbor);
        } else if (!neighbor.mine && neighbor.state == CellState.covered && neighbor.minesAround != 0) {
          _changeCell(cell: neighbor, state: CellState.blank);
        }
      }
    }
  }

  bool digAroundBesidesFlagged({required Cell cell}) {
    bool digAny = false;
    if (state.board.countAroundByState(cell: cell, state: CellState.flag) >= cell.minesAround) {
      for (final neighbor in state.board.iterateAround(cell: cell)) {
        if (neighbor.state == CellState.covered) {
          dig(cell: neighbor);
          digAny = true;
        }
      }
    }
    return digAny;
  }

  bool flagRestCovered({required Cell cell}) {
    bool flagAny = false;
    final coveredCount = state.board.countAroundByState(cell: cell, state: CellState.covered);
    if (coveredCount == 0) return false;
    final flagCount = state.board.countAroundByState(cell: cell, state: CellState.flag);
    if (coveredCount + flagCount == cell.minesAround) {
      for (final neighbor in state.board.iterateAround(cell: cell)) {
        if (neighbor.state == CellState.covered) {
          flag(cell: neighbor);
          flagAny = true;
        }
      }
    }
    return flagAny;
  }

  bool checkWin() {
    var coveredCells = state.board.countAllByState(state: CellState.covered);
    var flagCells = state.board.countAllByState(state: CellState.flag);
    var mineCells = state.board.mines;
    if (kDebugMode) {
      logger.log(
        Level.debug,
        "mines: $mineCells, covers: $coveredCells, flags: $flagCells",
      );
    }
    if (coveredCells + flagCells == mineCells) {
      return true;
    }
    return false;
  }

  void toggleFlag({required Cell cell}) {
    if (cell.state == CellState.flag) {
      _changeCell(cell: cell, state: CellState.covered);
    } else if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.flag);
    } else {
      assert(false, "$cell");
    }
  }

  void flag({required Cell cell}) {
    if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.flag);
    } else {
      assert(false, "$cell");
    }
  }

  void removeFlag({required Cell cell}) {
    if (cell.state == CellState.flag) {
      _changeCell(cell: cell, state: CellState.covered);
    } else {
      assert(false, "$cell");
    }
  }

  Future<void> save() async {
    if (state.goodGame || state.gameOver) {
      await SaveMinesweeper.storage.delete();
    } else {
      await SaveMinesweeper.storage.save(state.board.toSave());
    }
  }
}

class GameStates {
  late bool gameOver;
  late bool goodGame;
  late GameMode mode;
  late Screen screen;
  late Board board;
}

final boardManager = StateNotifierProvider<GameLogic, GameStates>((ref) {
  if (kDebugMode) {
    logger.log(Level.info, "GameLogic Init Finished");
  }
  return GameLogic(ref);
});
