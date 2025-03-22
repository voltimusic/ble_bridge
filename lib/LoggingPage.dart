import 'package:ble_bridge_volti/widgets/MessageFilterDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:provider/provider.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'MidiLog.dart';
import 'MidiService.dart';
import 'device_dialogs.dart';

class LoggingPage extends StatelessWidget {
  final MidiService midiService;
  final VoidCallback onToggleLogging;

  const LoggingPage({
    Key? key,
    required this.midiService,
    required this.onToggleLogging,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            midiService.isLoggingEnabled ? Icons.visibility : Icons.visibility_off,
            color: Colors.black, // ✅ Changed to black
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
                  midiService.isLoggingEnabled ? "Logging enabled" : "Logging disabled",
                  style: const TextStyle(color: Colors.black), // ✅ Changed to black
                ),
                backgroundColor: Colors.white, // ✅ Black text needs a light background
              ),
            );
          },
          tooltip: midiService.isLoggingEnabled ? "Disable logging" : "Enable logging",
        ),
        title: const Text(
          'MIDI Message Log',
          style: TextStyle(
            color: Colors.black, // ✅ Changed to black
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white, // ✅ Ensure light background
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black), // ✅ Changed to black
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
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              Provider.of<MidiLogProvider>(context, listen: false).clearLogs();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // ✅ Changed background to white for black text visibility
        child: Consumer<MidiLogProvider>(
          builder: (context, logProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            decoration: const BoxDecoration(
                              color: Colors.white, // ✅ Changed background to white
                            ),
                            columns: const [
                              DataColumn(
                                label: Text("Device", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Dir", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Message", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Channel", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Value", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Copy", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                              DataColumn(
                                label: Text("Hex", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                              ),
                            ],
                            rows: logProvider.logs.map((log) {
                              final packet = log.message;
                              final device = packet.device.name;
                              final direction = "In";
                              final message = _getMessageType(packet.data);
                              final channel = _getChannel(packet.data);
                              final value = _getValue(packet.data);
                              final hex = packet.data
                                  .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                                  .join(' ');

                              return DataRow(
                                cells: [
                                  DataCell(Text(device, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
                                  DataCell(Text(direction, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
                                  DataCell(Text(message, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
                                  DataCell(Text(channel, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
                                  DataCell(Text(value, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.content_copy, color: Colors.blue),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: hex));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Copied to clipboard: $hex",
                                              style: const TextStyle(color: Colors.black), // ✅ Changed to black
                                            ),
                                            backgroundColor: Colors.white, // ✅ Ensure visibility
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(Text(hex, style: const TextStyle(color: Colors.black))), // ✅ Changed to black
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
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Provider.of<MidiLogProvider>(context, listen: false).clearLogs();
                      },
                      child: const Text("Clear Logs"),
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

    if ((statusByte & 0xF0) == 0x80) return "Note Off";
    if ((statusByte & 0xF0) == 0x90) return "Note On";
    if ((statusByte & 0xF0) == 0xA0) return "Polyphonic Aftertouch";
    if ((statusByte & 0xF0) == 0xB0) return "Control Change";
    if ((statusByte & 0xF0) == 0xC0) return "Program Change";
    if ((statusByte & 0xF0) == 0xD0) return "Channel Aftertouch";
    if ((statusByte & 0xF0) == 0xE0) return "Pitch Bend";
    if (statusByte == 0xF0) return "System Exclusive";

    return "Unknown";
  }

  String _getChannel(List<int> data) {
    if (data.isEmpty) return "N/A";
    final statusByte = data[0];
    final channel = (statusByte & 0x0F) + 1;
    return channel.toString();
  }

  String _getValue(List<int> data) {
    if (data.length < 2) return "N/A";
    return data[1].toString();
  }
}
