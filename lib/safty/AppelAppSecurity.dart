import 'package:flutter/services.dart';
import 'dart:io';

class AppelAppSecurity {
  static const MethodChannel _channel = MethodChannel('app_security');

  static Future<bool> isInstalledFromAppStore() async {
    try {
      final bool isValid = await _channel.invokeMethod('isInstalledFromAppStore');
      return isValid;
    } catch (e) {
      return false; // Default to false if there's an error
    }
  }

  static Future<String> performAppAttest() async {
    try {
      final String attestResult = await _channel.invokeMethod('performAppAttest');
      return attestResult;
    } catch (e) {
      return "Error: $e";
    }
  }

  // Validate the App Attest result
  static bool isAttestValid(String attestResult) {
    if (attestResult.contains("App Attest Failed") ||
        attestResult.contains("Error") ||
        attestResult.contains("failed") ||
        attestResult.contains("not supported")) {
      return false; // ❌ Invalid Attestation
    }
    return true; // ✅ App Attest is valid
  }
}
