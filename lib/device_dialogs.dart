import 'package:ble_reciever/widgets/HoverableCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceDialogs {
  static void showDisconnectDialog(
    BuildContext context,
    MidiDevice device,
    Function(MidiDevice) onDisconnect,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Match the dialog's rounded corners
          ),
          titlePadding: EdgeInsets.zero,
          // Remove default title padding
          title: Container(
            padding: const EdgeInsets.all(16),
            // Add internal padding for the text
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF105FB9), // Dark Blue
                  Color(0xFF16D9F3), // Cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12), // Match the dialog's rounded corners
              ),
            ),
            child: const Text(
              "Disconnect Device",
              style: TextStyle(
                color: Colors.white, // White text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
              "The device '${device.name}' is already connected. Do you want to disconnect it?"),
          actions: [
            // Disconnect Button (Red)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onDisconnect(device);
              },
              child: const Text("Disconnect"),
            ),
            // Cancel Button (Grey)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Grey background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void showConnectionOptionsDialog(
    BuildContext context,
    MidiDevice device,
    Function(MidiDevice) onCreateNew,
    Function(MidiDevice) onConnectExisting,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Match the dialog's rounded corners
          ),
          titlePadding: EdgeInsets.zero,
          // Remove default title padding
          title: Container(
            padding: const EdgeInsets.all(16),
            // Add internal padding for the text
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF105FB9), // Dark Blue
                  Color(0xFF16D9F3), // Cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12), // Match the dialog's rounded corners
              ),
            ),
            child: const Text(
              "Choose an option",
              style: TextStyle(
                color: Colors.white, // White text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Text(
              "Do you want to create a new virtual MIDI device or connect to an existing one?"),
          actions: [
            // Create New Button (Green)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Green background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onCreateNew(device);
              },
              child: const Text("Create New"),
            ),
            // Connect to Existing Button (Blue)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                // Blue background
                foregroundColor: Colors.white,
                // White text
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onConnectExisting(device);
              },
              child: const Text("Connect to Existing"),
            ),
            // Cancel Button (Red)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void showExistingDeviceSelectionDialog(
      BuildContext context,
      List<MidiDevice> availableDevices,
      Function(MidiDevice) onDeviceSelected,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match the dialog's rounded corners
          ),
          titlePadding: EdgeInsets.zero, // Remove default title padding
          title: Container(
            padding: const EdgeInsets.all(16), // Add internal padding for the text
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF105FB9), // Dark Blue
                  Color(0xFF16D9F3), // Cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12), // Match the dialog's rounded corners
              ),
            ),
            child: const Text(
              "Select an existing device",
              style: TextStyle(
                color: Colors.white, // White text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: availableDevices.map((existingDevice) {
                return HoverableCard(
                  device: existingDevice,
                  onTap: () {
                    Navigator.pop(context);
                    onDeviceSelected(existingDevice);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            // Cancel Button (Red)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}


Future<bool> showLoggingWarningDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
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
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "Warning",
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
                  Text(
                    "Enabling logging may create latency. Are you sure you want to continue?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Cancel
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Enable Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirm
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Button color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Enable",
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
    },
  ) ?? false; // Return false if the dialog is dismissed

}

void  showReviewPopup(BuildContext context) {
  double rating = 0; // Stores the selected rating
  TextEditingController feedbackController = TextEditingController(); // Stores user input

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
        ),
        title: const Text(
          "Rate Our App",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star Rating
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber, // ✅ Star color
              ),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
            const SizedBox(height: 10),

            // Feedback Text Field
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                labelText: "Tell us what you think",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // ✅ Rounded text field
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // ✅ Submit button color
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool("hasReviewed", true); // ✅ Save review flag

              print("User Rating: $rating");
              print("User Feedback: ${feedbackController.text}");

              // ✅ Show Thank You Message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thank you for your feedback!"),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.of(context).pop(); // ✅ Close the popup
            },
            child: const Text("Submit"),
          ),

        ],
      );
    },
  );
}





