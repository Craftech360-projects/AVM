// import 'dart:developer';

// import 'package:altio/backend/auth.dart';
// import 'package:altio/backend/database/box.dart';
// import 'package:altio/backend/database/memory_provider.dart';
// import 'package:altio/backend/database/message_provider.dart';
// import 'package:altio/backend/database/profile_provider.dart';
// import 'package:altio/backend/growthbook.dart';
// import 'package:altio/backend/mixpanel.dart';
// import 'package:altio/backend/preferences.dart';
// import 'package:altio/backend/schema/plugin.dart';
// import 'package:altio/backend/services/device_flag.dart';
// import 'package:altio/core/theme/app_theme.dart';
// import 'package:altio/env/dev_env.dart';
// import 'package:altio/env/env.dart';
// import 'package:altio/env/prod_env.dart';
// import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
// import 'package:altio/features/chat/bloc/chat_bloc.dart';
// import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
// import 'package:altio/features/memories/bloc/memory_bloc.dart';
// import 'package:altio/firebase_options_dev.dart' as dev;
// import 'package:altio/firebase_options_prod.dart' as prod;
// import 'package:altio/flavors.dart';
// import 'package:altio/pages/splash/splash_screen.dart';
// import 'package:altio/utils/features/calendar.dart';
// import 'package:altio/utils/other/notifications.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:opus_dart/opus_dart.dart';
// import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
// import 'package:provider/provider.dart';

// void main() async {
//   if (F.env == Environment.prod) {
//     Env.init(ProdEnv());
//   } else {
//     Env.init(DevEnv());
//   }

//   WidgetsFlutterBinding.ensureInitialized();

//   await ble.FlutterBluePlus.setLogLevel(ble.LogLevel.info, color: true);
//   try {
//     if (F.env == Environment.prod) {
//       await Firebase.initializeApp(
//         options: prod.DefaultFirebaseOptions.currentPlatform,
//       );
//     } else {
//       await Firebase.initializeApp(
//         options: dev.DefaultFirebaseOptions.currentPlatform,
//       );
//     }

//     await initializeNotifications();
//     await SharedPreferencesUtil.init();
//     await ObjectBoxUtil.init();
//     await MixpanelManager.init();
//   } on Exception catch (e, stackTrace) {
//     log('Initialization failed: $e\n$stackTrace');
//   }

//   listenAuthTokenChanges();

//   bool isAuth = false;

//   try {
//     isAuth = (await getIdToken()) != null;
//   } on Exception catch (e) {
//     log(e.toString());
//   }

//   if (isAuth) MixpanelManager().identify();

//   try {
//     initOpus(await opus_flutter.load());
//     await GrowthbookUtil.init();
//     CalendarUtil.init();
//   } on Exception catch (e, stackTrace) {
//     log('Optional initialization failed: $e\n$stackTrace');
//   }

//   if (Env.oneSignalAppId != null) {
//     await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     OneSignal.initialize(Env.oneSignalAppId!);
//     await OneSignal.login(SharedPreferencesUtil().uid);
//   }

//   _getRunApp(isAuth);
// }

// // class NavbarState extends ChangeNotifier {
// //   bool _isExpanded = true;
// //   bool isChatVisible = true;
// //   bool isMemoryVisible = false;

// //   bool get isExpanded => _isExpanded;

// //   void setChatVisibility(bool value) {
// //     isChatVisible = value;
// //     notifyListeners();
// //   }

// //   void setMemoryVisibility(bool value) {
// //     isMemoryVisible = value;
// //     notifyListeners();
// //   }

// //   void expand() {
// //     _isExpanded = true;
// //     notifyListeners();
// //   }

// //   void collapse() {
// //     _isExpanded = false;
// //     isChatVisible = false;
// //     isMemoryVisible = false;
// //     notifyListeners();
// //   }
// // }

// _getRunApp(bool isAuth) {
//   return runApp(MyApp(isAuth: isAuth));
// }

// class MyApp extends StatefulWidget {
//   final bool isAuth;

//   const MyApp({super.key, required this.isAuth});

//   @override
//   State<MyApp> createState() => MyAppState();

//   static MyAppState of(BuildContext context) =>
//       context.findAncestorStateOfType<MyAppState>()!;

//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
// }

// class MyAppState extends State<MyApp> {
//   List<Plugin> plugins = [];

