import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:provider/provider.dart';
import 'LoggingPage.dart';
import 'MidiLog.dart';
import 'MidiService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MidiDevice> availableDevices = [];
  List<MidiDevice> bluetoothDevices = [];
  Set<MidiDevice> selectedDevices = {}; // Multi-selection
  late MidiService midiService;
  final MidiCommand _midiCommand = MidiCommand();
  bool _didAskForBluetoothPermissions = false;


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

    midiService.init();
  }
  Future<void> _informUserAboutBluetoothPermissions(
      BuildContext context) async {
    if (_didAskForBluetoothPermissions) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Please Grant Bluetooth Permissions to discover BLE MIDI Devices.'),
          content: const Text(
              'In the next dialog we might ask you for bluetooth permissions.\n'
                  'Please grant permissions to make bluetooth MIDI possible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok. I got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions = true;

    return;
  }
  Future<void> _refreshBluetoothConnection(BuildContext context) async {
    // Ask for Bluetooth permissions
    await _informUserAboutBluetoothPermissions(context);

    // Start Bluetooth
    if (kDebugMode) {
      print("start ble central");
    }
    await _midiCommand.startBluetoothCentral().catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
      ));
    });

    if (kDebugMode) {
      print("wait for init");
    }
    await _midiCommand.waitUntilBluetoothIsInitialized().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (kDebugMode) {
          print("Failed to initialize Bluetooth");
        }
      },
    );

    // If Bluetooth is powered on, start scanning
    if (_midiCommand.bluetoothState == BluetoothState.poweredOn) {
      _midiCommand.startScanningForBluetoothDevices().catchError((err) {
        if (kDebugMode) {
          print("Error $err");
        }
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Scanning for Bluetooth devices ...'),
        ));
      }
    } else {
      final messages = {
        BluetoothState.unsupported:
        'Bluetooth is not supported on this device.',
        BluetoothState.poweredOff:
        'Please switch on Bluetooth and try again.',
        BluetoothState.poweredOn: 'Everything is fine.',
        BluetoothState.resetting:
        'Currently resetting. Try again later.',
        BluetoothState.unauthorized:
        'This app needs Bluetooth permissions. Please open settings, find your app and assign Bluetooth access rights and start your app again.',
        BluetoothState.unknown:
        'Bluetooth is not ready yet. Try again later.',
        BluetoothState.other:
        'This should never happen. Please inform the developer of your app.',
      };
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(messages[_midiCommand.bluetoothState] ??
              'Unknown Bluetooth state: ${_midiCommand.bluetoothState}'),
        ));
      }
    }

    if (kDebugMode) {
      print("done");
    }
    setState(() {});
  }
  void _createNewVirtualDevice(MidiDevice bleDevice) async {
    setState(() {
      selectedDevices.add(bleDevice);
      midiService.addVirtualDevice(bleDevice);
      midiService.connectDevice(bleDevice);
    });

    // Fetch the latest list of devices directly from MidiCommand
    List<MidiDevice>? devices = await _midiCommand.devices;

    if (devices == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No devices found after creating virtual device")),
      );
      return;
    }

    // Find the new virtual device by its generated name
    String virtualDeviceName = midiService.getVirtualDeviceName(bleDevice);
    MidiDevice? virtualDevice = devices.firstWhere(
          (device) => device.name == virtualDeviceName,
      orElse: () => bleDevice, // Default to BLE device if no match
    );

    setState(() {
      midiService.connectDevice(virtualDevice);
      midiService.addBleDeviceMapping(bleDevice, virtualDevice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Created and mapped virtual device: ${bleDevice.name} → ${virtualDevice.name}")),
    );
  }



  void _connectToExistingDevice(MidiDevice bleDevice) {
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
                    setState(() {

                        selectedDevices.add(bleDevice);
                        midiService.connectDevice(bleDevice);
                        midiService.connectDevice(existingDevice);
                        midiService.addBleDeviceMapping(bleDevice, existingDevice);
                    });

                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }


  void _connectDevice(MidiDevice device) {
    setState(() {
      selectedDevices.add(device);
      midiService.connectDevice(device);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connected to: ${device.name}")),
    );
  }
  void toggleDeviceSelection(MidiDevice device) {
    if (device.connected) {
      // If the device is already connected, ask for confirmation before disconnecting
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
                  _disconnectDevice(device);
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
    } else {
      // Ask whether to create a new virtual MIDI device or connect to an existing one
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Choose an option"),
            content: Text("Do you want to create a new virtual MIDI device or connect to an existing one?"),
            actions: [
              // Create a new virtual MIDI device
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewVirtualDevice(device);
                },
                child: Text("Create New"),
              ),
              // Connect to an existing device
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _connectToExistingDevice(device);
                },
                child: Text("Connect to Existing"),
              ),
              // Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIDI Bridge App'),
        actions: [
          IconButton(
            onPressed: () => _refreshBluetoothConnection(context),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Bluetooth MIDI Devices",
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: bluetoothDevices.length,
                          itemBuilder: (context, index) {
                            final device = bluetoothDevices[index];
                            final isSelected = bluetoothDevices[index].connected;
                            return ListTile(
                              title: Text(device.name),
                              subtitle: Text("Type: ${device.type}"),
                              leading: Icon(isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                              onTap: () => toggleDeviceSelection(device),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Available MIDI Devices",
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: availableDevices.length,
                          itemBuilder: (context, index) {
                            final device = availableDevices[index];
                            final isSelected = selectedDevices.contains(device);
                            return ListTile(
                              title: Text(device.name),
                              subtitle: Text("Type: ${device.type}"),
                              leading: Icon(isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                              onTap: () => toggleDeviceSelection(device),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            child: const Text('Open Log Page'),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LoggingPage())),
          ),
        ],
      ),
    );
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


}
