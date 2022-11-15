import 'package:flutter/material.dart';
import 'package:open_chessboard_api/open_chessboard_api.dart';

class Leds extends StatelessWidget {
  final LedsFeature board;

  const Leds({Key key, this.board}) : super(key: key);

  void testLeds() async {
    board.setDeltaLeds([
      PieceDelta("a2", Piece("P"), PieceDeltaType.pieceNeedsRemoval),
      PieceDelta("a4", Piece("P"), PieceDeltaType.pieceMissing),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text("Test LEDS"),
      onPressed: testLeds
    );
  }
}
