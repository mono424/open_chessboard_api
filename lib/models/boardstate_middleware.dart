import 'package:open_chessboard_api/models/piece.dart';

abstract class BoardStateMiddleware {
  
  final String key;
  Map<String, Piece>? execute(Map<String, Piece?> raw);

  BoardStateMiddleware(this.key);
  
}