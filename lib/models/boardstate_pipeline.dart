import 'package:open_chessboard_api/models/boardstate_middleware.dart';
import 'package:open_chessboard_api/models/Piece.dart';

class BoardStatePipeline {
  
  List<BoardStateMiddleware> middlewares;

  BoardStatePipeline({this.middlewares = const []});
  
  void addMiddleware(BoardStateMiddleware middleware) {
    middlewares.add(middleware);
  }

  void addFirstMiddleware(BoardStateMiddleware middleware) {
    middlewares.insert(0, middleware);
  }

  void removeMiddleware(String middlewareKey) {
    middlewares = middlewares.where((m) => m.key != middlewareKey).toList();
  }

  Map<String, Piece?>? execute(Map<String, Piece?>? raw) {
    for (var middleware in middlewares) {
      if (raw == null) {
        return null;
      }
      raw = middleware.execute(raw);
    }
    return raw;
  }

}