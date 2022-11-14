import 'package:meta/meta.dart';
import 'package:open_chessboard_api/boardstate_pipeline.dart';
import 'package:open_chessboard_api/models/Piece.dart';
import 'package:open_chessboard_api/models/board_state.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChessboardFeatureBoardstate {

  ChessboardFeatureBoardstate();

  BoardStatePipeline get boardStatePipeline;
  BoardState get boardstate;
  ValueStream<BoardState>get boardstateStream;

  @protected
  void setBoardState(Map<String, Piece?> rawState, [bool applyOrientation = true]);

}