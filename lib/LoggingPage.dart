import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'MidiLog.dart';

class LoggingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MIDI Message Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Provider.of<MidiLogProvider>(context, listen: false).clearLogs();
            },
          ),
        ],
      ),
      body: Consumer<MidiLogProvider>(
        builder: (context, logProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: logProvider.logs.length,
                  itemBuilder: (context, index) {
                    final log = logProvider.logs[index];
                    return ListTile(
                      title: Text(log.message),
                      subtitle: Text(log.timestamp.toString()),
                    );
                  },
                ),
              ),
              if (logProvider.logs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<MidiLogProvider>(context, listen: false)
                          .clearLogs();
                    },
                    child: Text("Clear Logs"),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
