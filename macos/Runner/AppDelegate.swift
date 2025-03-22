import Cocoa
import FlutterMacOS
import DeviceCheck
@main
class AppDelegate: FlutterAppDelegate {
   override func applicationDidFinishLaunching(_ aNotification: Notification) {
        let controller = self.mainFlutterWindow?.contentViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "app_security", binaryMessenger: controller.engine.binaryMessenger)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "isInstalledFromAppStore":
                result(self.isInstalledFromAppStore())

            case "performAppAttest":
                self.performAppAttest(result: result)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        super.applicationDidFinishLaunching(aNotification)
    }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

      private func isInstalledFromAppStore() -> Bool {
          let receiptPath = Bundle.main.bundlePath + "/Contents/_MASReceipt/receipt"
          return FileManager.default.fileExists(atPath: receiptPath)
      }

      private func performAppAttest(result: @escaping FlutterResult) {
          if #available(macOS 11.0, *) {
              let attestationService = DCAppAttestService.shared
              print("🔍 Checking App Attest support: \(attestationService.isSupported)")

              if !attestationService.isSupported {
                  print("⚠️ App Attest is NOT supported on this Mac, allowing app to run.")
                  result("App Attest not supported, allowing app.")
                  return // ✅ Allow the app to run if App Attest is not supported
              }

              attestationService.generateKey { keyId, error in
                  if let error = error {
                      print("❌ App Attest Failed: \(error.localizedDescription)")
                      result("App Attest Failed: \(error.localizedDescription)")
                      return
                  }
                  if let keyId = keyId {
                      print("✅ App Attest Key Generated: \(keyId)")
                      result("App Attest Key: \(keyId)")
                  } else {
                      print("❌ App Attest Key Generation Failed")
                      result("App Attest Key generation failed")
                  }
              }
          } else {
              print("❌ App Attest requires macOS 11.0 or later, allowing app to run.")
              result("App Attest requires macOS 11.0 or later, allowing app.")
          }
      }

}
