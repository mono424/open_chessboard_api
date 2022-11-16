import 'package:meta/meta.dart';
import 'package:open_chessboard_api/models/field_update.dart';
import 'package:open_chessboard_api/models/field_update_action.dart';
import 'package:open_chessboard_api/models/piece.dart';

abstract class BoardMoveDeltaMixin {

  @protected
  List<FieldUpdate> mapFieldUpdate(Map<String, Piece?>? oldBoard, Map<String, Piece?> newBoard) {
    List<FieldUpdate> result = _boardDelta(oldBoard, newBoard);
    result.sort((a, b) {
      int sort = a.action.index - b.action.index;
      if (sort == 0) {
        try {
          // Sort King to top if other pieces are moved too, to support castling
          bool aIsKing = a.piece.notation.toLowerCase() == "k";
          bool bIsKing = b.piece.notation.toLowerCase() == "k";
          if (aIsKing && !bIsKing) {
            return -1;
          } else if (!aIsKing && bIsKing) {
            return 1;
          } else {
            return 0;
          }
        } catch (e) {
          return 0;
        }
      }
      return sort;
    });
    return result;
  }

  List<FieldUpdate> _boardDelta(Map<String, Piece?>? oldBoard, Map<String, Piece?> newBoard) {
    List<FieldUpdate> delta = [];
    for (var square in newBoard.keys) {
      if (oldBoard == null || !Piece.equal(oldBoard[square], newBoard[square])) {
        if (oldBoard == null || oldBoard[square] == null) {
          delta.add(FieldUpdate(square, newBoard[square]!, FieldUpdateAction.setDown));
        } else if (newBoard[square] == null) {
          delta.add(FieldUpdate(square, oldBoard[square]!, FieldUpdateAction.pickUp));
        } else {
          delta.add(FieldUpdate(square, oldBoard[square]!, FieldUpdateAction.pickUp));
          delta.add(FieldUpdate(square, newBoard[square]!, FieldUpdateAction.setDown));
        }
      }
    }
    return delta;
  }
}