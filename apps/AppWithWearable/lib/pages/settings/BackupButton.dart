import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/utils/features/backups.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(BuildContext context) async {
  var status = await Permission.storage.status;
  print(status.isGranted);
  if (status.isGranted) {
    // Permission is already granted
    return true;
  } else if (status.isDenied) {
    // Request permission
    status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      // Permission is permanently denied, guide the user to settings
      _showPermissionDeniedDialog(context);
      return false;
    }
  }
  return false;
}

void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Permission Required"),
        content: Text(
            "Storage permission is required to access files. Please enable it in the app settings."),
        actions: <Widget>[
          TextButton(
            child: Text("Settings"),
            onPressed: () {
              openAppSettings(); // Redirect to app settings
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

class BackupButton extends StatefulWidget {
  const BackupButton({Key? key}) : super(key: key);

  @override
  _BackupButtonState createState() => _BackupButtonState();
}

class _BackupButtonState extends State<BackupButton> {
  bool backupsEnabled = SharedPreferencesUtil().backupsEnabled;
  bool isManualBackupInProgress = false;
  bool isRestoreInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Automatic Backup Switch
        ListTile(
          title: const Text('Automatic Backups',
              style: TextStyle(color: Colors.white)),
          subtitle: backupsEnabled
              ? const Text('Backups are enabled')
              : const Text('Backups are disabled'),
          trailing: Switch(
            value: backupsEnabled,
            onChanged: (bool value) {
              setState(() {
                if (backupsEnabled) {
                  _showDisableBackupDialog(context);
                } else {
                  _enableBackups();
                }
              });
            },
          ),
        ),

        // Manual Backup Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.backup),
            label: const Text('Manual Backup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPressed: backupsEnabled
                ? _manualBackup
                : null, // Disable button if backups are disabled
          ),
        ),

        if (isManualBackupInProgress)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Manual Backup in progress...',
                style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  void _showDisableBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Disable Automatic Backups'),
        content: const Text(
            'You will be responsible for backing up your own data. We will not be able to restore it automatically once you disable this feature. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                backupsEnabled = false;
                SharedPreferencesUtil().backupsEnabled = false;
                MixpanelManager().backupsDisabled();
                deleteBackupApi();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _enableBackups() {
    setState(() {
      backupsEnabled = true;
      SharedPreferencesUtil().backupsEnabled = true;

      executeBackupWithUid();
    });
  }

  void _manualBackup() async {
    setState(() => isManualBackupInProgress = true);

    try {
      // Call your backup API or method here
      //  await executeManualBackupWithUid(); // Replace this with your backup method
    } catch (error) {
      // Handle error (e.g., show a snackbar or alert)
      print('Manual backup failed: $error');
    } finally {
      setState(() => isManualBackupInProgress = false);
    }
  }
}
