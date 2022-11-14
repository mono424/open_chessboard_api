enum BoardLogMessageType {
  error, message
}

class LogEntry {
  final DateTime created;
  final BoardLogMessageType type;
  final List<int> buffer;
  final Exception? error;

  LogEntry(this.created, this.type, this.buffer, { this.error });
}