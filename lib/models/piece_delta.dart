import 'package:open_chessboard_api/models/piece.dart';
import 'package:open_chessboard_api/models/piece_delta_type.dart';

class PieceDelta {
  final String square;
  final Piece piece;
  final PieceDeltaType action;

  PieceDelta(this.square, this.piece, this.action);
}