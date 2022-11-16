import 'package:open_chessboard_api/models/piece_color.dart';
import 'package:open_chessboard_api/models/piece_type.dart';

class Piece {
  final String _notation;

  Piece(this._notation);

  String get notation {
    return _notation;
  }

  PieceColor get color {
    if (_notation == "?") {
      return PieceColor.unknown;
    }
    return _notation.toUpperCase() == _notation ? PieceColor.white : PieceColor.black;
  }

  PieceType get type {
    switch (_notation.toLowerCase()) {
      case "p":
        return PieceType.pawn;
      case "n":
        return PieceType.knight;
      case "b":
        return PieceType.bishop;
      case "r":
        return PieceType.rook;
      case "q":
        return PieceType.queen;
      case "k":
        return PieceType.king;
      case "?":
        return PieceType.unknown;
      default:
        throw Exception("Unknown piece type: $_notation");
    }
  }

  @override
  String toString() {
    return _notation;
  }

  Piece clone() {
    return Piece(_notation);
  }

  static bool equal(Piece? a, Piece? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    return a.type == b.type && a.color == b.color;
  }
}
