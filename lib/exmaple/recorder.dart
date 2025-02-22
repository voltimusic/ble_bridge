
import 'dart:async';
import 'dart:io';

import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiRecorder {

  factory MidiRecorder() {
    _instance ??= MidiRecorder._();
    return _instance!;
  }

  static MidiRecorder? _instance;

  MidiRecorder._();

  bool _recording = false;

  bool get recording => _recording;

  final List<MidiPacket> _messages = [];

  StreamSubscription<MidiPacket>? _midiSub;

  startRecording() {
    _recording = true;
    _midiSub = MidiCommand().onMidiDataReceived?.listen((packet) {
      _messages.add(packet);
    });
  }

  stopRecording() {
    _recording = false;
    _midiSub?.cancel();
  }


  exportRecording() async {

    print("recording exported");
  }

  clearRecording() {
    _messages.clear();
  }
}
