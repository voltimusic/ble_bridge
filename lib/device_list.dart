import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
 

class DeviceList extends StatelessWidget {
  final String title;
  final List<MidiDevice> devices;
  final Function(MidiDevice) onDeviceSelected;

  const DeviceList({
    required this.title,
    required this.devices,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final isSelected = device.connected;
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text("Type: ${device.type}"),
                  leading: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                  onTap: () => onDeviceSelected(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}