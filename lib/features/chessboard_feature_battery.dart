import 'dart:async';

import 'package:open_chessboard_api/models/battery_update.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChessboardFeatureBattery {

  ChessboardFeatureBattery();

  BatteryUpdate get orientation;
  ValueStream<BatteryUpdate> get orientationStream;

}