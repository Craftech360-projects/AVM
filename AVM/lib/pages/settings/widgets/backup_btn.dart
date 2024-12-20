import 'package:avm/backend/api_requests/api/server.dart';
import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/utils/features/backups.dart';
import 'package:avm/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(BuildContext context) async {
  var status = await Permission.storage.status;
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
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
          title: const Text('Backups & Restore',
              style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: Switch(
            activeTrackColor: AppColors.purpleDark,
            inactiveTrackColor: AppColors.grey,
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
                color: backupsEnabled ? AppColors.black : AppColors.greyLight,
                fontWeight: FontWeight.w600),
          ),
          subtitle: backupsEnabled
              ? const Text(
                  'Enabled',
                  style: TextStyle(fontWeight: FontWeight.w500),
                )
              : const Text('Disabled',
                  style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: CircleAvatar(
            backgroundColor:
                backupsEnabled ? AppColors.greyLavender : AppColors.greyLight,
            child: Icon(
                color: backupsEnabled ? AppColors.black : AppColors.greyMedium,
                Icons.backup,
                size: 22.h),
          ),
          onTap: backupsEnabled ? _manualBackup : null,
        ),
        if (isManualBackupInProgress)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Manual Backup in progress...',
                style: TextStyle(
                    color: AppColors.grey, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  void _showDisableBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => CustomDialogWidget(
        icon: Icons.backup_rounded,
        title: "Disable Automatic Backups",
        message:
            "You will be responsible for backing up your own data. We will not be able to restore it automatically once you disable this feature. Are you sure?",
        yesPressed: () {
          setState(() {
            backupsEnabled = false;
            SharedPreferencesUtil().backupsEnabled = false;
            MixpanelManager().backupsDisabled();
            deleteBackupApi();
          });
          Navigator.of(context).pop();
        },
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
