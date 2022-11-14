class ChessboardDevice<T> {
  final T communicationClient;
  
  Function()? onDisconnect;

  ChessboardDevice(this.communicationClient);

  void triggerOnDisconnect() {
    if (onDisconnect != null) {
      onDisconnect!();
    }
  }
}