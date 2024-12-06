import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionHandler {
  static Future<bool> requestBluetoothPermissions(BuildContext context) async {
    // First check if Bluetooth is available
    if (await Permission.bluetooth.status.isDenied) {
      debugPrint("Bluetooth permission is denied, requesting...");

      // Request Bluetooth permission
      PermissionStatus bluetoothStatus = await Permission.bluetooth.request();
      debugPrint("Bluetooth permission status after request: $bluetoothStatus");

      // For iOS, also request bluetoothScan and bluetoothConnect
      PermissionStatus bluetoothScanStatus =
          await Permission.bluetoothScan.request();
      debugPrint("Bluetooth scan status: $bluetoothScanStatus");

      PermissionStatus bluetoothConnectStatus =
          await Permission.bluetoothConnect.request();
      debugPrint("Bluetooth connect status: $bluetoothConnectStatus");

      // If any permission is permanently denied, show settings dialog
      if (bluetoothStatus.isPermanentlyDenied ||
          bluetoothScanStatus.isPermanentlyDenied ||
          bluetoothConnectStatus.isPermanentlyDenied) {
        // Show dialog to open settings
        final bool shouldOpenSettings = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Bluetooth Permission Required'),
                content: const Text(
                    'Bluetooth permission is required to connect with your Friend Wearable. '
                    'Please enable it in Settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldOpenSettings) {
          await openAppSettings();
        }
        return false;
      }

      // Return true only if all permissions are granted
      return bluetoothStatus.isGranted &&
          bluetoothScanStatus.isGranted &&
          bluetoothConnectStatus.isGranted;
    }

    return true;
  }
}
