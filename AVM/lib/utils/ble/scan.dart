import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/utils/ble/connect.dart';
import 'package:avm/utils/ble/find.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Future<BTDeviceStruct?> scanAndConnectDevice(
//     {bool autoConnect = true, bool timeout = false}) async {
//   debugPrint('scanAndConnectDevice');
//   var deviceId = SharedPreferencesUtil().deviceId;
//   debugPrint('scanAndConnectDevice $deviceId');
//   for (var device in FlutterBluePlus.connectedDevices) {
//     if (device.remoteId.str == deviceId) {
//       return BTDeviceStruct(
//         id: device.remoteId.str,
//         name: device.platformName,
//         rssi: await device.readRssi(),
//       );
//     }
//   }
//   int timeoutCounter = 0;
//   while (true) {
//     if (timeout && timeoutCounter >= 10) return null;
//     List<BTDeviceStruct> foundDevices = await bleFindDevices();
//     for (BTDeviceStruct device in foundDevices) {
//       // Remember the first connected device.
//       // Technically, there should be only one
//       if (deviceId == '') {
//         deviceId = device.id;
//         SharedPreferencesUtil().deviceId = device.id;
//         SharedPreferencesUtil().deviceName = device.name;
//       }

//       if (device.id == deviceId) {
//         try {
//           await bleConnectDevice(device.id, autoConnect: autoConnect);
//           return device;
//         } catch (e) {
//           debugPrint(e.toString());
//         }
//       }
//     }
//     // If the device is not found, wait for a bit before retrying.
//     await Future.delayed(const Duration(seconds: 2));
//     timeoutCounter += 2;
//   }
// }

Future<BTDeviceStruct?> scanAndConnectDevice(
    {bool autoConnect = true, bool timeout = false}) async {
  debugPrint('scanAndConnectDevice');
  var deviceId = SharedPreferencesUtil().deviceId;
  debugPrint('scanAndConnectDevice $deviceId');

  try {
    // First check already connected devices
    for (var device in FlutterBluePlus.connectedDevices) {
      if (device.remoteId.str == deviceId) {
        return BTDeviceStruct(
          id: device.remoteId.str,
          name: device.platformName,
          rssi: await device.readRssi(),
        );
      }
    }

    // Check if Bluetooth is available and on
    if (!await FlutterBluePlus.isAvailable) {
      debugPrint('Bluetooth is not available');
      return null;
    }

    // Stop any ongoing scan
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }

    int timeoutCounter = 0;
    const maxTimeout = 10; // 10 * 2 seconds = 20 seconds total timeout

    while (true) {
      if (timeout && timeoutCounter >= maxTimeout) {
        debugPrint('Scan timeout reached');
        return null;
      }

      try {
        List<BTDeviceStruct> foundDevices = await bleFindDevices();

        // Handle case when no device ID is saved
        if (deviceId.isEmpty && foundDevices.isNotEmpty) {
          var firstDevice = foundDevices.first;
          deviceId = firstDevice.id;
          SharedPreferencesUtil().deviceId = firstDevice.id;
          SharedPreferencesUtil().deviceName = firstDevice.name;
        }

        // Look for matching device
        for (BTDeviceStruct device in foundDevices) {
          if (device.id == deviceId) {
            try {
              await bleConnectDevice(device.id, autoConnect: autoConnect);
              return device;
            } catch (e) {
              debugPrint('Connection error: $e');
              // If connection fails, continue scanning
              continue;
            }
          }
        }

        // If device not found in this scan, wait before next attempt
        await Future.delayed(const Duration(seconds: 2));
        timeoutCounter += 2;
      } catch (e) {
        debugPrint('Scan error: $e');

        // If scanning fails, wait a bit before retrying
        await Future.delayed(const Duration(seconds: 1));
        timeoutCounter += 1;

        // Stop if timeout reached
        if (timeout && timeoutCounter >= maxTimeout) {
          return null;
        }
      }
    }
  } catch (e) {
    debugPrint('Fatal error in scanAndConnectDevice: $e');
    return null;
  } finally {
    // Ensure scan is stopped when we exit
    try {
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }
}
