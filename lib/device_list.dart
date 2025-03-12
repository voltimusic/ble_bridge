import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120, // Fixed height for horizontal list
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: devices.map((device) {
                final isConnected = device.connected;
                final isMapped = bleDeviceMapping.containsKey(device.id);
                final mappedDeviceId = bleDeviceMapping[device.id];
                final mappedDevice = mappedDeviceId != null
                    ? availableDevices.firstWhere(
                      (d) => d.id == mappedDeviceId,
                  orElse: () => device,
                )
                    : null;

                return GestureDetector(
                  onTap: () => onDeviceSelected(device),
                  child: Container(
  /*                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9BBBDF).withOpacity(0.5), // Shadow color
                          blurRadius: 10, // Softness of the shadow
                          spreadRadius: 0.5, // How far it spreads
                          offset: const Offset(1, 4), // X and Y position
                        ),
                      ],
                    ),*/
                    width: 200, // Set width for each card
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shadowColor: Color(0xFF9BBBDF).withOpacity(0.5), // Custom shadow color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded edges
                      ),
                      elevation: 4,
                      color: isConnected ? Colors.blue[100] : Colors.white ,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth,
                              color: isConnected ? Color(0xFF105FB9) : Color(0xFF105FB9),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isMapped && mappedDevice != null)
                              Text(
                                "Connected to: ${mappedDevice.name}",
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
