import 'package:open_chessboard_api/models/piece_delta.dart';

abstract class LedsFeature {

  LedsFeature();

  Future<void> unsetAllLeds();
  Future<void> setDeltaLeds(List<PieceDelta> delta);
  Future<void> setCommitedMoveLeds(List<String> squares, [String? checkSquare]);

}