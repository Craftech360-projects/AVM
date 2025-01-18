import 'dart:async';
import 'dart:developer';

import 'package:capsaul/backend/api_requests/api/server.dart';
import 'package:capsaul/backend/auth.dart';
import 'package:capsaul/backend/database/box.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/database/message_provider.dart';
import 'package:capsaul/backend/growthbook.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/core/theme/app_theme.dart';
import 'package:capsaul/env/dev_env.dart';
import 'package:capsaul/env/env.dart';
import 'package:capsaul/env/prod_env.dart';
import 'package:capsaul/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:capsaul/features/chat/bloc/chat_bloc.dart';
import 'package:capsaul/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/firebase_options_dev.dart' as dev;
import 'package:capsaul/firebase_options_prod.dart' as prod;
import 'package:capsaul/flavors.dart';
import 'package:capsaul/pages/splash/splash_screen.dart';
import 'package:capsaul/src/config/simple_bloc_observer.dart';
import 'package:capsaul/utils/features/calendar.dart';
import 'package:capsaul/utils/other/notifications.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

void main() async {
  if (F.env == Environment.prod) {
    Env.init(ProdEnv());
  } else {
    Env.init(DevEnv());
  }

  WidgetsFlutterBinding.ensureInitialized();

  ble.FlutterBluePlus.setLogLevel(ble.LogLevel.info, color: true);
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
  await ObjectBoxUtil.init();
  await MixpanelManager.init();
  // AppLogger.init();
  Bloc.observer = const SimpleBlocObserver();

  listenAuthTokenChanges();
  bool isAuth = false;
  try {
    isAuth = (await getIdToken()) != null;
  } catch (e) {
    log(e.toString());
  }

  if (isAuth) MixpanelManager().identify();

  initOpus(await opus_flutter.load());

  await GrowthbookUtil.init();
  CalendarUtil.init();

  if (Env.oneSignalAppId != null) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(Env.oneSignalAppId!);
    OneSignal.login(SharedPreferencesUtil().uid);
  }

  if (Env.instabugApiKey != null) {
    runZonedGuarded(
      () {
        Instabug.init(
          token: Env.instabugApiKey!,
          invocationEvents: [InvocationEvent.shake, InvocationEvent.screenshot],
        );
        if (isAuth) {
          Instabug.identifyUser(
            FirebaseAuth.instance.currentUser?.email ?? '',
            SharedPreferencesUtil().fullName,
            SharedPreferencesUtil().uid,
          );
        }
        FlutterError.onError = (FlutterErrorDetails details) {
          Zone.current.handleUncaughtError(
              details.exception, details.stack ?? StackTrace.empty);
        };
        _getRunApp(isAuth);
      },
      CrashReporting.reportCrash,
    );
  } else {
    _getRunApp(isAuth);
  }
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
    NotificationUtil.initializeNotificationsEventListeners();
    NotificationUtil.initializeIsolateReceivePort();
    _initiatePlugins();
    super.initState();
  }

  Future<void> _initiatePlugins() async {
    plugins = SharedPreferencesUtil().pluginsList;
    plugins = await retrievePlugins();

    _edgeCasePluginNotAvailable();
    setState(() {});
  }

  _edgeCasePluginNotAvailable() {
    var selectedChatPlugin = SharedPreferencesUtil().selectedChatPluginId;
    var plugin = plugins.firstWhereOrNull((p) => selectedChatPlugin == p.id);
    if (selectedChatPlugin != 'no_selected' &&
        (plugin == null || !plugin.worksWithChat())) {
      SharedPreferencesUtil().selectedChatPluginId = 'no_selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => MemoryBloc()),
            BlocProvider(
              create: (context) => ChatBloc(
                SharedPreferencesUtil(),
                MessageProvider(),
                MemoryProvider(),
              ),
            ),
            BlocProvider(
              create: (context) =>
                  BluetoothBloc()..startListening('your_device_id'),
            ),
            BlocProvider<ConnectivityBloc>(
              create: (context) => ConnectivityBloc(),
            ),
          ],
          child: MaterialApp(
            navigatorObservers: [InstabugNavigatorObserver()],
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