//   @override
//   void initState() {
//     super.initState();
//     NotificationUtil.initializeNotificationsEventListeners();
//     NotificationUtil.initializeIsolateReceivePort();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       builder: (context, child) {
//         return MultiBlocProvider(
//           providers: [
//             // ChangeNotifierProvider(create: (_) => WebSocketService()),
//             ChangeNotifierProvider(
//               create: (_) =>
//                   DeviceProvider(FirebaseAuth.instance.currentUser!.uid),
//             ),
//             BlocProvider(
//               create: (context) => MemoryBloc(),
//             ),
//             BlocProvider(
//               create: (context) => ChatBloc(
//                 SharedPreferencesUtil(),
//                 MessageProvider(),
//                 MemoryProvider(),
//               ),
//             ),
//             BlocProvider(
//               create: (_) => BluetoothBloc(),
//             ),
//             BlocProvider<ConnectivityBloc>(
//               create: (context) => ConnectivityBloc(),
//             ),
//             ChangeNotifierProvider(
//               create: (_) => ProfileProvider(),
//             ),
//           ],
//           child: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             title: F.title,
//             navigatorKey: MyApp.navigatorKey,
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [Locale('en')],
//             home: SplashScreen(
//               isAuth: widget.isAuth,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// with daily summary

// import 'dart:developer';

// import 'package:altio/backend/api_requests/api/prompt.dart';
// import 'package:altio/backend/auth.dart';
// import 'package:altio/backend/database/box.dart';
// import 'package:altio/backend/database/memory_provider.dart';
// import 'package:altio/backend/database/message.dart';
// import 'package:altio/backend/database/message_provider.dart';
// import 'package:altio/backend/database/profile_provider.dart';
// import 'package:altio/backend/growthbook.dart';
// import 'package:altio/backend/mixpanel.dart';
// import 'package:altio/backend/preferences.dart';
// import 'package:altio/backend/schema/plugin.dart';
// import 'package:altio/backend/services/device_flag.dart';
// import 'package:altio/core/theme/app_theme.dart';
// import 'package:altio/env/dev_env.dart';
// import 'package:altio/env/env.dart';
// import 'package:altio/env/prod_env.dart';
// import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
// import 'package:altio/features/chat/bloc/chat_bloc.dart';
// import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
// import 'package:altio/features/memories/bloc/memory_bloc.dart';
// import 'package:altio/firebase_options_dev.dart' as dev;
// import 'package:altio/firebase_options_prod.dart' as prod;
// import 'package:altio/flavors.dart';
// import 'package:altio/pages/splash/splash_screen.dart';
// import 'package:altio/utils/features/calendar.dart';
// import 'package:altio/utils/other/notifications.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:opus_dart/opus_dart.dart';
// import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
// import 'package:provider/provider.dart';
// import 'package:workmanager/workmanager.dart';

// // Workmanager callback dispatcher
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       log("Workmanager task started: $task at ${DateTime.now()}");
//       await SharedPreferencesUtil.init();
//       await ObjectBoxUtil.init();

//       final chatBloc = ChatBloc(
//         SharedPreferencesUtil(),
//         MessageProvider(),
//         MemoryProvider(),
//       );

//       await _runDailySummary(chatBloc, DateTime.now()); // Pass current date
//       log("Workmanager task completed: $task at ${DateTime.now()}");
//       return Future.value(true);
//     } catch (e, stackTrace) {
//       log('Workmanager task failed: $e\n$stackTrace');
//       return Future.value(false);
//     }
//   });
// }

// // Daily summary logic
// Future<void> _runDailySummary(ChatBloc chatBloc, DateTime targetDate) async {
//   log("Running Daily Summary for $targetDate");

//   final prefs = SharedPreferencesUtil();
//   final lastRunStr = prefs.lastDailySummaryDay;
//   final target8pm =
//       DateTime(targetDate.year, targetDate.month, targetDate.day, 20);

//   log("Last run: $lastRunStr, Target 8 PM: $target8pm");

//   if (lastRunStr.isNotEmpty) {
//     final lastRun = DateTime.parse(lastRunStr);
//     if (lastRun.isAfter(target8pm)) {
//       log("Skipping Daily Summary: Already ran after 8 PM for $targetDate");
//       return;
//     } else {
//       log("Last run was before 8 PM, proceeding with summary");
//     }
//   } else {
//     log("No previous run recorded, proceeding with summary");
//   }

//   final memories = MemoryProvider().retrieveDayMemories(targetDate);
//   log("Retrieved ${memories.length} memories for $targetDate");

//   if (memories.isEmpty) {
//     log("No memories found for $targetDate, marking as complete");
//     prefs.lastDailySummaryDay = target8pm.toIso8601String();
//     return;
//   }

//   log("Creating and saving summary message");
//   final message = Message(target8pm, '', 'ai', type: 'daySummary');
//   await MessageProvider().saveMessage(message);

