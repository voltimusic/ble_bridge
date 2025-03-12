import 'package:ble_reciever/widgets/buildSideNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoggingEnabled = true;
  double _logSectionHeight = 0.4;


  Future<void> checkAndShowReviewPopup(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasReviewed = prefs.getBool("hasReviewed") ?? false; // Default to false

    if (!hasReviewed) {
      showReviewPopup(context);
    }
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () { // Small delay for better UI
      checkAndShowReviewPopup(context);
    });

    final logProvider = Provider.of<MidiLogProvider>(context, listen: false);

    midiService = MidiService(
      onDevicesUpdated: (devices) {
        setState(() => availableDevices = devices);
      },
      onBluetoothDevicesUpdated: (devices) {
        setState(() => bluetoothDevices = devices);
      },
      onLog: (msg) {
        if (isLoggingEnabled) logProvider.addLog(msg);
      },
    );

    bleService = BleService(
      onBluetoothDevicesUpdated: (devices) {
        setState(() => bluetoothDevices = devices);
      },
      onLog: (msg) => logProvider.addLog(msg),
      midiService: midiService, // Pass MidiService instance
    );

    midiService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9BBBDF).withOpacity(0.5) ,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Device List Section
                  Expanded(
                    flex: ((1 - _logSectionHeight) * 100).toInt(),
                    child: _buildDeviceListSection(),
                  ),

                  // 🟠 RESTORED DRAGGABLE DIVIDER
                  _buildDraggableDivider(),

                  // Logging Section
                  Expanded(
                    flex: (_logSectionHeight * 100).toInt(),
                    child: _buildLoggingSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // 🟠 SIDE NAVIGATION MENU

  // 🟠 DEVICE LIST SECTION
// 🟠 DEVICE LIST SECTION WITH HEADER BAR
  Widget _buildDeviceListSection() {
    return Column(
      children: [
        // HEADER BAR (Separate from the device list)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available MIDI Devices",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,

                  color: Color(0xFF105FB9), // Orange
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF105FB9)),
                onPressed: () => bleService.refreshBluetoothConnection(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // DEVICE LIST
        Expanded(child: _buildDeviceList()),
      ],
    );
  }

  // 🟠 Device List Section
  Widget _buildDeviceList() {
    return Container(
      width: double.infinity, // Make it 100% width
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: bluetoothDevices.isEmpty
          ? _buildNoDeviceUI()
          : DeviceList(
        title: "Bluetooth MIDI Devices",
        devices: bluetoothDevices,
        availableDevices: availableDevices,
        bleDeviceMapping: midiService.bleDeviceMapping,
        onDeviceSelected: toggleDeviceSelection,
      ),
    );
  }

  // 🟠 DRAGGABLE DIVIDER
  Widget _buildDraggableDivider() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _logSectionHeight -= details.delta.dy / MediaQuery.of(context).size.height;
          _logSectionHeight = _logSectionHeight.clamp(0.1, 0.9);
        });
      },
      child: Container(
        height: 8,
        color: Colors.transparent ,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF105FB9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  // 🟠 LOGGING SECTION
  Widget _buildLoggingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: LoggingPage(
        onToggleLogging: () {
          setState(() {});
        },
        midiService: midiService,
      ),
    );
  }

  // 🟠 NO DEVICE UI
  Widget _buildNoDeviceUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No Bluetooth MIDI Devices Found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF105FB9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => bleService.refreshBluetoothConnection(context),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  // 🟠 NAVIGATION ITEM BUILDER
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: isActive ? const Color(0xFFFF6600) : Colors.grey, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF6600) : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 🟠 BOX DECORATION FOR CONTAINERS
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // 🟠 DEVICE SELECTION TOGGLE
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

  // 🟠 DEVICE DISCONNECTION
  void _disconnectDevice(MidiDevice device) {
    setState(() {
      selectedDevices.remove(device);
      midiService.disconnectDevice(device);
      midiService.bleDeviceMapping.remove(device.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Disconnected: ${device.name}")),
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
