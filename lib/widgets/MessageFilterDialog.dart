import 'package:flutter/material.dart';

class MessageFilterDialog extends StatefulWidget {
  final Set<String> filters;
  final Function(Set<String>) onFiltersUpdated;

  const MessageFilterDialog({
    required this.filters,
    required this.onFiltersUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _MessageFilterDialogState createState() => _MessageFilterDialogState();
}

class _MessageFilterDialogState extends State<MessageFilterDialog> {
  final List<String> allMessageTypes = [
    "Note On",
    "Note Off",
    "Control Change",
    "Program Change",
    "Pitch Bend",
    "System Exclusive",
  ];

  late Set<String> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Set.from(widget.filters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom App Bar
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF384453), // AppBar color
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "Filter MIDI Messages",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Dialog Content
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: allMessageTypes.map((type) {
                      return CheckboxListTile(
                        title: Text(type),
                        value: selectedFilters.contains(type),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedFilters.add(type);
                            } else {
                              selectedFilters.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Apply Button
                    ElevatedButton(
                      onPressed: () {
                        widget.onFiltersUpdated(selectedFilters);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Button color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Apply",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showMessageFilterDialog(
    BuildContext context, Set<String> filters, Function(Set<String>) onFiltersUpdated) async {
  await showDialog(
    context: context,
    builder: (context) {
      return MessageFilterDialog(
        filters: filters,
        onFiltersUpdated: onFiltersUpdated,
      );
    },
  );
}
