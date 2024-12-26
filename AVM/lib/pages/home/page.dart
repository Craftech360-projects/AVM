import 'dart:async';
import 'dart:io';

import 'package:avm/backend/api_requests/api/server.dart';
import 'package:avm/backend/api_requests/cloud_storage.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/database/message.dart';
import 'package:avm/backend/database/message_provider.dart';
import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/backend/schema/plugin.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/features/capture/logic/websocket_mixin.dart';
import 'package:avm/features/capture/presentation/capture_page.dart';
import 'package:avm/features/chat/bloc/chat_bloc.dart';
import 'package:avm/features/chat/presentation/chat_screen.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';


import 'package:avm/main.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/settings/presentation/pages/setting_page.dart';
import 'package:avm/pages/skeleton/screen_skeleton.dart';
import 'package:avm/scripts.dart';
import 'package:avm/utils/audio/foreground.dart';
import 'package:avm/utils/ble/communication.dart';
import 'package:avm/utils/ble/connected.dart';
import 'package:avm/utils/ble/scan.dart';
import 'package:avm/utils/features/backups.dart';
import 'package:avm/utils/other/notifications.dart';
import 'package:avm/widgets/navbar.dart';
import 'package:avm/widgets/upgrade_alert.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:upgrader/upgrader.dart';

class HomePageWrapper extends StatefulWidget {
  final dynamic btDevice;

  const HomePageWrapper({super.key, this.btDevice});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper>
    with WidgetsBindingObserver, TickerProviderStateMixin, WebSocketMixin {
  ForegroundUtil foregroundUtil = ForegroundUtil();
  TabController? _controller;
  late bool _isLoading;

  List<Widget> screens = [Container(), const SizedBox(), const SizedBox()];

  List<Memory> memories = [];
  List<Message> messages = [];

  FocusNode chatTextFieldFocusNode = FocusNode(canRequestFocus: true);
  FocusNode memoriesTextFieldFocusNode = FocusNode(canRequestFocus: true);

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
    debugPrint(
        '_setupHasSpeakerProfile: ${SharedPreferencesUtil().hasSpeakerProfile}');
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
    debugPrint(event);
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
    _isLoading = true;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
      // initialIndex: SharedPreferencesUtil().pageToShowFromNotification,
    );

