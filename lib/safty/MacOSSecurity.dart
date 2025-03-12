import 'dart:io';
import 'package:flutter/services.dart';

class MacOSSecurity {
  static const MethodChannel _channel = MethodChannel('app_security');

  /// Runs all security checks for macOS and returns an error message if any issues exist.
  /// If there are no issues, returns `null` (app can run normally).
  static Future<String?> runSecurityChecks() async {
    if (!Platform.isMacOS) return null; // ✅ Skip checks on non-macOS platforms

    String errorMessage = "";

    // Step 1: Check if the app is installed from the Mac App Store
    bool valid = await isInstalledFromAppStore();
    if (!valid) {
      errorMessage = "❌ App not installed from Mac App Store.";
    }

    // Step 2: Perform App Attest validation
    String attestResult = await performAppAttest();
    if (!isAttestValid(attestResult)) {
      if (attestResult.contains("not supported") || attestResult.contains("allowing app")) {
        // ✅ Allow the app to run if App Attest is unsupported
        return null;
      } else {
        // ❌ Block the app only if App Attest fails
        errorMessage = "❌ App integrity check failed: $attestResult";
      }
    }

    // Return error message if any issues exist, otherwise return null
    return errorMessage.isNotEmpty ? errorMessage : null;
  }

  /// Check if the app was installed from the Mac App Store (macOS only)
  static Future<bool> isInstalledFromAppStore() async {
    if (!Platform.isMacOS) return true; // ✅ Skip check on non-macOS platforms
    try {
      final bool isValid = await _channel.invokeMethod('isInstalledFromAppStore');
      return isValid;
    } catch (e) {
      return false;
    }
  }

  /// Perform App Attest API verification (macOS only)
  static Future<String> performAppAttest() async {
    if (!Platform.isMacOS) return "App Attest not required";
    try {
      final String attestResult = await _channel.invokeMethod('performAppAttest');
      return attestResult;
    } catch (e) {
      return "Error: $e";
    }
  }

  /// Validate the App Attest result
  static bool isAttestValid(String attestResult) {
    if (!Platform.isMacOS) return true; // ✅ Skip validation on non-macOS platforms

    if (attestResult.contains("App Attest Failed") ||
        attestResult.contains("Error") ||
        attestResult.contains("failed")) {
      return false; // ❌ Invalid Attestation
    }
    return true; // ✅ App Attest is valid OR not supported
  }
}
