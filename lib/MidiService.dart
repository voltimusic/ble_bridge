import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter/foundation.dart';

class MidiService {
  final Function(List<MidiDevice>) onDevicesUpdated;
  final Function(List<MidiDevice>) onBluetoothDevicesUpdated;
  final Function(String) onLog;
  final MidiCommand _midiCommand = MidiCommand();
  // Map BLE Device ID -> Target Device ID
  Map<String, String> bleDeviceMapping = {};
  MidiService({
    required this.onDevicesUpdated,
    required this.onBluetoothDevicesUpdated,
    required this.onLog,
  });

  void init() {
    // Listen for device setup changes & update UI
    _midiCommand.onMidiSetupChanged?.listen((_) async {
      List<MidiDevice>? devices = await _midiCommand.devices;

      if (devices != null) {
        List<MidiDevice> filteredDevices = devices
            .where((device) => device.type.toLowerCase() != 'ble')
            .toList();
        List<MidiDevice> bleFilteredDevices = devices
            .where((device) => device.type.toLowerCase() == 'ble')
            .toList();

        onDevicesUpdated(filteredDevices);
        onBluetoothDevicesUpdated(bleFilteredDevices);
      }
    });

    _midiCommand.onBluetoothStateChanged.listen((_) async {});

    // Listen for incoming MIDI messages and forward them
    _midiCommand.onMidiDataReceived?.listen((packet) {
      final List<int> midiBytes = packet.data;
      if(midiBytes.length==1)
        {
          return;
        }
      String message = midiBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');

      onLog("Received MIDI Data from ${packet.device.name}: $message");

      // Get the mapped target device for this BLE device
      String? targetDeviceId = bleDeviceMapping[packet.device.id];

      if (targetDeviceId != null) {

        _midiCommand.sendData(packet.data,deviceId:targetDeviceId);
        onLog("Forwarded MIDI Data to: ${targetDeviceId}");
      }
    });

    // Start scanning for Bluetooth MIDI devices
    _midiCommand.startScanningForBluetoothDevices();
  }
  void connectDevice(MidiDevice device) {
    _midiCommand.connectToDevice(device).then((_) {
      onLog("Connected: ${device.name}");
    }).catchError((err) {
      onLog("Error Connecting: $err");
    });
  }

  void disconnectDevice(MidiDevice device) {
    _midiCommand.disconnectDevice(device);
    onLog("Disconnected: ${device.name}");
  }

  void addVirtualDevice(MidiDevice device) {
    _midiCommand.addVirtualDevice(name: getVirtualDeviceName(device));
  }

  void removeVirtualDevice(MidiDevice device) {
    _midiCommand.removeVirtualDevice(name: device.name);
  }

  String getVirtualDeviceName(MidiDevice device)
  {
    return  "${device.name} usb";
  }


  void addBleDeviceMapping(MidiDevice bleDevice, MidiDevice selectedDevice) {
    bleDeviceMapping[bleDevice.id] = selectedDevice.id;  // Use IDs instead of names
    onLog("Mapped BLE Device: ${bleDevice.name} (${bleDevice.id}) → ${selectedDevice.name} (${selectedDevice.id})");
  }

  Future<MidiDevice?> findVirtualDevice(MidiDevice bleDevice) async {
    // Fetch the latest list of devices directly from MidiCommand
    List<MidiDevice>? devices = await _midiCommand.devices;

    // Find the new virtual device by its generated name
    String virtualDeviceName =  getVirtualDeviceName(bleDevice);
    return  devices?.firstWhere(
          (device) => device.name == virtualDeviceName,
      orElse: () => bleDevice, // Default to BLE device if no match
    );
  }
}