//   log("Generating summary notification");
//   final result = await dailySummaryNotifications(memories);
//   prefs.lastDailySummaryDay = target8pm.toIso8601String();

//   log("Updating message with result: $result");
//   message.text = result;
//   message.memories.addAll(memories);
//   await MessageProvider().updateMessage(message);

//   log("Triggering UI refresh");
//   chatBloc.add(RefreshMessages());
// }

// void main() async {
//   if (F.env == Environment.prod) {
//     Env.init(ProdEnv());
//   } else {
//     Env.init(DevEnv());
//   }

//   WidgetsFlutterBinding.ensureInitialized();

//   await ble.FlutterBluePlus.setLogLevel(ble.LogLevel.info, color: true);
//   try {
//     if (F.env == Environment.prod) {
//       await Firebase.initializeApp(
//         options: prod.DefaultFirebaseOptions.currentPlatform,
//       );
//     } else {
//       await Firebase.initializeApp(
//         options: dev.DefaultFirebaseOptions.currentPlatform,
//       );
//     }

//     await initializeNotifications();
//     await SharedPreferencesUtil.init();
//     await ObjectBoxUtil.init();
//     await MixpanelManager.init();
//   } on Exception catch (e, stackTrace) {
//     log('Initialization failed: $e\n$stackTrace');
//   }

//   listenAuthTokenChanges();

//   bool isAuth = false;
//   try {
//     isAuth = (await getIdToken()) != null;
//   } on Exception catch (e) {
//     log(e.toString());
//   }

//   if (isAuth) MixpanelManager().identify();

//   try {
//     initOpus(await opus_flutter.load());
//     await GrowthbookUtil.init();
//     CalendarUtil.init();
//   } on Exception catch (e, stackTrace) {
//     log('Optional initialization failed: $e\n$stackTrace');
//   }

//   if (Env.oneSignalAppId != null) {
//     await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     OneSignal.initialize(Env.oneSignalAppId!);
//     await OneSignal.login(SharedPreferencesUtil().uid);
//   }

//   await _checkAndRunMissedSummary();
//   // Initialize Workmanager for daily summary
//   // Workmanager().initialize(callbackDispatcher, isInDebugMode: F.env != Environment.prod);
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
//   _scheduleDailySummary();

//   //for testing daily summary task immediately after app start (remove this line in production)

//   await Workmanager().registerOneOffTask(
//     "testDailySummary",
//     "dailySummaryTest",
//     initialDelay: const Duration(seconds: 15), // Runs 5 seconds after app start
//   );

//   _getRunApp(isAuth);
// }

// Future<void> _checkAndRunMissedSummary() async {
//   final prefs = SharedPreferencesUtil();
//   final now = DateTime.now();
//   final yesterday = now.subtract(const Duration(days: 1));
//   final yesterday8pm =
//       DateTime(yesterday.year, yesterday.month, yesterday.day, 20);

//   final lastRunStr = prefs.lastDailySummaryDay;

//   if (lastRunStr.isEmpty || DateTime.parse(lastRunStr).isBefore(yesterday8pm)) {
//     log("Detected missed summary for $yesterday");
//     final chatBloc = ChatBloc(
//       SharedPreferencesUtil(),
//       MessageProvider(),
//       MemoryProvider(),
//     );
//     await _runDailySummary(chatBloc, yesterday);
//     log("Completed catch-up summary for $yesterday");
//   } else {
//     log("No missed summary detected. Last run: $lastRunStr");
//   }
// }

// // Schedule the daily summary task
// void _scheduleDailySummary() {
//   Workmanager().registerPeriodicTask(
//     "dailySummaryTask",
//     "dailySummary",
//     frequency: const Duration(hours: 24),
//     initialDelay: _calculateInitialDelayTo8PM(),
//     constraints: Constraints(
//       networkType: NetworkType.connected, // Ensure network is available
//     ),
//     existingWorkPolicy:
//         ExistingWorkPolicy.keep, // Keep existing task if scheduled
//   );
// }

// Duration _calculateInitialDelayTo8PM() {
//   final now = DateTime.now();
//   final today8pm = DateTime(now.year, now.month, now.day, 20);
//   return today8pm.isAfter(now)
//       ? today8pm.difference(now)
//       : today8pm.add(const Duration(days: 1)).difference(now);
// }

// _getRunApp(bool isAuth) {
//   return runApp(MyApp(isAuth: isAuth));
// }

// class MyApp extends StatefulWidget {
//   final bool isAuth;

//   const MyApp({super.key, required this.isAuth});

