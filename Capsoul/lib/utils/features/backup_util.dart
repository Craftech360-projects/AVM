import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/utils/features/backups.dart';
import 'package:flutter/material.dart';

Future<void> manualBackup(BuildContext context) async {
  // ignore: unused_local_variable
  bool isManualBackupInProgress = true;

  try {
    var uid = SharedPreferencesUtil().uid;
    // Call your backup API or method here
    await executeManualBackupWithUid(uid);
    print("backup sucess"); // Replace this with your backup method
  } catch (error) {
    // Handle error (e.g., show a snackbar or alert)
    debugPrint('Manual backup failed: $error');
  } finally {
    isManualBackupInProgress = false;
  }
}
