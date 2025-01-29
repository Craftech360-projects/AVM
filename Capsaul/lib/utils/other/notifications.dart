import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:capsaul/backend/notify_on_kill.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/main.dart';
import 'package:capsaul/pages/home/page.dart';
import 'package:flutter/material.dart';

// could install the latest version due to podfile issues, so installed 0.8.3
// https://pub.dev/packages/awesome_notifications/versions/0.8.3

Future<void> initializeNotifications() async {
  // ignore: unused_local_variable
  bool initialized = await AwesomeNotifications().initialize(
      'resource://drawable/ic_stat_launcher',
      [
        NotificationChannel(
            channelGroupKey: 'channel_group_key',
            channelKey: 'channel',
            channelName: 'Capsaul Notifications',
            channelDescription: 'Notification channel for Capsaul',
            defaultColor: AppColors.purpleDark,
            ledColor: AppColors.commonPink)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'channel_group_key',
            channelGroupName: 'Capsaul Notifications')
      ],
      debug: false);
  NotifyOnKill.register();
}

Future<void> requestNotificationPermissions() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    // This is just a basic example. For real apps, you must show some
    // friendly dialog box before call the request method.
    // This is very important to not harm the user experience
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

_retrieveNotificationInterval({
  bool isMorningNotification = false,
  bool isDailySummaryNotification = false,
}) async {
  NotificationCalendar? interval;
  // allow people to set a notification time in settings
  if (isMorningNotification) {
    var scheduled = await AwesomeNotifications().listScheduledNotifications();
    var hasMorningNotification =
        scheduled.any((element) => element.content?.id == 4);
    if (hasMorningNotification) return;
    interval = NotificationCalendar(
      hour: 8,
      minute: 0,
      second: 0,
      repeats: true,
      preciseAlarm: false,
      allowWhileIdle: true,
    );
  } else if (isDailySummaryNotification) {
    var scheduled = await AwesomeNotifications().listScheduledNotifications();
    var hasDailySummaryNotification =
        scheduled.any((element) => element.content?.id == 5);
    if (hasDailySummaryNotification) return;
    interval = NotificationCalendar(
      hour: 20,
      minute: 0,
      second: 0,
      repeats: true,
      preciseAlarm: false,
      allowWhileIdle: false,
    );
  }
  return interval;
}

void createNotification({
  String title = '',
  String body = '',
  int notificationId = 1,
  Map<String, String?>? payload,
  bool isMorningNotification = false,
  bool isDailySummaryNotification = false,
}) async {
  var allowed = await AwesomeNotifications().isNotificationAllowed();
  if (!allowed) return;
  NotificationCalendar? interval = await _retrieveNotificationInterval(
    isMorningNotification: isMorningNotification,
    isDailySummaryNotification: isDailySummaryNotification,
  );
  if (interval == null &&
      (isMorningNotification || isDailySummaryNotification)) {
    return;
  }

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: notificationId,
      channelKey: 'channel',
      actionType: ActionType.Default,
      title: title,
      body: body,
      wakeUpScreen: true,
      payload: payload,
    ),
    schedule: interval,
  );
}

clearNotification(int id) => AwesomeNotifications().cancel(id);
void createMessagingNotification(String sender, String message) async {
  bool allowed = await AwesomeNotifications().isNotificationAllowed();
  if (!allowed) {
    log('Notifications are not allowed.');
    return;
  }

  // ✅ Ensure emojis are properly encoded
  String fixedMessage = message.replaceAllMapped(
      RegExp(r'[\uD800-\uDFFF]'), (match) => match.group(0) ?? '');

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 2,
      channelKey: 'channel',
      title: sender,
      body: fixedMessage, // ✅ Use the fixed message
      notificationLayout: NotificationLayout.Messaging,
      largeIcon: 'resource://drawable/ic_stat_launcher',
      payload: {
        'sender': sender,
        'message': fixedMessage,
      },
    ),
    actionButtons: [
      // NotificationActionButton(
      //   key: 'REPLY',
      //   label: 'Reply',
      //   autoDismissible: true,
      //   requireInputText: true, // Allow the user to input text for replies
      // ),
      // NotificationActionButton(
      //   key: 'MARK_AS_READ',
      //   label: 'Mark as Read',
      //   autoDismissible: true,
      // ),
    ],
  );
}

class NotificationUtil {
  static ReceivePort? receivePort;

  static Future<void> initializeNotificationsEventListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationUtil.onActionReceivedMethod);
  }

  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate');
    receivePort!.listen((serializedData) {
      final receivedAction = ReceivedAction().fromMap(serializedData);
      onActionReceivedMethodImpl(receivedAction);
    });

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivePort != null) {
      await onActionReceivedMethodImpl(receivedAction);
    } else {
      SendPort? sendPort =
          IsolateNameServer.lookupPortByName('notification_action_port');

      if (sendPort != null) {
        dynamic serializedData = receivedAction.toMap();
        sendPort.send(serializedData);
      }
    }
  }

  static Future<void> onActionReceivedMethodImpl(
      ReceivedAction receivedAction) async {
    final Map<String, int> screensWithRespectToPath = {
      '/chat': 2,
      '/capture': 1,
      '/memories': 0,
    };

    WidgetsFlutterBinding.ensureInitialized();

    if (receivedAction.buttonKeyPressed == 'REPLY') {
      // ignore: unused_local_variable
      String? userReply = receivedAction.buttonKeyInput;
      // Add logic to send the user's reply to the server or process it
    } else if (receivedAction.buttonKeyPressed == 'MARK_AS_READ') {
      log('Message marked as read');
    }

    final payload = receivedAction.payload;
    if (payload?.containsKey('navigateTo') ?? false) {
      SharedPreferencesUtil().subPageToShowFromNotification =
          payload?['navigateTo'] ?? '';
    }
    SharedPreferencesUtil().pageToShowFromNotification =
        screensWithRespectToPath[payload?['path']] ?? 1;
    MyApp.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePageWrapper()));
  }
}
