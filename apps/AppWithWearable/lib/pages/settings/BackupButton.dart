import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/src/core/constant/constant.dart';
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
        title: const Text("Permission Required"),
        content: const Text(
            "Storage permission is required to access files. Please enable it in the app settings."),
        actions: <Widget>[
          TextButton(
            child: const Text("Settings"),
            onPressed: () {
              openAppSettings(); // Redirect to app settings
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text("Cancel"),
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
  const BackupButton({super.key});

  @override
  State<BackupButton> createState() => _BackupButtonState();
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
          title: const Text('Backups & Restore',
              style: TextStyle(color: CustomColors.blackPrimary)),
          trailing: Switch(
            activeTrackColor: CustomColors.purpleDark,
            inactiveTrackColor: CustomColors.grey,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white,
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
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
          title: Text(
            'Manual Backup',
            style: TextStyle(
              color: backupsEnabled
                  ? CustomColors.blackPrimary
                  : CustomColors.greyLight,
            ),
          ),
          subtitle:
              backupsEnabled ? const Text('Enabled') : const Text('Disabled'),
          trailing: CircleAvatar(
            backgroundColor: backupsEnabled
                ? CustomColors.greyLavender
                : CustomColors.greyLight,
            child: Icon(
                color: backupsEnabled
                    ? CustomColors.blackPrimary
                    : CustomColors.greyMedium,
                Icons.backup,
                size: 22.h),
          ),
          //  Icon(
          //   Icons.backup,
          //   size: 22.h,
          //   color: backupsEnabled
          //       ? CustomColors.blackPrimary
          //       : CustomColors.greyLight,
          // ),
          onTap: backupsEnabled ? _manualBackup : null,
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: ElevatedButton.icon(
        //     icon: const Icon(Icons.backup),
        //     label: const Text('Manual Backup'),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.blue,
        //       textStyle: const TextStyle(color: Colors.white),
        //     ),
        //     onPressed: backupsEnabled
        //         ? _manualBackup
        //         : null, // Disable button if backups are disabled
        //   ),
        // ),

        if (isManualBackupInProgress)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Manual Backup in progress...',
                style: TextStyle(color: CustomColors.grey)),
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
            child: const Text('Cancel',
                style: TextStyle(
                  color: CustomColors.purpleBright,
                )),
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
            child: const Text('Disable',
                style: TextStyle(
                  color: CustomColors.grey,
                )),
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
      var uid = SharedPreferencesUtil().uid;
      // Call your backup API or method here
      await executeManualBackupWithUid(
          uid); // Replace this with your backup method
    } catch (error) {
      // Handle error (e.g., show a snackbar or alert)
      debugPrint('Manual backup failed: $error');
    } finally {
      setState(() => isManualBackupInProgress = false);
    }
  }
}
