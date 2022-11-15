import 'package:open_chessboard_api/models/piece.dart';
import 'package:open_chessboard_api/models/field_update_action.dart';

class FieldUpdate {
  final String square;
  final Piece piece;
  final FieldUpdateAction action;

  FieldUpdate(this.square, this.piece, this.action);

  String getNotation({bool takes = false, String from = ""}) {
    if (action == FieldUpdateAction.pickUp) return "";
    return piece.notation + from + (takes ? "x" : "") + square;
  }

  @override
  String toString() {
    return "$square: ${piece.notation} (${action == FieldUpdateAction.pickUp ? 'Pickup' : 'Set'})";
  }

  static bool equals(FieldUpdate a, FieldUpdate b) {
    return Piece.equal(a.piece, b.piece) && a.square == b.square && a.action == b.action;
  }
}