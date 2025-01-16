import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotifyOnKill {
  static const platform = MethodChannel('com.craftech360.avm/notifyOnKill');

  static Future<void> register() async {
    try {
      await platform.invokeMethod(
        'setNotificationOnKillService',
        {
          'title': "Capsoul was disconnected",
          'description':
              "Please keep your app open to continue using Capsoul.",
        },
      );
    } catch (e) {
      debugPrint('NotifOnKill error: $e');
    }
  }
}
