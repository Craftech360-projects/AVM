import 'dart:async';
import 'dart:io';

import 'package:altio/backend/api_requests/api/server.dart';
import 'package:altio/backend/api_requests/cloud_storage.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/message_provider.dart';
import 'package:altio/backend/mixpanel.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/features/capture/logic/websocket_mixin.dart';
import 'package:altio/features/capture/presentation/capture_page.dart';
import 'package:altio/main.dart';
import 'package:altio/pages/settings/presentation/pages/setting_page.dart';
import 'package:altio/scripts.dart';
import 'package:altio/utils/audio/foreground.dart';
import 'package:altio/utils/ble/connected.dart';
import 'package:altio/utils/ble/scan.dart';
import 'package:altio/utils/legal/terms_and_condition.dart';
import 'package:altio/utils/other/notifications.dart';
import 'package:altio/widgets/upgrade_alert.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:instabug_flutter/instabug_flutter.dart';

class HomePageWrapper extends StatefulWidget {
  final dynamic btDevice;

  const HomePageWrapper({super.key, this.btDevice});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper>
    with WidgetsBindingObserver, TickerProviderStateMixin, WebSocketMixin {
  ForegroundUtil foregroundUtil = ForegroundUtil();
  bool? hasSeenTutorial;

  List<Widget> screens = [Container(), const SizedBox(), const SizedBox()];

  List<Memory> memories = [];
  List<Message> messages = [];

  FocusNode chatTextFieldFocusNode = FocusNode(canRequestFocus: true);
  GlobalKey<CapturePageState> capturePageKey = GlobalKey();
  // GlobalKey<ChatPageState> chatPageKey = GlobalKey();
  StreamSubscription<OnConnectionStateChangedEvent>? _connectionStateListener;
  StreamSubscription<List<int>>? _bleBatteryLevelListener;

  int batteryLevel = -1;
  BTDeviceStruct? _device;

  List<Plugin> plugins = [];
  final _upgrader = MyUpgrader(debugLogging: false, debugDisplayOnce: false);

  void someMethod() {
    // Check if the CapturePageState is available
    if (capturePageKey.currentState != null) {
      // Call the initiateBytesStreamingProcessing method
      capturePageKey.currentState!.initiateBytesStreamingProcessing();
    }
  }

  _initiateMemories() async {
    memories = MemoryProvider()
        .getMemoriesOrdered(includeDiscarded: true)
        .reversed
        .toList();
    setState(() {});
  }

  _refreshMessages() async {
    messages = MessageProvider().getMessages();
    setState(() {});
  }

  _setupHasSpeakerProfile() async {
    SharedPreferencesUtil().hasSpeakerProfile =
        await userHasSpeakerProfile(SharedPreferencesUtil().uid);
    MixpanelManager().setUserProperty(
        'Speaker Profile', SharedPreferencesUtil().hasSpeakerProfile);
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

  Future<void> _initiatePlugins() async {
    plugins = SharedPreferencesUtil().pluginsList;
    plugins = await retrievePlugins();
    _edgeCasePluginNotAvailable();
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String event = '';
    if (state == AppLifecycleState.paused) {
      event = 'App is paused';
    } else if (state == AppLifecycleState.resumed) {
      event = 'App is resumed';
    } else if (state == AppLifecycleState.hidden) {
      event = 'App is hidden';
    } else if (state == AppLifecycleState.detached) {
      event = 'App is detached';
    }
    InstabugLog.logInfo(event);
  }

  _migrationScripts() async {
    scriptMemoryVectorsExecuted();
    // await migrateMemoriesToObjectBox();
    _initiateMemories();
  }

  ///Screens with respect to subpage
  final Map<String, Widget> screensWithRespectToPath = {
    '/settings': const SettingPage(),
  };

  @override
  void initState() {
    super.initState();
    setState(() {});
    Future.delayed(const Duration(seconds: 2), () {
      var tutorialSeen = SharedPreferencesUtil().hasSeenTutorial;
      setState(() {
        hasSeenTutorial = tutorialSeen;
      });
    });

    SharedPreferencesUtil().pageToShowFromNotification = 1;
    SharedPreferencesUtil().onboardingCompleted = true;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      requestNotificationPermissions();
      foregroundUtil.requestPermissionForAndroid();
    });
    _refreshMessages();
    // executeBackupWithUid();
    _initiateMemories();
    _initiatePlugins();
    _setupHasSpeakerProfile();
    _migrationScripts();
    authenticateGCP();
    if (SharedPreferencesUtil().deviceId.isNotEmpty) {
      scanAndConnectDevice().then((device) {
        _onConnected(device);
        BlocProvider.of<BluetoothBloc>(context).startListening(device!.id);
      });
    }

    createNotification(
      title: 'Don\'t forget to wear Capsaul today',
      body: 'Wear your Capsaul and capture your memories today.',
      notificationId: 4,
      isMorningNotification: true,
    );
    createNotification(
      title: 'Here is your action plan for tomorrow',
      body: 'Check out your daily summary to see what you should do tomorrow.',
      notificationId: 5,
      isDailySummaryNotification: true,
      payload: {'path': '/chat'},
    );
    if (SharedPreferencesUtil().subPageToShowFromNotification != '') {
      final subPageRoute =
          SharedPreferencesUtil().subPageToShowFromNotification;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        MyApp.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                screensWithRespectToPath[subPageRoute] as Widget,
          ),
        );
      });
      SharedPreferencesUtil().subPageToShowFromNotification = '';
    }
  }

  _initiateConnectionListener() async {
    if (_connectionStateListener != null) return;
    //when disconnected manually need to remove this connection state listener
    _connectionStateListener = getConnectionStateListener(
      deviceId: _device!.id,
      onStateChanged: (state, device) {
        if (state == BluetoothConnectionState.disconnected) {
          capturePageKey.currentState
              ?.resetState(restartBytesProcessing: false);
          setState(() {
            _device = null;
            batteryLevel = -1;
          });
          InstabugLog.logInfo('Capsaul Disconnected');
          if (SharedPreferencesUtil().reconnectNotificationIsChecked) {
            if (SharedPreferencesUtil().showDisconnectionNotification) {
              createNotification(
                title: 'Capsaul Disconnected',
                body: 'Please reconnect to continue using Capsaul.',
              );
              SharedPreferencesUtil().showDisconnectionNotification = false;
            } else {}
          }
          MixpanelManager().deviceDisconnected();
          foregroundUtil.stopForegroundTask();
        } else if (state == BluetoothConnectionState.connected &&
            device != null) {
          _onConnected(device, initiateConnectionListener: false);
        }
      },
    );
  }

  _startForeground() async {
    if (!Platform.isAndroid) return;
    await foregroundUtil.initForegroundTask();
    // ignore: unused_local_variable
    var result = await foregroundUtil.startForegroundTask();
  }

  _onConnected(BTDeviceStruct? connectedDevice,
      {bool initiateConnectionListener = true}) {
    if (connectedDevice == null) return;
    clearNotification(1);
    _device = connectedDevice;
    if (initiateConnectionListener) _initiateConnectionListener();
    _initiateBleBatteryListener();
    capturePageKey.currentState
        ?.resetState(restartBytesProcessing: true, btDevice: connectedDevice);
    MixpanelManager().deviceConnected();
    SharedPreferencesUtil().deviceId = _device!.id;
    SharedPreferencesUtil().deviceName = _device!.name;
    _startForeground();

    setState(() {
      _device = connectedDevice;
    });
  }

  _initiateBleBatteryListener() async {
    _bleBatteryLevelListener?.cancel();
    _bleBatteryLevelListener = await getBleBatteryLevelListener(
      _device!.id,
      onBatteryLevelChange: (int value) {
        setState(() {
          batteryLevel = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTosAccepted = SharedPreferencesUtil().tosAccepted;

    if (!isTosAccepted) {
      return TermsAndConditionsWidget(
        showAcceptBtn: true,
        onAccept: () {
          SharedPreferencesUtil().tosAccepted = true;
          setState(() {});
        },
      );
    }

    return CapturePage(
      key: capturePageKey,
      device: _device,
      batteryLevel: batteryLevel,
      refreshMemories: _initiateMemories,
      refreshMessages: _refreshMessages,
      hasSeenTutorial: hasSeenTutorial ?? false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionStateListener?.cancel();
    _bleBatteryLevelListener?.cancel();
    super.dispose();
  }
}
