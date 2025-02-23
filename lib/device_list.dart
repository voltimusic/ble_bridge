import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:provider/provider.dart';

import 'MidiService.dart';


class DeviceList extends StatelessWidget {
  final String title;
  final List<MidiDevice> devices;
  final List<MidiDevice> availableDevices;
  final Map<String, String> bleDeviceMapping;
  final Function(MidiDevice) onDeviceSelected;

  const DeviceList({
    required this.title,
    required this.devices,
    required this.availableDevices,
    required this.bleDeviceMapping,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final isConnected = device.connected;
                final isMapped = bleDeviceMapping.containsKey(device.id);
                final mappedDeviceId = bleDeviceMapping[device.id];
                final mappedDevice = mappedDeviceId != null
                    ? availableDevices.firstWhere(
                      (d) => d.id == mappedDeviceId,
                  orElse: () => device,
                )
                    : null;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Add margin
                  elevation: 2, // Add shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isConnected
                          ? LinearGradient(
                        colors: [
                          Colors.blue !, // Light green
                          Colors.blue[50]!, // Light blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.grey[50]!, // Light grey
                          Colors.grey[100]!, // Slightly darker grey
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8), // Match the Card's rounded corners
                    ),
                    child: ListTile(
                      leading: Icon(
                        isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                        color: isConnected ? Colors.greenAccent : Colors.grey, // Change color based on connection status
                      ),
                      title: Text(device.name),
                      subtitle: isMapped && mappedDevice != null
                          ? Text("Connected to: ${mappedDevice.name}")
                          : null,
                      trailing: isConnected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      onTap: () => onDeviceSelected(device),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}