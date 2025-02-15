import 'dart:developer';

import 'package:altio/backend/preferences.dart';
import 'package:altio/utils/features/backups.dart';
import 'package:flutter/material.dart';

Future<void> manualBackup(BuildContext context) async {
  // ignore: unused_local_variable
  bool isManualBackupInProgress = true;

  try {
    var uid = SharedPreferencesUtil().uid;
    // Call your backup API or method here
    await executeManualBackupWithUid(uid);
    log("backup sucess");
  } on Exception catch (error) {
    log("backup failed: $error");
  } finally {
    isManualBackupInProgress = false;
  }
}
