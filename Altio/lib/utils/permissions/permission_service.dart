import 'dart:io';

import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:altio/backend/preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_handler;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      if (!context.mounted) return false;
      bool userResponse = await customDialogBox(
        context,
        icon: Icons.notifications_rounded,
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

  static Future<bool> requestLocationPermission(BuildContext context) async {
    location_handler.Location location = location_handler.Location();

    // Check if location services are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
       if(!context.mounted) return false;
      bool userResponse = await customDialogBox(
        context,
        icon: Icons.location_on_rounded,
        title: 'Enable Location Services',
        message:
            'This app requires location services to be enabled to tag your memories with location data. Please turn on location services to continue.',
      );
      if (userResponse) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (context.mounted) {
            showPermissionDeniedDialog(context, 'Location Service Disabled',
                'Please enable location services in your settings for a better experience.');
          }
          return false;
        }
      } else {
        return false;
      }
    }

    // Check location permission status
    location_handler.PermissionStatus permissionStatus =
        await location.hasPermission();

    if (permissionStatus == location_handler.PermissionStatus.denied ||
        permissionStatus == location_handler.PermissionStatus.deniedForever) {
      // Prominent Disclosure BEFORE requesting permission
       if(!context.mounted) return false;
      bool userResponse = await customDialogBox(
        context,
        icon: Icons.location_on_rounded,
        title: 'Location Permission Required 🌍',
        message:
            'This app collects location data to tag memories with their location, even when the app is closed or not in use. This helps in remembering where your memories happened. Do you want to continue?',
      );

      if (userResponse) {
        permissionStatus = await location.requestPermission();

        if (permissionStatus ==
            location_handler.PermissionStatus.deniedForever) {
          if (context.mounted) {
            showPermissionDeniedDialog(context, 'Location Permission Denied',
                'Location permissions are denied permanently. Please enable them in settings.');
          }
          return false;
        } else if (permissionStatus ==
            location_handler.PermissionStatus.denied) {
          return false;
        }
      } else {
        return false;
      }
    }

    // Request Background Location Permission if Foreground Permission is granted
    if (permissionStatus == location_handler.PermissionStatus.granted) {
       if(!context.mounted) return false;
      bool backgroundUserResponse = await customDialogBox(
        context,
        icon: Icons.location_on_rounded,
        title: 'Allow Background Location?',
        message:
            'To ensure your memories are tagged accurately, we need access to your location even when the app is closed or not in use. This helps us associate locations even when you are not actively using the app. Would you like to enable background location access?',
      );

      if (backgroundUserResponse) {
        // Request Background Location Permission
        permissionStatus = await location.requestPermission();
      }
    }

    // Mark the permission as requested
    SharedPreferencesUtil().locationPermissionRequested = true;

    return permissionStatus == location_handler.PermissionStatus.granted;
  }

  static Future<bool> requestBluetoothPermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      bool userResponse = await customDialogBox(
        context,
        icon: Icons.bluetooth,
        title: 'Bluetooth Permission',
        message:
            'Bluetooth access is needed to connect with nearby devices for data collection and sharing.',
      );
      if (!userResponse) return false;

      try {
        permission_handler.PermissionStatus bluetoothScanStatus =
            await permission_handler.Permission.bluetoothScan.request();
        if (bluetoothScanStatus.isDenied ||
            bluetoothScanStatus.isPermanentlyDenied) {
          if (context.mounted) {
            showPermissionDeniedDialog(
              context,
              'Bluetooth Scan Permission Required',
              'Please enable Bluetooth Scan permission for device discovery.',
            );
          }
          return false;
        }

        permission_handler.PermissionStatus bluetoothConnectStatus =
            await permission_handler.Permission.bluetoothConnect.request();
        if (bluetoothConnectStatus.isDenied ||
            bluetoothConnectStatus.isPermanentlyDenied) {
          if (context.mounted) {
            showPermissionDeniedDialog(
              context,
              'Bluetooth Connect Permission Required',
              'Please enable Bluetooth Connect permission for connecting to devices.',
            );
          }
          return false;
        }

        permission_handler.PermissionStatus bluetoothAdvertiseStatus =
            await permission_handler.Permission.bluetoothAdvertise.request();
        if (bluetoothAdvertiseStatus.isDenied ||
            bluetoothAdvertiseStatus.isPermanentlyDenied) {
          if (context.mounted) {
            showPermissionDeniedDialog(
              context,
              'Bluetooth Advertise Permission Required',
              'Please enable Bluetooth Advertise permission for device communication.',
            );
          }
          return false;
        }

        // Mark the permission as requested
        SharedPreferencesUtil().bluetoothPermissionRequested = true;
      } catch (e) {
        if (context.mounted) {
          showPermissionDeniedDialog(
            context,
            'Error Occurred',
            'An error occurred while requesting Bluetooth Scan permission. Please try again.',
          );
        }
        return false;
      }
    }
    return true;
  }

  static Future<bool> checkInternetConnection(BuildContext context) async {
    try {
      final List<ConnectivityResult> connectivity =
          await Connectivity().checkConnectivity();

      // Check if the list contains ConnectivityResult.none or is empty
      if (connectivity.isEmpty ||
          connectivity.contains(ConnectivityResult.none)) {
        if (context.mounted) {
          showPermissionDeniedDialog(
            context,
            'No Internet Connection',
            'Please check your internet connection and try again.',
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        showPermissionDeniedDialog(
          context,
          'Connection Error',
          'Unable to check internet connection. Please try again.',
        );
      }
      return false;
    }
  }
}
