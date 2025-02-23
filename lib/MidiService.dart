import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter/foundation.dart';

class MidiService {
  final Function(List<MidiDevice>) onDevicesUpdated;
  final Function(List<MidiDevice>) onBluetoothDevicesUpdated;
  final Function(MidiPacket) onLog;
  final MidiCommand _midiCommand = MidiCommand();
  bool isLoggingEnabled = false; // Add logging state
  // Message filter: Track which types of messages should be logged
  Set<String> messageFilters = {
    "Note On",
    "Note Off",
    "Control Change",
    "Program Change",
    "Pitch Bend",
    "System Exclusive",
  };
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



      // Get the mapped target device for this BLE device
      String? targetDeviceId = bleDeviceMapping[packet.device.id];

      if (targetDeviceId != null) {
        _midiCommand.sendData(packet.data,deviceId:targetDeviceId);
      }
      // Check if logging is enabled before calling onLog
      // Check if logging is enabled and the message type is allowed
      if (isLoggingEnabled && _shouldLogMessage(packet.data)) {
        onLog(packet);
      }
    });

    // Start scanning for Bluetooth MIDI devices
    _midiCommand.startScanningForBluetoothDevices();
  }
  void connectDevice(MidiDevice device) {
    _midiCommand.connectToDevice(device).then((_) {

    }).catchError((err) {

    });
  }
  // Method to toggle logging
  void toggleLogging() {
    isLoggingEnabled = !isLoggingEnabled;
  }
  void disconnectDevice(MidiDevice device) {
    _midiCommand.disconnectDevice(device);

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



  // Check if a message should be logged based on the filter
  bool _shouldLogMessage(List<int> data) {
    final messageType = _getMessageType(data);
    return messageFilters.contains(messageType);
  }

  // Helper method to get the message type
  String _getMessageType(List<int> data) {
    if (data.isEmpty) return "Unknown";
    final statusByte = data[0];

    // Channel Voice Messages
    if ((statusByte & 0xF0) == 0x80) return "Note Off";
    if ((statusByte & 0xF0) == 0x90) return "Note On";
    if ((statusByte & 0xF0) == 0xA0) return "Polyphonic Aftertouch";
    if ((statusByte & 0xF0) == 0xB0) return "Control Change";
    if ((statusByte & 0xF0) == 0xC0) return "Program Change";
    if ((statusByte & 0xF0) == 0xD0) return "Channel Aftertouch";
    if ((statusByte & 0xF0) == 0xE0) return "Pitch Bend";

    // System Common Messages
    if (statusByte == 0xF1) return "MIDI Time Code Quarter Frame";
    if (statusByte == 0xF2) return "Song Position Pointer";
    if (statusByte == 0xF3) return "Song Select";
    if (statusByte == 0xF6) return "Tune Request";
    if (statusByte == 0xF7) return "End of Exclusive";

    // System Real-Time Messages
    if (statusByte == 0xF8) return "Timing Clock";
    if (statusByte == 0xFA) return "Start";
    if (statusByte == 0xFB) return "Continue";
    if (statusByte == 0xFC) return "Stop";
    if (statusByte == 0xFE) return "Active Sensing";
    if (statusByte == 0xFF) return "Reset";

    // System Exclusive Messages
    if (statusByte == 0xF0) return "System Exclusive";

    return "Unknown";
  }

// Other methods (connectDevice, disconnectDevice, etc.) remain unchanged

}
