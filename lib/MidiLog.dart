// Define a model for log messages.
import 'package:flutter/cupertino.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiLog {
  final MidiPacket message;
  final DateTime timestamp;

  MidiLog(this.message, this.timestamp);
}

// A provider for logging MIDI messages.
class MidiLogProvider extends ChangeNotifier {
  late List<MidiLog> _logs = [];
  bool _isLoggingEnabled = true;

  List<MidiLog> get logs => List.unmodifiable(_logs);
  bool get isLoggingEnabled => _isLoggingEnabled;
  void addLog(MidiPacket message) {
    _logs.insert(0, MidiLog(message, DateTime.now()));
    notifyListeners();
  }
  void toggleLogging() {
    _isLoggingEnabled = !_isLoggingEnabled;
    notifyListeners();
  }
  void clearLogs() {
    _logs = []; // Reassign to a new empty list
    notifyListeners();
  }
}
