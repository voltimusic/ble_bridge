import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';


class DeviceDialogs {
  static void showDisconnectDialog(
      BuildContext context,
      MidiDevice device,
      Function(MidiDevice) onDisconnect,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Disconnect Device"),
          content: Text("The device '${device.name}' is already connected. Do you want to disconnect it?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDisconnect(device);
              },
              child: Text("Disconnect"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void showConnectionOptionsDialog(
      BuildContext context,
      MidiDevice device,
      Function(MidiDevice) onCreateNew,
      Function(MidiDevice) onConnectExisting,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose an option"),
          content: Text("Do you want to create a new virtual MIDI device or connect to an existing one?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onCreateNew(device);
              },
              child: Text("Create New"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConnectExisting(device);
              },
              child: Text("Connect to Existing"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void showExistingDeviceSelectionDialog(
      BuildContext context,
      List<MidiDevice> availableDevices,
      Function(MidiDevice) onDeviceSelected,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select an existing device"),
          content: SingleChildScrollView(
            child: Column(
              children: availableDevices.map((existingDevice) {
                return ListTile(
                  title: Text(existingDevice.name),
                  onTap: () {
                    Navigator.pop(context);
                    onDeviceSelected(existingDevice);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}