//   @override
//   State<MyApp> createState() => MyAppState();

//   static MyAppState of(BuildContext context) =>
//       context.findAncestorStateOfType<MyAppState>()!;

//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
// }

// class MyAppState extends State<MyApp> {
//   List<Plugin> plugins = [];

//   @override
//   void initState() {
//     super.initState();
//     NotificationUtil.initializeNotificationsEventListeners();
//     NotificationUtil.initializeIsolateReceivePort();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       builder: (context, child) {
//         return MultiBlocProvider(
//           providers: [
//             ChangeNotifierProvider(
//               create: (_) =>
//                   DeviceProvider(FirebaseAuth.instance.currentUser?.uid ?? ''),
//             ),
//             BlocProvider(
//               create: (context) => MemoryBloc(),
//             ),
//             BlocProvider(
//               create: (context) => ChatBloc(
//                 SharedPreferencesUtil(),
//                 MessageProvider(),
//                 MemoryProvider(),
//               ),
//             ),
//             BlocProvider(
//               create: (_) => BluetoothBloc(),
//             ),
//             BlocProvider<ConnectivityBloc>(
//               create: (context) => ConnectivityBloc(),
//             ),
//             ChangeNotifierProvider(
//               create: (_) => ProfileProvider(),
//             ),
//           ],
//           child: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             title: F.title,
//             navigatorKey: MyApp.navigatorKey,
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [Locale('en')],
//             home: SplashScreen(
//               isAuth: widget.isAuth,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:developer';

import 'package:altio/backend/api_requests/api/prompt.dart';
import 'package:altio/backend/auth.dart';
import 'package:altio/backend/database/box.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/message_provider.dart';
import 'package:altio/backend/database/profile_provider.dart';
import 'package:altio/backend/growthbook.dart';
import 'package:altio/backend/mixpanel.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/theme/app_theme.dart';
import 'package:altio/env/dev_env.dart';
import 'package:altio/env/env.dart';
import 'package:altio/env/prod_env.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/features/chat/bloc/chat_bloc.dart';
import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/firebase_options_dev.dart' as dev;
import 'package:altio/firebase_options_prod.dart' as prod;
import 'package:altio/flavors.dart';
import 'package:altio/objectbox.g.dart'; // For openStore
import 'package:altio/pages/splash/splash_screen.dart';
import 'package:altio/utils/features/calendar.dart';
import 'package:altio/utils/other/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

// Workmanager callback dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Store? store;
    try {
      log("Workmanager task started: $task at ${DateTime.now()}");
      await SharedPreferencesUtil.init();
      store = await openStore(); // New store for isolate

      final chatBloc = ChatBloc(
        SharedPreferencesUtil(),
        MessageProvider.withStore(store),
        MemoryProvider.withStore(store),
      );

      await _runDailySummary(chatBloc, DateTime.now());
      log("Workmanager task completed: $task at ${DateTime.now()}");
      return Future.value(true);
    } catch (e, stackTrace) {
      log('Workmanager task failed: $e\n$stackTrace');
      return Future.value(false);
    } finally {
      store?.close(); // Clean up
    }
  });
}

// Daily summary logic
Future<void> _runDailySummary(ChatBloc chatBloc, DateTime targetDate) async {
  log("Running Daily Summary for $targetDate");

  final prefs = SharedPreferencesUtil();
  final lastRunStr = prefs.lastDailySummaryDay;
  final target8pm =
      DateTime(targetDate.year, targetDate.month, targetDate.day, 20);

  log("Last run: $lastRunStr, Target 8 PM: $target8pm");

  if (lastRunStr.isNotEmpty) {
    final lastRun = DateTime.parse(lastRunStr);
    if (lastRun.isAfter(target8pm) || lastRun.isAtSameMomentAs(target8pm)) {
      log("Skipping Daily Summary: Already ran at or after 8 PM for $targetDate");
      return;
    } else {
      log("Last run was before 8 PM, proceeding with summary");
    }
  } else {
    log("No previous run recorded, proceeding with summary");
  }

  final memories = chatBloc.memoryProvider.retrieveDayMemories(targetDate);
  log("Retrieved ${memories.length} memories for $targetDate");

  if (memories.isEmpty) {
    log("No memories found for $targetDate, marking as complete");
    prefs.lastDailySummaryDay = target8pm.toIso8601String();
    return;
  }

  log("Creating and saving summary message");
  final message = Message(target8pm, '', 'ai', type: 'daySummary');
  await chatBloc.messageProvider.saveMessage(message);

  log("Generating summary notification");
  final result = await dailySummaryNotifications(memories);
  prefs.lastDailySummaryDay = target8pm.toIso8601String();

  log("Updating message with result: $result");
  message.text = result;
  message.memories.addAll(memories);
  await chatBloc.messageProvider.updateMessage(message);

  log("Triggering UI refresh");
  chatBloc.add(RefreshMessages());
}

