// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart'
//     as permissionHandler;
// import 'package:location/location.dart' as locationHandler;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

// class PermissionsService {
//   // Method to request Notification Permission
//   static Future<bool> requestNotificationPermission(
//       BuildContext context) async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) {
//       bool userResponse = await _showPermissionRequestDialog(
//         context,
//         title: 'Notification Permission',
//         message:
//             'Please allow notifications to stay updated with important alerts.',
//       );
//       if (userResponse) {
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//         isAllowed = await AwesomeNotifications().isNotificationAllowed();
//       }
//     }
//     return isAllowed;
//   }

//   // Method to request Location Permission
//   static Future<bool> requestLocationPermission(BuildContext context) async {
//     locationHandler.Location location = locationHandler.Location();

//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       bool userResponse = await _showPermissionRequestDialog(
//         context,
//         title: 'Location Permission',
//         message:
//             'This app needs access to your location to tag memories with location data.',
//       );
//       if (userResponse) {
//         serviceEnabled = await location.requestService();
//         if (!serviceEnabled) {
//           _showPermissionDeniedDialog(context, 'Location Service Disabled',
//               'Please enable location services in your settings for a better experience.');
//           return false;
//         }
//       } else {
//         return false;
//       }
//     }

//     locationHandler.PermissionStatus permissionStatus =
//         await location.hasPermission();
//     if (permissionStatus == locationHandler.PermissionStatus.denied ||
//         permissionStatus == locationHandler.PermissionStatus.deniedForever) {
//       bool userResponse = await _showPermissionRequestDialog(
//         context,
//         title: 'Location Permission',
//         message:
//             'Location permission is needed to tag memories with their location. This can help you remember where they happened.',
//       );
//       if (userResponse) {
//         permissionStatus = await location.requestPermission();
//         if (permissionStatus ==
//             locationHandler.PermissionStatus.deniedForever) {
//           _showPermissionDeniedDialog(context, 'Location Permission Denied',
//               'Location permissions are denied permanently. Please enable them in settings.');
//           return false;
//         } else if (permissionStatus ==
//             locationHandler.PermissionStatus.denied) {
//           return false;
//         }
//       } else {
//         return false;
//       }
//     }

//     return permissionStatus == locationHandler.PermissionStatus.granted;
//   }

//   // Method to request Bluetooth Permissions (Android 12+)
//   static Future<bool> requestBluetoothPermission(BuildContext context) async {
//     if (Platform.isAndroid || Platform.isIOS) {
//       bool userResponse = await _showPermissionRequestDialog(
//         context,
//         title: 'Bluetooth Permission',
//         message:
//             'Bluetooth access is needed to connect with nearby devices for data collection and sharing.',
//       );
//       if (!userResponse) return false;

//       // Request Bluetooth Scan permission
//       permissionHandler.PermissionStatus bluetoothScanStatus =
//           await permissionHandler.Permission.bluetoothScan.request();
//       if (bluetoothScanStatus.isDenied ||
//           bluetoothScanStatus.isPermanentlyDenied) {
//         _showPermissionDeniedDialog(
//             context,
//             'Bluetooth Scan Permission Required',
//             'Please enable Bluetooth Scan permission for device discovery.');
//         return false;
//       }

//       // Request Bluetooth Connect permission
//       permissionHandler.PermissionStatus bluetoothConnectStatus =
//           await permissionHandler.Permission.bluetoothConnect.request();
//       if (bluetoothConnectStatus.isDenied ||
//           bluetoothConnectStatus.isPermanentlyDenied) {
//         _showPermissionDeniedDialog(
//             context,
//             'Bluetooth Connect Permission Required',
//             'Please enable Bluetooth Connect permission for connecting to devices.');
//         return false;
//       }

//       // Request Bluetooth Advertise permission (if needed)
//       permissionHandler.PermissionStatus bluetoothAdvertiseStatus =
//           await permissionHandler.Permission.bluetoothAdvertise.request();
//       if (bluetoothAdvertiseStatus.isDenied ||
//           bluetoothAdvertiseStatus.isPermanentlyDenied) {
//         _showPermissionDeniedDialog(
//             context,
//             'Bluetooth Advertise Permission Required',
//             'Please enable Bluetooth Advertise permission for device communication.');
//         return false;
//       }
//     }
//     return true;
//   }

