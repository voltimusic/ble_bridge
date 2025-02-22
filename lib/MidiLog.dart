// Define a model for log messages.
import 'package:flutter/cupertino.dart';

class MidiLog {
  final String message;
  final DateTime timestamp;

  MidiLog(this.message, this.timestamp);
}

// A provider for logging MIDI messages.
class MidiLogProvider extends ChangeNotifier {
  late List<MidiLog> _logs = [];
  List<MidiLog> get logs => List.unmodifiable(_logs);

  void addLog(String message) {
    _logs.insert(0, MidiLog(message, DateTime.now()));
    notifyListeners();
  }

  void clearLogs() {
    _logs = []; // Reassign to a new empty list
    notifyListeners();
  }
}
