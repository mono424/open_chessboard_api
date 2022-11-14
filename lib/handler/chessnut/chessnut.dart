import 'dart:async';

import 'package:chessnutdriver/chessnutdriver.dart';
import 'package:open_chessboard_api/chessboard.dart';
import 'package:open_chessboard_api/chessboard_device.dart';
import 'package:open_chessboard_api/features/chessboard_feature_boardstate.dart';
import 'package:open_chessboard_api/features/chessboard_feature_leds.dart';
import 'package:open_chessboard_api/features/chessboard_feature_orientation.dart';
import 'package:open_chessboard_api/mixins/chessboard_mixin_boardstate.dart';
import 'package:open_chessboard_api/mixins/chessboard_mixin_orientation.dart';
import 'package:open_chessboard_api/models/Piece.dart';
import 'package:open_chessboard_api/models/piece_delta.dart';
import 'package:synchronized/synchronized.dart';

class Chessnut extends Chessboard<ChessnutCommunicationClient> 
    with ChessboardMixinBoardstate, ChessboardMixinOrientation
    implements ChessboardFeatureBoardstate, ChessboardFeatureOrientation, ChessboardFeatureLeds
{
  static LEDPattern allLEDsOn = LEDPattern(List.filled(64, true));
  static LEDPattern allLEDsOff = LEDPattern();

  ChessnutBoard? board;
  StreamSubscription? _boardListener;

  @override
  Future<void> connect(ChessboardDevice<ChessnutCommunicationClient> device) async {
    if (board != null) return;

    ChessnutCommunicationClient client = device.communicationClient;
    
    ChessnutBoard nBoard = ChessnutBoard();
    await nBoard.init(client).timeout(const Duration(seconds: 10));

    device.onDisconnect = () => handleDisconnect();

    // TURN ON LEDS
    await nBoard.setLEDs(allLEDsOn);
    await Future.delayed(const Duration(milliseconds: 100));
    await nBoard.setLEDs(allLEDsOff);

    _boardListener = nBoard
      .getBoardUpdateStream()!
      .listen(onUpdateEvent);

    board = nBoard;
    connectedStreamController.add(true);
  }

  Map<String, String>? lastBoardStateUpdate;
  void onUpdateEvent(Map<String, String> board) {
    lastBoardStateUpdate = board;
    Map<String, Piece?> newBoard = mapBoardState(board);
    setBoardState(newBoard);
  }

  Map<String, Piece?> mapBoardState(Map<String, String> boardMap) {
    Map<String, Piece?> result = {};
    for (var square in boardMap.keys) {
      result[square] = boardMap[square] == "" ? null : Piece(boardMap[square]!);
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
  Future<void> unsetAllLeds() async {
    if (board == null) {
      return;
    }
    return lock.synchronized(() async {
      ledPattern = LEDPattern();
      await board!.setLEDs(ledPattern).timeout(const Duration(seconds: 1));
    });
  }

  @override
  Future<void> setDeltaLeds(List<PieceDelta> delta) async {
    if (board == null) {
      return;
    }
    return lock.synchronized(() async {
      ledPattern = LEDPattern();
      for (var item in delta) {
        ledPattern.setSquare(item.square, true);
      }
      await board!.setLEDs(ledPattern).timeout(const Duration(seconds: 1));
    });
  }

  @override
  Future<void> setCommitedMoveLeds(List<String> squares, [String? checkSquare]) async {
    if (board == null) {
      return;
    }
    return lock.synchronized(() async {
      LEDPattern notifyPattern = LEDPattern();
      for (var square in squares) {
        notifyPattern.setSquare(square, true);
      }
      if (checkSquare != null) {
        notifyPattern.setSquare(checkSquare, true);
      }
      await board!.setLEDs(notifyPattern).timeout(const Duration(seconds: 1));
      await board!.setLEDs(ledPattern).timeout(const Duration(seconds: 1));
    });
  }
}