    SharedPreferencesUtil().pageToShowFromNotification = 1;
    SharedPreferencesUtil().onboardingCompleted = true;
    // print('Selected: ${SharedPreferencesUtil().selectedChatPluginId}');

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      requestNotificationPermissions();
      foregroundUtil.requestPermissionForAndroid();
    });
    _refreshMessages();
    executeBackupWithUid();
    _initiateMemories();
    _initiatePlugins();
    _setupHasSpeakerProfile();
    _migrationScripts();
    authenticateGCP();
    if (SharedPreferencesUtil().deviceId.isNotEmpty) {
      scanAndConnectDevice().then(_onConnected);
    }

    createNotification(
      title: 'Don\'t forget to wear AVM today',
      body: 'Wear your AVM and capture your memories today.',
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
    super.initState();
  }

  _initiateConnectionListener() async {
    if (_connectionStateListener != null) return;
    //when disconnected manually need to remove this connection state listener
    _connectionStateListener = getConnectionStateListener(
        deviceId: _device!.id,
        onDisconnected: () {
          debugPrint('onDisconnected');
          capturePageKey.currentState
              ?.resetState(restartBytesProcessing: false);
          setState(() => _device = null);
          InstabugLog.logInfo('AVM Device Disconnected');
          if (SharedPreferencesUtil().reconnectNotificationIsChecked) {
            if (SharedPreferencesUtil().showDisconnectionNotification) {
              print('Show Disconnection Notification: true');
              createNotification(
                title: 'AVM Device Disconnected',
                body: 'Please reconnect to continue using your AVM.',
              );
              SharedPreferencesUtil().showDisconnectionNotification = false;
            } else {
              print('Show Disconnection Notification: false');
            }
          }
          MixpanelManager().deviceDisconnected();
          foregroundUtil.stopForegroundTask();
        },
        onConnected: ((d) =>
            _onConnected(d, initiateConnectionListener: false)));
  }

  _startForeground() async {
    if (!Platform.isAndroid) return;
    await foregroundUtil.initForegroundTask();
    var result = await foregroundUtil.startForegroundTask();
    debugPrint('_startForeground: $result');
  }

  // _onConnected(BTDeviceStruct? connectedDevice,
  //     {bool initiateConnectionListener = true}) async {
  //   debugPrint('_onConnected: $connectedDevice');
  //   if (connectedDevice == null) return;
  //   clearNotification(1);
  //   _device = connectedDevice;
  //   if (initiateConnectionListener) _initiateConnectionListener();
  //   _initiateBleBatteryListener();
  //   capturePageKey.currentState
  //       ?.resetState(restartBytesProcessing: true, btDevice: connectedDevice);
  //   MixpanelManager().deviceConnected();
  //   SharedPreferencesUtil().deviceId = _device!.id;
  //   SharedPreferencesUtil().deviceName = _device!.name;

  //   // Mark "Show Disconnection Notification" as true
  //   SharedPreferencesUtil().showDisconnectionNotification = true;
  //   websocketChannel?.sink.close(1000);
  //   await initWebSocket(
  //     onConnectionClosed: (int? closeCode, String? closeReason) {
  //       setState(() {});
  //     },
  //     onConnectionSuccess: () {
  //       print('WebSocket Connected');
  //       setState(() {});
  //     },
  //     onConnectionError: (p1) {},
  //     onConnectionFailed: (p1) {},
  //     onMessageReceived: (List<TranscriptSegment> p1) {},
  //   );

  //   _startForeground();
  //   setState(() {
  //     _device = connectedDevice;
  //   });
  // }
  
 _onConnected(BTDeviceStruct? connectedDevice, {bool initiateConnectionListener = true}) async {
  debugPrint('_onConnected: $connectedDevice');
  if (connectedDevice == null) return;
  clearNotification(1);
  _device = connectedDevice;
  
  if (initiateConnectionListener) _initiateConnectionListener();
  _initiateBleBatteryListener();
  
  // Reset the capture page state with the connected device
  capturePageKey.currentState?.resetState(restartBytesProcessing: true, btDevice: connectedDevice);
  
  MixpanelManager().deviceConnected();
  SharedPreferencesUtil().deviceId = _device!.id;
  SharedPreferencesUtil().deviceName = _device!.name;

  // Mark "Show Disconnection Notification" as true
  SharedPreferencesUtil().showDisconnectionNotification = true;
  closeWebSocket();
  
  // Allow some delay before initializing WebSocket connection
  await Future.delayed(Duration(seconds: 4));
  
  await initWebSocket(
    onConnectionClosed: (int? closeCode, String? closeReason) {
      setState(() {});
    },
    onConnectionSuccess: () {
      _startForeground();
      print('WebSocket Connected');
      setState(() {});
      
       if (capturePageKey.currentState != null) {
      capturePageKey.currentState!.initiateBytesStreamingProcessing();
    }
    },
    onConnectionError: (p1) {},
    onConnectionFailed: (p1) {},
    onMessageReceived: (List<TranscriptSegment> p1) {},
  );
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

  void tabChange(int index) {
    MixpanelManager().bottomNavigationTabClicked(['Home', 'Chat'][index]);
    FocusScope.of(context).unfocus();
    setState(() {
      _controller!.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
        child: MyUpgradeAlert(
      upgrader: _upgrader,
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      child: CustomScaffold(
        resizeToAvoidBottomInset: true,
        showBatteryLevel: true,
        showGearIcon: true,
        title: Image.asset(
          AppImages.appLogo,
          width: 70,
          height: 70,
        ),
        // showBackBtn: true,
        device: _device,
        batteryLevel: batteryLevel,
        tabIndex: _controller!.index,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            chatTextFieldFocusNode.unfocus();
            memoriesTextFieldFocusNode.unfocus();
          },
          child: _isLoading
              ? const ScreenSkeleton()
              : Stack(
                  children: [
                    Positioned.fill(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _controller,
                        children: [
                          CapturePage(
                            key: capturePageKey,
                            device: _device,
                            batteryLevel: batteryLevel,
                            refreshMemories: _initiateMemories,
                            refreshMessages: _refreshMessages,
                          ),
                          ChatScreen(
                            textFieldFocusNode: chatTextFieldFocusNode,
                          ),
                          const SettingPage(),
                        ],
                      ),
                    ),
                    if (chatTextFieldFocusNode.hasFocus ||
                        memoriesTextFieldFocusNode.hasFocus)
                      const SizedBox.shrink()
                    else
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomNavBar(
                          isChat: _controller!.index == 1,
                          isMemory: _controller!.index == 0,
                          onTabChange: (index) => _controller?.animateTo(index),
                          onSendMessage: (message) {
                            BlocProvider.of<ChatBloc>(context)
                                .add(SendMessage(message));
                          },
                          onMemorySearch: (query) {
                            BlocProvider.of<MemoryBloc>(context).add(
                              SearchMemory(query: query),
                            );
                          },
                        ),
                      )
                  ],
                ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionStateListener?.cancel();
    _bleBatteryLevelListener?.cancel();

    _controller?.dispose();
    super.dispose();
  }
}
