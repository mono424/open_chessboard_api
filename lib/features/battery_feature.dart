import 'dart:async';

import 'package:open_chessboard_api/models/battery_update.dart';
import 'package:rxdart/rxdart.dart';

abstract class BatteryFeature {

  BatteryFeature();

  BatteryUpdate get orientation;
  ValueStream<BatteryUpdate> get orientationStream;

}