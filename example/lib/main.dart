import 'dart:async';
import 'dart:typed_data';

import 'package:example/ble_scanner.dart';
import 'package:example/device_list_screen.dart';
import 'package:example/features/board_state_widget.dart';
import 'package:example/features/leds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:open_chessboard_api/open_chessboard_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _scanner = BleScanner(ble: _ble, logMessage: print);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        StreamProvider<BleScannerState>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter example',
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterReactiveBle = FlutterReactiveBle();

  final bleReadCharacteristicA = Uuid.parse("1B7E8262-2877-41C3-B46E-CF057C562023");
  final bleReadCharacteristicB = Uuid.parse("1B7E8273-2877-41C3-B46E-CF057C562023");
  final bleWriteCharacteristic = Uuid.parse("1B7E8272-2877-41C3-B46E-CF057C562023");

  Chessboard connectedBoard;
  StreamSubscription<ConnectionStateUpdate> boardBtStream;
  StreamSubscription<List<int>> boardBtInputStreamA;
  StreamSubscription<List<int>> boardBtInputStreamB;
  bool loading = false;
  bool ackEnabled = true;

  void connectBle() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    String deviceId = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeviceListScreen()));

    setState(() {
      loading = true;
    });

    boardBtStream = flutterReactiveBle.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 5),
    ).listen((e) async {
      if (e.connectionState == DeviceConnectionState.connected) {
        List<DiscoveredService> services = await flutterReactiveBle.discoverServices(e.deviceId);
        await flutterReactiveBle.requestMtu(deviceId: deviceId, mtu: 247); // Important: Increase MTU

        QualifiedCharacteristic readA;
        QualifiedCharacteristic readB;
        QualifiedCharacteristic write;
        for (var service in services) {
          for (var characteristicId in service.characteristicIds) {
            if (characteristicId == bleReadCharacteristicA) {
              readA = QualifiedCharacteristic(
                serviceId: service.serviceId,
                characteristicId: bleReadCharacteristicA,
                deviceId: e.deviceId
              );
            }

            if (characteristicId == bleReadCharacteristicB) {
              readB = QualifiedCharacteristic(
                serviceId: service.serviceId,
                characteristicId: bleReadCharacteristicB,
                deviceId: e.deviceId
              );
            }

            if (characteristicId == bleWriteCharacteristic) {
              write = QualifiedCharacteristic(
                serviceId: service.serviceId,
                characteristicId: bleWriteCharacteristic,
                deviceId: e.deviceId
              );
            }
          }
        }

        ChessnutCommunicationClient chessnutCommuniChessnutCommunicationClient = ChessnutCommunicationClient(
          ChessnutCommunicationType.bluetooth,
          (v) => flutterReactiveBle.writeCharacteristicWithResponse(write, value: v),
          waitForAck: ackEnabled
        );
        boardBtInputStreamA = flutterReactiveBle
            .subscribeToCharacteristic(readA)
            .listen((list) {
              chessnutCommuniChessnutCommunicationClient.handleReceive(Uint8List.fromList(list));
            });
        boardBtInputStreamB = flutterReactiveBle
            .subscribeToCharacteristic(readB)
            .listen((list) {
              chessnutCommuniChessnutCommunicationClient.handleAckReceive(Uint8List.fromList(list));
            });
          

        // connect to board and initialize
        ChessnutChessboard nBoard = new ChessnutChessboard();
        await nBoard.connect(chessnutCommuniChessnutCommunicationClient);
        print("chessnutBoard connected");

        // set connected board
        setState(() {
          connectedBoard = nBoard;
          loading = false;
        });
      } else if (e.connectionState == DeviceConnectionState.disconnected) {
        if (connectedBoard != null) {
          connectedBoard.dispose();
        }
      }
    });
  }

  void disconnectBle() {
    boardBtInputStreamA.cancel();
    boardBtInputStreamB.cancel();
    boardBtStream.cancel();
    setState(() {
      boardBtInputStreamA = null;
      boardBtInputStreamB = null;
      boardBtStream = null;
      connectedBoard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("chessnutdriver example"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(value: ackEnabled, onChanged: connectedBoard == null ? (state) => setState(() => (ackEnabled = state)) : null),
              SizedBox(width: 4),
              Text("Enable Acks"),
            ],
          ),
          Center(child: TextButton(
            child: Text(connectedBoard == null ? "Try to connect to board (BLE)" : (boardBtStream != null ? "Disconnect" : "")),
            onPressed: !loading && connectedBoard == null ? connectBle : (boardBtStream != null && !loading ? disconnectBle : null),
          )),

          // LEDS
          (
            connectedBoard == null || !(connectedBoard is LedsFeature) ? SizedBox() : 
            Center(child: Leds(board: connectedBoard as LedsFeature))
          ),

          // 
          (
            connectedBoard == null || !(connectedBoard is BoardStateFeature) ? SizedBox() : 
            Center(child: BoardStateWidget(board: connectedBoard as BoardStateFeature, width: width))
          ),
        ],
      ),
    );
  }
}
