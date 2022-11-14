import 'package:meta/meta.dart';
import 'package:open_chessboard_api/features/orientation_feature.dart';
import 'package:open_chessboard_api/models/boardstate_pipeline.dart';
import 'package:open_chessboard_api/chess_utils.dart';
import 'package:open_chessboard_api/models/Piece.dart';
import 'package:open_chessboard_api/models/board_state.dart';
import 'package:open_chessboard_api/models/chessboard_orientation.dart';
import 'package:rxdart/rxdart.dart';

abstract class BoardstateMixin {
  final BoardStatePipeline boardStatePipeline = BoardStatePipeline();

  @protected
  final BehaviorSubject<BoardState> boardstateSubject
    = BehaviorSubject<BoardState>.seeded(BoardState({}));

  BoardState get boardstate =>  boardstateSubject.value;
  ValueStream<BoardState> get boardstateStream =>  boardstateSubject.stream;

  // BoardState without orientation
  Map<String, Piece?> rawBoardState = {};

  @protected
  void setBoardState(Map<String, Piece?> rawState, [bool applyOrientation = true]) {
    final newRawState = boardStatePipeline.execute(rawState);

    if (newRawState == null) {
      return;
    }

    rawBoardState = newRawState;

    if (this is OrientationFeature) {
      boardstateSubject.add(BoardState(_applyOrientationToBoardState(newRawState, (this as OrientationFeature).orientation)));
    } else {
      boardstateSubject.add(BoardState(newRawState));
    }
  }

  Map<String, Piece?> _applyOrientationToBoardState(Map<String, Piece?> boardState, ChessboardOrientation orientation) {
    Map<String, Piece?> mapped = {};
    for (var square in boardState.keys) {
      mapped[orientation == ChessboardOrientation.blackAtBottom ? ChessUtils.getInverseSquare(square) : square] = boardState[square];
    }
    return mapped;
  }

}