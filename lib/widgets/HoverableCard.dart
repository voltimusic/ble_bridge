import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class HoverableCard extends StatefulWidget {
  final MidiDevice device;
  final VoidCallback onTap;

  const HoverableCard({
    required this.device,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _HoverableCardState createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool isHovered = false;

  // Function to determine the icon based on the device type
  Widget _getDeviceIcon(MidiDevice device) {
    print(device.type.toLowerCase());
    if (device.type.toLowerCase() == "ble") {
      return Icon(Icons.bluetooth, color: Colors.blue); // Icon for BLE MIDI device
    } else if (device.type.toLowerCase() == "native") {
      return Icon(Icons.usb, color: Colors.green); // Icon for USB MIDI device
    } else  if (device.type.toLowerCase() == "network") {
      return Icon(Icons.network_wifi, color: Colors.orange); // Icon for Network MIDI device
    }
    else  if (device.type.toLowerCase() == "virtual") {
      return Icon(Icons.app_settings_alt, color: Colors.teal); // Icon for Network MIDI device
    } else {
      return Icon(Icons.help_outline, color: Colors.grey); // Default icon for unknown types
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4), // Add margin
        elevation: 2, // Add shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isHovered
                ? LinearGradient(
              colors: [
                Colors.blue[100]!, // Light blue
                Colors.blue[200]!, // Slightly darker blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [
                Colors.grey[100]!, // Light grey
                Colors.grey[200]!, // Slightly darker grey
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8), // Match the Card's rounded corners
          ),
          child: ListTile(
            leading: _getDeviceIcon(widget.device), // Display the icon based on device type
            title: Text(widget.device.name),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}