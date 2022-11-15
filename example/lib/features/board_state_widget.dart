import 'package:flutter/material.dart';
import 'package:open_chessboard_api/open_chessboard_api.dart';

class BoardStateWidget extends StatelessWidget {
  final BoardStateFeature board;
  final double width;

  const BoardStateWidget({Key key, this.board, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: board.boardstateStream,
      builder: (context, AsyncSnapshot<BoardState> snapshot) {
        if (!snapshot.hasData) return Text("- no data -");

        Map<String, Piece> fieldUpdate = snapshot.data.board;
        List<Widget> rows = [];
        
        for (var i = 0; i < 8; i++) {
          List<Widget> cells = [];
          for (var j = 0; j < 8; j++) {
              MapEntry<String, Piece> entry = fieldUpdate.entries.toList()[i * 8 + j];
              cells.add(
                Container(
                  padding: EdgeInsets.only(bottom: 2),
                  width: width / 8 - 4,
                  height: width / 8 - 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color:  Colors.black54,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(entry.key, style: TextStyle(color: Colors.white)),
                        Text(entry.value.toString() ?? ".", style: TextStyle(color: Colors.white, fontSize: 8)),
                      ],
                    )
                  ),
                ),
              );
          }
          rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: cells,
          ));
        }

        return Column(
          children: rows,
        );
      }
    );
  }
}
