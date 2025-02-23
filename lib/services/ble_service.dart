import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class BleService {
  final MidiCommand _midiCommand = MidiCommand();
  bool _didAskForBluetoothPermissions = false;

  final Function(List<MidiDevice>) onBluetoothDevicesUpdated;
  final Function(MidiPacket) onLog;

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match the dialog's rounded corners
          ),
          titlePadding: EdgeInsets.zero, // Remove default title padding
          title: Container(
            padding: EdgeInsets.all(16), // Add internal padding for the text
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF105FB9), // Dark Blue
                  Color(0xFF16D9F3), // Cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12), // Match the dialog's rounded corners
              ),
            ),
            child: Text(
              'Please Grant Bluetooth Permissions',
              style: TextStyle(
                color: Colors.white, // White text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Text(
            'In the next dialog we might ask you for Bluetooth permissions.\nPlease grant permissions to make Bluetooth MIDI possible.',
          ),
          actions: [
            // Ok Button (Blue)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                foregroundColor: Colors.white, // White text
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok. I got it!'),
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
