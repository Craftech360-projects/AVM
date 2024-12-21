
import 'package:shared_preferences/shared_preferences.dart';

// Method to fetch the latest value from SharedPreferences
Future<bool> getNotificationPluginValue() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notificationPlugin') ?? false;
}

// Usage example
void someFunction() async {
  bool notificationPluginValue = await getNotificationPluginValue();
  if (notificationPluginValue) {
    // Call _PluginNotification and _createMemory
  } else {
    // Handle the case where the value is false
  }
}