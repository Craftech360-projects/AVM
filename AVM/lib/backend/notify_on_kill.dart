import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotifyOnKill {
  static const platform = MethodChannel('com.craftech360.avm/notifyOnKill');

  static Future<void> register() async {
    try {
      await platform.invokeMethod(
        'setNotificationOnKillService',
        {
          'title': "AVM Device Disconnected...",
          'description':
              "Please keep your app opened to continue using your AVM.",
        },
      );
    } catch (e) {
      debugPrint('NotifOnKill error: $e');
    }
  }
}