void main() async {
  if (F.env == Environment.prod) {
    Env.init(ProdEnv());
  } else {
    Env.init(DevEnv());
  }

  WidgetsFlutterBinding.ensureInitialized();

  await ble.FlutterBluePlus.setLogLevel(ble.LogLevel.info, color: true);
  try {
    if (F.env == Environment.prod) {
      await Firebase.initializeApp(
        options: prod.DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp(
        options: dev.DefaultFirebaseOptions.currentPlatform,
      );
    }

    await initializeNotifications();
    await SharedPreferencesUtil.init();
    await ObjectBoxUtil.init(); // Singleton for main app
    await MixpanelManager.init();
  } on Exception catch (e, stackTrace) {
    log('Initialization failed: $e\n$stackTrace');
  }

  listenAuthTokenChanges();

  bool isAuth = false;
  try {
    isAuth = (await getIdToken()) != null;
  } on Exception catch (e) {
    log(e.toString());
  }

  if (isAuth) MixpanelManager().identify();

  try {
    initOpus(await opus_flutter.load());
    await GrowthbookUtil.init();
    CalendarUtil.init();
  } on Exception catch (e, stackTrace) {
    log('Optional initialization failed: $e\n$stackTrace');
  }

  if (Env.oneSignalAppId != null) {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(Env.oneSignalAppId!);
    await OneSignal.login(SharedPreferencesUtil().uid);
  }

  await _checkAndRunMissedSummary();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await _scheduleDailySummary();

  // For testing (remove in production)
  // await Workmanager().registerOneOffTask(
  //   "testDailySummary",
  //   "dailySummaryTest",
  //   initialDelay: const Duration(seconds: 15),
  // );

  _getRunApp(isAuth);
}

Future<void> _checkAndRunMissedSummary() async {
  final prefs = SharedPreferencesUtil();
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final yesterday8pm =
      DateTime(yesterday.year, yesterday.month, yesterday.day, 20);

  final lastRunStr = prefs.lastDailySummaryDay;

  if (lastRunStr.isEmpty || DateTime.parse(lastRunStr).isBefore(yesterday8pm)) {
    log("Detected missed summary for $yesterday");
    final chatBloc = ChatBloc(
      SharedPreferencesUtil(),
      MessageProvider(), // Uses singleton
      MemoryProvider(), // Uses singleton
    );
    await _runDailySummary(chatBloc, yesterday);
    log("Completed catch-up summary for $yesterday");
  } else {
    log("No missed summary detected. Last run: $lastRunStr");
  }
}

Future<void> _scheduleDailySummary() async {
  await Workmanager().registerPeriodicTask(
    "dailySummaryTask",
    "dailySummary",
    frequency: const Duration(hours: 24),
    initialDelay: _calculateInitialDelayTo8PM(),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

Duration _calculateInitialDelayTo8PM() {
  final now = DateTime.now();
  final today8pm = DateTime(now.year, now.month, now.day, 20);
  return today8pm.isAfter(now)
      ? today8pm.difference(now)
      : today8pm.add(const Duration(days: 1)).difference(now);
}

_getRunApp(bool isAuth) {
  return runApp(MyApp(isAuth: isAuth));
}

class MyApp extends StatefulWidget {
  final bool isAuth;

  const MyApp({super.key, required this.isAuth});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class MyAppState extends State<MyApp> {
  List<Plugin> plugins = [];

  @override
  void initState() {
    super.initState();
    NotificationUtil.initializeNotificationsEventListeners();
    NotificationUtil.initializeIsolateReceivePort();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  DeviceProvider(FirebaseAuth.instance.currentUser?.uid ?? ''),
            ),
            BlocProvider(
              create: (context) => MemoryBloc(),
            ),
            BlocProvider(
              create: (context) => ChatBloc(
                SharedPreferencesUtil(),
                MessageProvider(),
                MemoryProvider(),
              ),
            ),
            BlocProvider(
              create: (_) => BluetoothBloc(),
            ),
            BlocProvider<ConnectivityBloc>(
              create: (context) => ConnectivityBloc(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            title: F.title,
            navigatorKey: MyApp.navigatorKey,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: SplashScreen(
              isAuth: widget.isAuth,
            ),
          ),
        );
      },
    );
  }
}
