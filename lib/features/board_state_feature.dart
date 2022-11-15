import 'package:meta/meta.dart';
import 'package:open_chessboard_api/models/boardstate_pipeline.dart';
import 'package:open_chessboard_api/models/piece.dart';
import 'package:open_chessboard_api/models/board_state.dart';
import 'package:rxdart/rxdart.dart';

abstract class BoardStateFeature {

  BoardStateFeature();

  BoardStatePipeline get boardStatePipeline;
  BoardState get boardstate;
  ValueStream<BoardState>get boardstateStream;

  @protected
  void setBoardState(Map<String, Piece?> rawState, [bool applyOrientation = true]);

}