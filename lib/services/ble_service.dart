import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class BleService {
  final MidiCommand _midiCommand = MidiCommand();
  bool _didAskForBluetoothPermissions = false;

  final Function(List<MidiDevice>) onBluetoothDevicesUpdated;
  final Function(String) onLog;

  BleService({
    required this.onBluetoothDevicesUpdated,
    required this.onLog,
  });

  Future<void> _informUserAboutBluetoothPermissions(BuildContext context) async {
    if (_didAskForBluetoothPermissions) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Grant Bluetooth Permissions to discover BLE MIDI Devices.'),
          content: const Text('In the next dialog we might ask you for Bluetooth permissions.\nPlease grant permissions to make Bluetooth MIDI possible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok. I got it!'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions = true;
  }

  Future<void> refreshBluetoothConnection(BuildContext context) async {
    await _informUserAboutBluetoothPermissions(context);
    if (kDebugMode) print("Start BLE central");

    await _midiCommand.startBluetoothCentral().catchError((err) {
      onLog("Bluetooth Error: $err");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    });

    if (kDebugMode) print("Wait for init");
    await _midiCommand.waitUntilBluetoothIsInitialized().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (kDebugMode) print("Failed to initialize Bluetooth");
      },
    );

    if (_midiCommand.bluetoothState == BluetoothState.poweredOn) {
      _midiCommand.startScanningForBluetoothDevices().catchError((err) {
        onLog("Scanning Error: $err");
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanning for Bluetooth devices ...')));
    } else {
      final messages = {
        BluetoothState.unsupported: 'Bluetooth is not supported on this device.',
        BluetoothState.poweredOff: 'Please switch on Bluetooth and try again.',
        BluetoothState.poweredOn: 'Everything is fine.',
        BluetoothState.resetting: 'Currently resetting. Try again later.',
        BluetoothState.unauthorized: 'This app needs Bluetooth permissions. Please assign Bluetooth access rights.',
        BluetoothState.unknown: 'Bluetooth is not ready yet. Try again later.',
        BluetoothState.other: 'Unexpected Bluetooth state.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(messages[_midiCommand.bluetoothState] ?? 'Unknown Bluetooth state: ${_midiCommand.bluetoothState}'),
      ));
    }
  }
}
