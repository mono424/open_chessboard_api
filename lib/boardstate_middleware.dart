import 'package:open_chessboard_api/models/Piece.dart';

abstract class BoardStateMiddleware {
  
  final String key;
  Map<String, Piece>? execute(Map<String, Piece?> raw);

  BoardStateMiddleware(this.key);
  
}