//   // Method to check Internet Connection (no explicit user permission needed)
//   static Future<bool> checkInternetConnection(BuildContext context) async {
//     try {
//       final connectivity = await Connectivity().checkConnectivity();
//       if (connectivity == ConnectivityResult.none) {
//         _showPermissionDeniedDialog(context, 'No Internet Connection',
//             'Please check your internet connection and try again.');
//         return false;
//       }
//       return true;
//     } catch (e) {
//       _showPermissionDeniedDialog(context, 'Connection Error',
//           'Unable to check internet connection. Please try again.');
//       return false;
//     }
//   }

//   // Utility method to show a permission request dialog
//   static Future<bool> _showPermissionRequestDialog(BuildContext context,
//       {required String title, required String message}) async {
//     bool userResponse = false;
//     await showDialog(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               userResponse = false;
//               Navigator.of(c).pop();
//             },
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () {
//               userResponse = true;
//               Navigator.of(c).pop();
//             },
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     return userResponse;
//   }

//   // Utility method to show permission-denied dialogs
//   static void _showPermissionDeniedDialog(
//       BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(c).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler;
import 'package:location/location.dart' as locationHandler;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Method to request Notification Permission
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      bool userResponse = await _showPermissionRequestDialog(
        context,
        title: 'Notification Permission',
        message:
            'Please allow notifications to stay updated with important alerts.',
      );
      if (userResponse) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
        isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (isAllowed) {
          // Mark the permission as requested
          SharedPreferencesUtil().notificationPermissionRequested = true;
        }
      }
    }
    return isAllowed;
  }

  // Method to request Location Permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
    locationHandler.Location location = locationHandler.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      bool userResponse = await _showPermissionRequestDialog(
        context,
        title: 'Location Permission',
        message:
            'This app needs access to your location to tag memories with location data.',
      );
      if (userResponse) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showPermissionDeniedDialog(context, 'Location Service Disabled',
              'Please enable location services in your settings for a better experience.');
          return false;
        }
      } else {
        return false;
      }
    }

    locationHandler.PermissionStatus permissionStatus =
        await location.hasPermission();
    if (permissionStatus == locationHandler.PermissionStatus.denied ||
        permissionStatus == locationHandler.PermissionStatus.deniedForever) {
      bool userResponse = await _showPermissionRequestDialog(
        context,
        title: 'Location Permission',
        message:
            'Location permission is needed to tag memories with their location. This can help you remember where they happened.',
      );
      if (userResponse) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus ==
            locationHandler.PermissionStatus.deniedForever) {
          _showPermissionDeniedDialog(context, 'Location Permission Denied',
              'Location permissions are denied permanently. Please enable them in settings.');
          return false;
        } else if (permissionStatus ==
            locationHandler.PermissionStatus.denied) {
          return false;
        }
      } else {
        return false;
      }
    }

    // Mark the permission as requested
    SharedPreferencesUtil().locationPermissionRequested = true;

    return permissionStatus == locationHandler.PermissionStatus.granted;
  }

  // Method to request Bluetooth Permissions (Android 12+)
  // static Future<bool> requestBluetoothPermission(BuildContext context) async {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     bool userResponse = await _showPermissionRequestDialog(
  //       context,
  //       title: 'Bluetooth Permission',
  //       message:
  //           'Bluetooth access is needed to connect with nearby devices for data collection and sharing.',
  //     );
  //     if (!userResponse) return false;

  //     // Request Bluetooth Scan permission
  //     permissionHandler.PermissionStatus bluetoothScanStatus =
  //         await permissionHandler.Permission.bluetoothScan.request();
  //     if (bluetoothScanStatus.isDenied ||
  //         bluetoothScanStatus.isPermanentlyDenied) {
  //       _showPermissionDeniedDialog(
  //           context,
  //           'Bluetooth Scan Permission Required',
  //           'Please enable Bluetooth Scan permission for device discovery.');
  //       return false;
  //     }

  //     // Request Bluetooth Connect permission
  //     permissionHandler.PermissionStatus bluetoothConnectStatus =
  //         await permissionHandler.Permission.bluetoothConnect.request();
  //     if (bluetoothConnectStatus.isDenied ||
  //         bluetoothConnectStatus.isPermanentlyDenied) {
  //       _showPermissionDeniedDialog(
  //           context,
  //           'Bluetooth Connect Permission Required',
  //           'Please enable Bluetooth Connect permission for connecting to devices.');
  //       return false;
  //     }

  //     // Request Bluetooth Advertise permission (if needed)
  //     permissionHandler.PermissionStatus bluetoothAdvertiseStatus =
  //         await permissionHandler.Permission.bluetoothAdvertise.request();
  //     if (bluetoothAdvertiseStatus.isDenied ||
  //         bluetoothAdvertiseStatus.isPermanentlyDenied) {
  //       _showPermissionDeniedDialog(
  //           context,
  //           'Bluetooth Advertise Permission Required',
  //           'Please enable Bluetooth Advertise permission for device communication.');
  //       return false;
  //     }

  //     // Mark the permission as requested
  //     SharedPreferencesUtil().bluetoothPermissionRequested = true;
  //   }
  //   return true;
  // }
  static Future<bool> requestBluetoothPermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      bool userResponse = await _showPermissionRequestDialog(
        context,
        title: 'Bluetooth Permission',
        message:
            'Bluetooth access is needed to connect with nearby devices for data collection and sharing.',
      );
      if (!userResponse) return false;
      PermissionStatus status = await Permission.bluetoothScan.request();

      if (status.isDenied) {
        log("denied");
        // Show a dialog or guide the user to the settings
      } // Request Bluetooth Scan permission
      // permissionHandler.PermissionStatus bluetoothScanStatus =
      //     await permissionHandler.Permission.bluetoothScan.request();
      // if (bluetoothScanStatus.isDenied ||
      //     bluetoothScanStatus.isPermanentlyDenied) {
      //   _showPermissionDeniedDialog(
      //       context,
      //       'Bluetooth Scan Permission Required',
      //       'Please enable Bluetooth Scan permission for device discovery.');
      //   return false;
      // }
      try {
        permissionHandler.PermissionStatus bluetoothScanStatus =
            await permissionHandler.Permission.bluetoothScan.request();

        if (bluetoothScanStatus.isDenied ||
            bluetoothScanStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog(
              context,
              'Bluetooth Scan Permission Required',
              'Please enable Bluetooth Scan permission for device discovery.');
          return false;
        }
      } catch (e) {
        // Catch any error that may occur during the permission request
        _showPermissionDeniedDialog(context, 'Error Occurred',
            'An error occurred while requesting Bluetooth Scan permission. Please try again.');
        print(
            'Error requesting Bluetooth Scan permission: $e'); // Optionally log the error
        return false;
      }

      // Request Bluetooth Connect permission
      permissionHandler.PermissionStatus bluetoothConnectStatus =
          await permissionHandler.Permission.bluetoothConnect.request();
      if (bluetoothConnectStatus.isDenied ||
          bluetoothConnectStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
            context,
            'Bluetooth Connect Permission Required',
            'Please enable Bluetooth Connect permission for connecting to devices.');
        return false;
      }

      // Request Bluetooth Advertise permission (if needed)
      permissionHandler.PermissionStatus bluetoothAdvertiseStatus =
          await permissionHandler.Permission.bluetoothAdvertise.request();
      if (bluetoothAdvertiseStatus.isDenied ||
          bluetoothAdvertiseStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
            context,
            'Bluetooth Advertise Permission Required',
            'Please enable Bluetooth Advertise permission for device communication.');
        return false;
      }

      // Mark the permission as requested
      SharedPreferencesUtil().bluetoothPermissionRequested = true;
    }
    return true;
  }

  // Method to check Internet Connection (no explicit user permission needed)
  static Future<bool> checkInternetConnection(BuildContext context) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        _showPermissionDeniedDialog(context, 'No Internet Connection',
            'Please check your internet connection and try again.');
        return false;
      }
      return true;
    } catch (e) {
      _showPermissionDeniedDialog(context, 'Connection Error',
          'Unable to check internet connection. Please try again.');
      return false;
    }
  }

  // Utility method to show a permission request dialog
  static Future<bool> _showPermissionRequestDialog(BuildContext context,
      {required String title, required String message}) async {
    bool userResponse = false;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              userResponse = false;
              Navigator.of(c).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              userResponse = true;
              Navigator.of(c).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return userResponse;
  }

  // Utility method to show permission-denied dialogs
  static void _showPermissionDeniedDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
