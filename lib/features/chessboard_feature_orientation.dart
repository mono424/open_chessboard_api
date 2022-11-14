import 'package:open_chessboard_api/models/chessboard_orientation.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChessboardFeatureOrientation {

  ChessboardFeatureOrientation();

  ChessboardOrientation get orientation;
  ValueStream<ChessboardOrientation> get orientationStream;

  void setOrientation(ChessboardOrientation orientation);

}