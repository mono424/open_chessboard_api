import 'dart:async';

import 'package:open_chessboard_api/models/battery_update.dart';

abstract class ChessboardFeatureBattery {
  
  final StreamController<BatteryUpdate> _batteryStreanController;

  ChessboardFeatureBattery() : _batteryStreanController = StreamController<BatteryUpdate>.broadcast();

  get battery =>  _batteryStreanController.stream;

}