import 'package:flutter/material.dart';

class MidiLogProvider extends ChangeNotifier {
  final List<String> _logs = [];
  List<String> get logs => List.unmodifiable(_logs);

  void addLog(String message) {
    _logs.insert(0, message);
    notifyListeners();
  }
}
