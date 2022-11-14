import 'dart:async';

import 'package:chessnutdriver/chessnutdriver.dart';
import 'package:open_chessboard_api/chessboard.dart';
import 'package:open_chessboard_api/features/chessboard_feature_boardstate.dart';
import 'package:open_chessboard_api/models/Piece.dart';

class Chessnut extends Chessboard implements ChessboardFeatureBoardstate {
  static LEDPattern allLEDsOn = LEDPattern(List.filled(64, true));
  static LEDPattern allLEDsOff = LEDPattern();

  ChessnutBoard? board;
  StreamSubscription? _boardListener;

  @override
  Future<void> connect(BoardDevice device, Function onDisconnect) async {
    if (board != null) return;

    ChessnutCommunicationClient client = await device.getChessnutCommunicationClient();
    
    ChessnutBoard nBoard = ChessnutBoard();
    await nBoard.init(client).timeout(const Duration(seconds: 10));

    device.onDisconnect = () => handleDisconnect();

    // TURN ON LEDS
    await nBoard.setLEDs(allLEDsOn);
    await Future.delayed(const Duration(milliseconds: 100));
    await nBoard.setLEDs(allLEDsOff);

    _boardListener = nBoard
      .getBoardUpdateStream()
      .handleError(onError)
      .listen(onUpdateEvent);

    board = nBoard;
    connectedStreamController.add(true);
  }

  Map<String, String> lastBoardStateUpdate;
  void onUpdateEvent(Map<String, String> board) {
    lastBoardStateUpdate = board;
    Map<String, WPPiece> newBoard = mapBoardState(board);
    setBoardState(newBoard);
  }

  Map<String, Piece> mapBoardState(Map<String, String> boardMap) {
    Map<String, Piece?> result = {};
    for (var square in boardMap.keys) {
      result[square] = boardMap[square] == "" ? null : Piece(boardMap[square]);
    }
    return result;
  }

  Future<void> disconnect() async {
    handleDisconnect();
  }

  void handleDisconnect() {
    if (_boardListener != null) {
      _boardListener!.cancel();
    }
    _boardListener = null;
    board = null;
    connectedStreamController.add(false);
  }

  Lock lock = Lock();
  LEDPattern ledPattern = LEDPattern();

  @override
  Future<void> resetBoardDeltaLeds() {
    return lock.synchronized(() async {
      ledPattern = LEDPattern();
      await board.value.setLEDs(ledPattern).timeout(Duration(seconds: 1));
    });
  }

  @override
  Future<void> setBoardDeltaLeds(List<PieceSyncDeltaEntry> delta) {
    return lock.synchronized(() async {
      ledPattern = LEDPattern();
      for (var item in delta) {
        ledPattern.setSquare(item.square, true);
      }
      await board.value.setLEDs(ledPattern).timeout(Duration(seconds: 1));
    });
  }

  @override
  Future<void> setCommitedMoveLeds(List<String> squares, [String checkSquare]) async {
    return lock.synchronized(() async {
      LEDPattern notifyPattern = LEDPattern();
      for (var square in squares) {
        notifyPattern.setSquare(square, true);
      }
      if (checkSquare != null) {
        notifyPattern.setSquare(checkSquare, true);
      }
      await board.value.setLEDs(notifyPattern).timeout(Duration(seconds: 1));
      await board.value.setLEDs(ledPattern).timeout(Duration(seconds: 1));
    });
  }
}
