import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:provider/provider.dart';
import 'MidiService.dart';
import 'device_dialogs.dart';
import 'device_list.dart';
import 'services/ble_service.dart';

import 'LoggingPage.dart';
import 'MidiLog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MidiDevice> availableDevices = [];
  List<MidiDevice> bluetoothDevices = [];
  Set<MidiDevice> selectedDevices = {};
  late MidiService midiService;
  late BleService bleService;

  @override
  void initState() {
    super.initState();
    final logProvider = Provider.of<MidiLogProvider>(context, listen: false);

    midiService = MidiService(
      onDevicesUpdated: (devices) {
        setState(() => availableDevices = devices);
      },
      onBluetoothDevicesUpdated: (devices) {
        setState(() => bluetoothDevices = devices);
      },
      onLog: (msg) => logProvider.addLog(msg),
    );

    bleService = BleService(
      onBluetoothDevicesUpdated: (devices) {
        setState(() => bluetoothDevices = devices);
      },
      onLog: (msg) => logProvider.addLog(msg),
    );

    midiService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIDI Bridge App'),
        actions: [
          IconButton(
            onPressed: () => bleService.refreshBluetoothConnection(context),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                DeviceList(
                  title: "Bluetooth MIDI Devices",
                  devices: bluetoothDevices,
                  onDeviceSelected: toggleDeviceSelection,
                ),
                DeviceList(
                  title: "Available MIDI Devices",
                  devices: availableDevices,
                  onDeviceSelected: toggleDeviceSelection,
                ),
              ],
            ),
          ),
          Expanded(child: LoggingPage())

        ],
      ),
    );
  }

//////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////                            Functions                           //////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

  void toggleDeviceSelection(MidiDevice device) {
    if (device.connected) {
      DeviceDialogs.showDisconnectDialog(context, device, _disconnectDevice);
    } else {
      DeviceDialogs.showConnectionOptionsDialog(
        context,
        device,
        _createNewVirtualDevice,
        _connectToExistingDevice,
      );
    }
  }

  void _disconnectDevice(MidiDevice device) {
    setState(() {
      selectedDevices.remove(device);
      midiService.disconnectDevice(device);

      // Check if the device is a BLE device and remove its mapping
      if (midiService.bleDeviceMapping.containsKey(device.id)) {
        String? mappedDeviceId = midiService.bleDeviceMapping[device.id];

        // If a virtual device was created for this BLE device, remove it
        if (mappedDeviceId != null) {
          MidiDevice? virtualDevice = availableDevices.firstWhere(
                (d) => d.id == mappedDeviceId,
            orElse: () => device,
          );
          midiService.disconnectDevice(virtualDevice);
          midiService.removeVirtualDevice(virtualDevice);
        }

        // Remove the BLE device mapping
        midiService.bleDeviceMapping.remove(device.id);
      }

      // Also check if this device is a mapped target device and remove any references
      midiService.bleDeviceMapping.removeWhere((bleId, mappedId) => mappedId == device.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Disconnected: ${device.name}, removed mapping, and deleted virtual device")),
    );
  }
  void _createNewVirtualDevice(MidiDevice bleDevice) async {
    setState(() {
      selectedDevices.add(bleDevice);
      midiService.addVirtualDevice(bleDevice);
      midiService.connectDevice(bleDevice);
    });

    final virtualDevice = await midiService.findVirtualDevice(bleDevice);

    if (virtualDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No devices found after creating virtual device")),
      );
      return;
    }

    setState(() {
      midiService.connectDevice(virtualDevice);
      midiService.addBleDeviceMapping(bleDevice, virtualDevice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Created and mapped virtual device: ${bleDevice.name} → ${virtualDevice.name}")),
    );
  }

  void _connectToExistingDevice(MidiDevice bleDevice) {
    DeviceDialogs.showExistingDeviceSelectionDialog(
      context,
      availableDevices,
          (existingDevice) {
        setState(() {
          selectedDevices.add(bleDevice);
          midiService.connectDevice(bleDevice);
          midiService.connectDevice(existingDevice);
          midiService.addBleDeviceMapping(bleDevice, existingDevice);
        });
      },
    );
  }
}