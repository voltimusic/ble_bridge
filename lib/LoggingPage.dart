import 'package:ble_reciever/widgets/MessageFilterDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:provider/provider.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'MidiLog.dart';
import 'MidiService.dart';
import 'device_dialogs.dart';

class LoggingPage extends StatelessWidget {

  final MidiService midiService; // Add MidiService as a parameter
  final VoidCallback onToggleLogging; // Add callback for toggleLogging

  const LoggingPage({
    Key? key,
    required this.midiService, // Require MidiService in the constructor
    required this.onToggleLogging, // Require callback in the constructor
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            midiService.isLoggingEnabled ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () async {
            if (!midiService.isLoggingEnabled) {
              final bool confirm = await showLoggingWarningDialog(context);
              if (!confirm) return;
            }

            midiService.toggleLogging();
            onToggleLogging();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  midiService.isLoggingEnabled
                      ? "Logging enabled"
                      : "Logging disabled",
                ),
              ),
            );
          },
          tooltip: midiService.isLoggingEnabled
              ? "Disable logging"
              : "Enable logging",
        ),
        title: const Text(
          'MIDI Message Log',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Color(0xFF384453),
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () async {
              await showMessageFilterDialog(
                context,
                midiService.messageFilters,
                    (newFilters) {
                    midiService.messageFilters = newFilters;
                },
              );
            },
            tooltip: "Filter MIDI Messages",
          ),
          // Clear Logs Button
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              Provider.of<MidiLogProvider>(context, listen: false).clearLogs();
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF2A2A2A), // Background color for the entire page
        child: Consumer<MidiLogProvider>(
          builder: (context, logProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true, // Always show the scrollbar
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // Allow vertical scrolling
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width, // Take full width
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                          child: DataTable(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2A2A2A), // Background color for the DataTable
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Device",
                                  style: TextStyle(color: Colors.white), // White text for column headers
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Dir",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Message",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Channel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Value",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Copy",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Hex",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),

                            ],
                            rows: logProvider.logs.map((log) {
                              final packet = log.message;
                              final device = packet.device.name;
                              final direction = "In"; // Replace with actual direction if available
                              final message = _getMessageType(packet.data);
                              final channel = _getChannel(packet.data);
                              final value = _getValue(packet.data);
                              final hex = packet.data
                                  .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                                  .join(' ');

                              return DataRow(
                                cells: [
                                  DataCell(Text(device, style: TextStyle(color: Colors.white))), // Device
                                  DataCell(Text(direction, style: TextStyle(color: Colors.white))), // Dir
                                  DataCell(Text(message, style: TextStyle(color: Colors.white))), // Message
                                  DataCell(Text(channel, style: TextStyle(color: Colors.white))), // Channel
                                  DataCell(Text(value, style: TextStyle(color: Colors.white))), // Value
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.content_copy, color: Colors.blue), // Clipboard icon
                                      onPressed: () {
                                        // Copy the MIDI message to the clipboard
                                        Clipboard.setData(ClipboardData(text: hex));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Copied to clipboard: $hex"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(Text(hex, style: TextStyle(color: Colors.white))), // Hex

                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (logProvider.logs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Button color
                        foregroundColor: Colors.white, // Text color
                      ),
                      onPressed: () {
                        Provider.of<MidiLogProvider>(context, listen: false).clearLogs();
                      },
                      child: Text("Clear Logs"),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

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

  // Helper method to get the MIDI channel
  String _getChannel(List<int> data) {
    if (data.isEmpty) return "N/A";
    final statusByte = data[0];
    final channel = (statusByte & 0x0F) + 1; // MIDI channels are 1-based
    return channel.toString();
  }

  // Helper method to get the MIDI value
  String _getValue(List<int> data) {
    if (data.length < 2) return "N/A";
    return data[1].toString();
  }
}