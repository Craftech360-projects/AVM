import 'dart:async';
import 'dart:io';

import 'package:capsaul/backend/api_requests/api/server.dart';
import 'package:capsaul/backend/api_requests/cloud_storage.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/database/message.dart';
import 'package:capsaul/backend/database/message_provider.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/bt_device.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:capsaul/features/capture/logic/websocket_mixin.dart';
import 'package:capsaul/features/capture/presentation/capture_page.dart';
import 'package:capsaul/features/chat/bloc/chat_bloc.dart';
import 'package:capsaul/features/chat/presentation/chat_screen.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/main.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:capsaul/pages/settings/presentation/pages/setting_page.dart';
import 'package:capsaul/pages/skeleton/screen_skeleton.dart';
import 'package:capsaul/scripts.dart';
import 'package:capsaul/utils/audio/foreground.dart';
import 'package:capsaul/utils/ble/connected.dart';
import 'package:capsaul/utils/ble/scan.dart';
import 'package:capsaul/utils/other/notifications.dart';
import 'package:capsaul/widgets/navbar.dart';
import 'package:capsaul/widgets/upgrade_alert.dart';
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
  bool? hasSeenTutorial;

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
    _isLoading = true;
    Future.delayed(const Duration(seconds: 2), () {
      var tutorialSeen = SharedPreferencesUtil().hasSeenTutorial;
      setState(() {
        _isLoading = false;
        hasSeenTutorial = tutorialSeen;
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
    super.initState();
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
            batteryLevel = -1; // Reset battery level
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

  void tabChange(int index) {
    MixpanelManager().bottomNavigationTabClicked(['Home', 'Chat'][index]);
    FocusScope.of(context).unfocus();
    setState(() {
      _controller!.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WithForegroundTask(
        child: MyUpgradeAlert(
      upgrader: _upgrader,
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      child: CustomScaffold(
        centerTitle: false,
        resizeToAvoidBottomInset: true,
        showBatteryLevel: true,
        showGearIcon: true,
        title: theme.brightness == Brightness.light
            ? Image.asset(
                AppImages.appLogo,
                width: 70,
                height: 70,
              )
            : Image.asset(
                AppImages.appLogoW,
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
                            hasSeenTutorial: hasSeenTutorial ?? false,
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
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: CustomNavBar(
                              isChat: _controller!.index == 1,
                              isMemory: _controller!.index == 0,
                              onTabChange: (index) =>
                                  _controller?.animateTo(index),
                              onSendMessage: (message) {
                                BlocProvider.of<ChatBloc>(context)
                                    .add(SendMessage(message));
                                FocusScope.of(context).unfocus();
                              },
                              onMemorySearch: (query) {
                                BlocProvider.of<MemoryBloc>(context).add(
                                  SearchMemory(query: query),
                                );
                              },
                              isUserMessageSent: state.isUserMessageSent,
                            ),
                          );
                        },
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
