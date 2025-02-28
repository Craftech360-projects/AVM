import 'dart:io';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  int _eventCount = 0;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    print("Foreground task started at $timestamp");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    //print("Repeat event: $_eventCount");
    sendPort?.send(_eventCount); // Send data to main isolate
    await Future.delayed(const Duration(seconds: 1));
    _eventCount++;
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print("Foreground task destroyed at $timestamp");
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print("Notification button pressed: $id");
  }

  // Called when the notification itself on the Android platform is pressed.
  // Requires "android.permission.SYSTEM_ALERT_WINDOW" permission.
  @override
  void onNotificationPressed() {
    print("Notification pressed, launching app");
    FlutterForegroundTask.launchApp("/resume-route");
  }
}

class ForegroundUtil {
  ReceivePort? _receivePort;

  Future<void> requestPermissionForAndroid() async {
    if (!Platform.isAndroid) return;
    try {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        print("Requesting battery optimization ignore");
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
      final NotificationPermission status =
          await FlutterForegroundTask.checkNotificationPermission();
      if (status != NotificationPermission.granted) {
        print("Requesting notification permission");
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

  Future<void> initForegroundTask() async {
    if (await FlutterForegroundTask.isRunningService) {
      print("Foreground service already running, skipping init");
      return;
    }
    try {
      print("Initializing foreground task");
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service',
          channelName: 'Foreground Service Notification',
          channelDescription: 'Your Capsaul is connected',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.HIGH,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000, // 5 seconds
          isOnceEvent: false,
          autoRunOnBoot: false,
          allowWakeLock: false,
          allowWifiLock: false,
        ),
      );
      print("Foreground task initialized successfully");
    } catch (e) {
      print("Error initializing foreground task: $e");
      rethrow; // Rethrow to handle the error upstream if needed
    }
  }

  Future<bool> startForegroundTask() async {
    try {
      final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
      final bool isRegistered = _registerReceivePort(receivePort);
      if (!isRegistered) {
        print("Failed to register receive port");
        return false;
      }

      if (await FlutterForegroundTask.isRunningService) {
        print("Restarting existing foreground service");
        return await FlutterForegroundTask.restartService();
      } else {
        print("Starting new foreground service");
        return await FlutterForegroundTask.startService(
          notificationTitle: 'Altio is active',
          notificationText: 'Tap to open the app',
          callback: startCallback,
        );
      }
    } catch (e) {
      print("Error starting foreground task: $e");
      return false;
    }
  }

  Future<void> stopForegroundTask() async {
    if (!Platform.isAndroid) return;
    try {
      print("Stopping foreground service");
      await FlutterForegroundTask.stopService();
      _closeReceivePort();
    } catch (e) {
      print("Error stopping foreground task: $e");
    }
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      print("Receive port is null");
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        print("Received event count: $data");
      } else if (data is String) {
        print("Received string data: $data");
        // Uncomment and adapt if navigation is needed:
        // if (data == 'onNotificationPressed') {
        //   Navigator.of(context).pushNamed('/resume-route');
        // }
      } else if (data is DateTime) {
        print("Received timestamp: $data");
      }
    });

    print("Receive port registered successfully");
    return _receivePort != null;
  }

  void _closeReceivePort() {
    if (_receivePort != null) {
      _receivePort?.close();
      _receivePort = null;
      print("Receive port closed");
    }
  }
}
