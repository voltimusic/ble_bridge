//
// Generated file. Do not edit.
// This file is generated from template in file `flutter_tools/lib/src/flutter_plugins.dart`.
//

// @dart = 3.5

import 'dart:io'; // flutter_ignore: dart_io_import.
import 'package:flutter_midi_command_linux/flutter_midi_command_linux.dart';
import 'package:flutter_midi_command_windows/flutter_midi_command_windows.dart';

@pragma('vm:entry-point')
class _PluginRegistrant {

  @pragma('vm:entry-point')
  static void register() {
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
    } else if (Platform.isLinux) {
      try {
        FlutterMidiCommandLinux.registerWith();
      } catch (err) {
        print(
          '`flutter_midi_command_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isMacOS) {
    } else if (Platform.isWindows) {
      try {
        FlutterMidiCommandWindows.registerWith();
      } catch (err) {
        print(
          '`flutter_midi_command_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    }
  }
}
