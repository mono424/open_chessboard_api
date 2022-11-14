import 'dart:async';

import 'package:open_chessboard_api/models/log_entry.dart';

abstract class ChessboardFeatureLogs {
  final StreamController<LogEntry> _batteryStreanController;

  ChessboardFeatureLogs() : _batteryStreanController = StreamController<LogEntry>.broadcast();

  get battery =>  _batteryStreanController.stream;

}