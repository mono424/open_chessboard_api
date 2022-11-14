import 'dart:async';
import 'package:meta/meta.dart';
import 'package:open_chessboard_api/models/chessboard_device.dart';
import 'package:open_chessboard_api/models/field_update.dart';

abstract class Chessboard<T> {

  @protected
  final StreamController<FieldUpdate> streamController;

  @protected
  final StreamController<bool> connectedStreamController;

  Chessboard() : streamController = StreamController<FieldUpdate>(), connectedStreamController = StreamController<bool>();

  Stream<bool> get connected => connectedStreamController.stream;
  Stream<FieldUpdate> get updates => streamController.stream;

  Future<void> connect(ChessboardDevice<T> device);
  
}
