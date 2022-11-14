import 'package:open_chessboard_api/models/Piece.dart';

class BoardState {
  final Map<String, Piece?> board;

  BoardState(this.board);
}