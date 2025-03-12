import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'DownloadSection.dart'; // ✅ Import the Download Section widget

class SideNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & App Name Section
          const Row(
            children: [
              Icon(Icons.bluetooth_audio, color: Color(0xFF105FB9), size: 20),
              SizedBox(width: 10),
              Text(
                "MIDI BLE Bridge",
                style: TextStyle(
                  color: Color(0xFF105FB9),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color (change as needed)
                  borderRadius: BorderRadius.circular(20), // ✅ Rounded edges
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Soft shadow
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                width: 100,
                child: Center(
                  child: Image.asset(
                    "assets/logo.png", // ✅ Replace with actual logo path
                    height: 100, // Adjust size as needed
                  ),
                )),
          ),

          const SizedBox(height: 40),
          const Text(
            "Contact Us",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          _buildNavItem(const Icon(Icons.language, color: Colors.grey), "www.voltimusic.com", false, ),
          _buildNavItem(const Icon(Icons.email, color: Colors.grey), "voltitech@contact.com", false, ),
          _buildNavItem(const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green), "+1514 629 8497", false,  ), // Replace with your number

          const Spacer(), // Pushes the download section to the bottom

          // ✅ Include the Download Section
          DownloadSection(),

          const SizedBox(height: 10),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "© 2025 VoltiTech Inc. All rights reserved.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4), // Add space between version and copyright
              Text(
                "v1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🟠 Navigation Item Builder
  Widget _buildNavItem(Widget icon, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          icon, // Accepts both Icons and FaIcon
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF105FB9) : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
