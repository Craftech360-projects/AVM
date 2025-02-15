import 'dart:developer';

import 'package:flutter/services.dart';

class NotifyOnKill {
  static const platform = MethodChannel('com.craftech360.avm/notifyOnKill');

  static Future<void> register() async {
    try {
      await platform.invokeMethod(
        'setNotificationOnKillService',
        {
          'title': "Capsaul was disconnected",
          'description': "Please keep your app open to continue using Capsaul",
        },
      );
    } on Exception catch (e) {
      log('NotifOnKill error: $e');
    }
  }
}
