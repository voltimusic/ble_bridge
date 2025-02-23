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
  bool isLoggingEnabled = true; // Track whether logging is enabled
  double _logSectionHeight = 0.5; // Initial height of the log section (50% of the screen)

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
      onLog: (msg) {
        if (isLoggingEnabled) { // Only log if logging is enabled
          logProvider.addLog(msg);
        }
      },
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
        title: const Row(
          children: [
            Icon(Icons.bluetooth, color: Colors.white), // Bluetooth icon
            SizedBox(width: 8), // Add spacing between icon and text
            Text(
              'MIDI Bridge App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Use a custom font if desired
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        elevation: 10, // Add elevation for shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom corners
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF105FB9), // Hex: #9C27B0 (Purple)
                Color(0xFF16D9F3), // Hex: #E91E63 (Pink)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow color
                blurRadius: 10, // Blur intensity
                spreadRadius: 2, // Spread of the shadow
                offset: const Offset(0, 5), // Shadow position (x, y)
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(0), // Match the AppBar's rounded corners
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => bleService.refreshBluetoothConnection(context),
            icon: const Icon(Icons.refresh, color: Colors.white), // Refresh icon
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFE3F2FD), // Light Blue background
        child: Column(
          children: [
            // Device List Section
            Expanded(
              flex: ((1 - _logSectionHeight) * 100).toInt(), // Adjust flex based on log section height
              child: Row(
                children: [
                  if (bluetoothDevices.isEmpty) // Check if no devices are found
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Bluetooth MIDI Devices Found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                bleService.refreshBluetoothConnection(context);
                              },
                              child: Text("Refresh"),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    DeviceList(
                      title: "Bluetooth MIDI Devices",
                      devices: bluetoothDevices,
                      availableDevices: availableDevices,
                      bleDeviceMapping: midiService.bleDeviceMapping,
                      onDeviceSelected: toggleDeviceSelection,
                    ),
                ],
              ),
            ),
            // Draggable Divider
            GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  // Update the log section height based on drag movement
                  _logSectionHeight -= details.delta.dy / MediaQuery.of(context).size.height;
                  // Clamp the height between 0.1 and 0.9 (10% to 90% of the screen)
                  _logSectionHeight = _logSectionHeight.clamp(0.1, 0.9);
                });
              },
              child: Container(
                height: 8, // Height of the draggable area
                color: Colors.grey.withOpacity(0.5), // Divider color
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            // Log Section
            Expanded(
              flex: (_logSectionHeight * 100).toInt(), // Adjust flex based on log section height
              child: LoggingPage(  onToggleLogging: () {
                setState(() {}); // Refresh HomePage when logging is toggled
              },midiService: midiService,),
            ),
          ],
        ),
      ),
    );
  }

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

      if (midiService.bleDeviceMapping.containsKey(device.id)) {
        String? mappedDeviceId = midiService.bleDeviceMapping[device.id];

        if (mappedDeviceId != null) {
          MidiDevice? virtualDevice = availableDevices.firstWhere(
                (d) => d.id == mappedDeviceId,
            orElse: () => device,
          );
          midiService.disconnectDevice(virtualDevice);
          midiService.removeVirtualDevice(virtualDevice);
        }

        midiService.bleDeviceMapping.remove(device.id);
      }

      midiService.bleDeviceMapping.removeWhere((bleId, mappedId) => mappedId == device.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Disconnected: ${device.name}, removed mapping, and deleted virtual device"),
      ),
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
        const SnackBar(
          content: Text("Error: No devices found after creating virtual device"),
        ),
      );
      return;
    }

    setState(() {
      midiService.connectDevice(virtualDevice);
      midiService.addBleDeviceMapping(bleDevice, virtualDevice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Created and mapped virtual device: ${bleDevice.name} → ${virtualDevice.name}"),
      ),
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