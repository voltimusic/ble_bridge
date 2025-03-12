import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Download App",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        // Windows Download Button
        _buildDownloadButton(
          icon: const FaIcon(FontAwesomeIcons.windows), // ✅ Official Windows logo
          label: "Download for Windows",
          url: "https://www.voltimusic.com", // Replace with actual Windows download link
        ),

        const SizedBox(height: 8),

// ✅ Mac Button
        _buildDownloadButton(
          icon: const Icon(Icons.apple, color: Colors.black), // ✅ Standard Apple Icon
          label: "Download for macOS",
          url: "https://www.voltimusic.com", // Replace with actual macOS download link
        ),
      ],
    );
  }

  // 🟠 Reusable Download Button
  Widget _buildDownloadButton({required Widget icon, required String label, required String url}) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url); // Convert string to URI
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print("Could not launch $url");
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF105FB9), // ✅ Start Color
              Color(0xFF16D9F3), // ✅ End Color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            icon, // ✅ Now supports FaIcon and Icon widgets
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
