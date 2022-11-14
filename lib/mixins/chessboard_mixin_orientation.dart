import 'package:meta/meta.dart';
import 'package:open_chessboard_api/models/chessboard_orientation.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChessboardMixinOrientation {
  
  @protected
  final BehaviorSubject<ChessboardOrientation> orientationSubject 
    = BehaviorSubject<ChessboardOrientation>.seeded(ChessboardOrientation.whiteAtBottom);

  ChessboardOrientation get orientation =>  orientationSubject.value;
  ValueStream<ChessboardOrientation> get orientationStream =>  orientationSubject.stream;

  void setOrientation(ChessboardOrientation orientation) {
    orientationSubject.add(orientation);
  }

}