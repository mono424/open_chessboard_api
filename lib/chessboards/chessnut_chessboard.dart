import 'dart:async';
import 'package:chessnutdriver/chessnutdriver.dart';
import 'package:open_chessboard_api/models/chessboard.dart';
import 'package:open_chessboard_api/features/board_state_feature.dart';
import 'package:open_chessboard_api/features/leds_feature.dart';
import 'package:open_chessboard_api/features/orientation_feature.dart';
import 'package:open_chessboard_api/mixins/board_state_mixin.dart';
import 'package:open_chessboard_api/mixins/orientation_mixin.dart';
import 'package:open_chessboard_api/models/piece.dart';
import 'package:open_chessboard_api/models/piece_delta.dart';
import 'package:synchronized/synchronized.dart';

class ChessnutChessboard extends Chessboard<ChessnutCommunicationClient> 
    with BoardStateMixin, OrientationMixin
    implements BoardStateFeature, OrientationFeature, LedsFeature
{
  static LEDPattern allLEDsOn = LEDPattern(List.filled(64, true));
  static LEDPattern allLEDsOff = LEDPattern();

  ChessnutBoard? board;
  StreamSubscription? _boardListener;

  @override
  Future<void> connect(ChessnutCommunicationClient client) async {
    if (board != null) return;
    
    ChessnutBoard nBoard = ChessnutBoard();
    await nBoard.init(client).timeout(const Duration(seconds: 10));

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

  @override
  void dispose() {
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
