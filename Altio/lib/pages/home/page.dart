import 'dart:async';
import 'dart:io';

import 'package:altio/backend/api_requests/cloud_storage.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/message_provider.dart';
import 'package:altio/backend/mixpanel.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/backend/websocket/websocket_mixin.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/widgets/navbar.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/features/capture/presentation/capture_page.dart';
import 'package:altio/features/chat/bloc/chat_bloc.dart';
import 'package:altio/features/chat/presentation/chat_screen.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/main.dart';
import 'package:altio/pages/home/action_items.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/pages/settings/presentation/pages/settings_page.dart';
import 'package:altio/pages/settings/widgets/about_you.dart';
import 'package:altio/pages/skeleton/screen_skeleton.dart';
import 'package:altio/scripts.dart';
import 'package:altio/utils/audio/foreground.dart';
import 'package:altio/utils/ble/connected.dart';
import 'package:altio/utils/ble/scan.dart';
import 'package:altio/utils/legal/terms_and_condition.dart';
import 'package:altio/utils/other/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePageWrapper extends StatefulWidget {
  final dynamic btDevice;
  final int? tabIndex;

  const HomePageWrapper({super.key, this.btDevice, this.tabIndex});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper>
    with WidgetsBindingObserver, TickerProviderStateMixin, WebSocketMixin {
  ForegroundUtil foregroundUtil = ForegroundUtil();
  late TabController _controller;
  late bool _isLoading;
  bool? hasSeenTutorial;

  List<Widget> screens = [Container(), const SizedBox(), const SizedBox()];

  List<Memory> memories = [];
  List<Message> messages = [];

  FocusNode chatTextFieldFocusNode = FocusNode(canRequestFocus: true);
  FocusNode memoriesTextFieldFocusNode = FocusNode(canRequestFocus: true);

  GlobalKey<CapturePageState> capturePageKey = GlobalKey();
  StreamSubscription<OnConnectionStateChangedEvent>? _connectionStateListener;
  StreamSubscription<List<int>>? _bleBatteryLevelListener;

  int batteryLevel = -1;
  BTDeviceStruct? _device;

  List<Plugin> plugins = [];

  void someMethod() {
    if (capturePageKey.currentState != null) {
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

  // _setupHasSpeakerProfile() async {
  //   SharedPreferencesUtil().hasSpeakerProfile =
  //       await userHasSpeakerProfile(SharedPreferencesUtil().uid);
  //   MixpanelManager().setUserProperty(
  //       'Speaker Profile', SharedPreferencesUtil().hasSpeakerProfile);
  //   setState(() {});
  // }

  // _edgeCasePluginNotAvailable() {
  //   var selectedChatPlugin = SharedPreferencesUtil().selectedChatPluginId;
  //   var plugin = plugins.firstWhereOrNull((p) => selectedChatPlugin == p.id);
  //   if (selectedChatPlugin != 'no_selected' &&
  //       (plugin == null || !plugin.worksWithChat())) {
  //     SharedPreferencesUtil().selectedChatPluginId = 'no_selected';
  //   }
  // }

  // Future<void> _initiatePlugins() async {
  //   plugins = SharedPreferencesUtil().pluginsList;
  //   plugins = await retrievePlugins();
  //   _edgeCasePluginNotAvailable();
  //   setState(() {});
  // }

  String event = '';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      event = 'App is paused';
    } else if (state == AppLifecycleState.resumed) {
      event = 'App is resumed';
    } else if (state == AppLifecycleState.hidden) {
      event = 'App is hidden';
    } else if (state == AppLifecycleState.detached) {
      event = 'App is detached';
    }
  }

  _migrationScripts() async {
    scriptMemoryVectorsExecuted();
    _initiateMemories();
  }

  final Map<String, Widget> screensWithRespectToPath = {
    '/settingsPage': const SettingsPage(),
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    _controller = TabController(length: 5, initialIndex: 2, vsync: this);

    Future.delayed(const Duration(seconds: 2), () {
      var tutorialSeen = SharedPreferencesUtil().hasSeenTutorial;
      setState(() {
        _isLoading = false;
        hasSeenTutorial = tutorialSeen;
      });
    });

    SharedPreferencesUtil().pageToShowFromNotification = 1;
    SharedPreferencesUtil().onboardingCompleted = true;

    WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {         ====> Permission should be request in some other way
    //   requestNotificationPermissions();
    //   foregroundUtil.requestPermissionForAndroid();
    // });
    _refreshMessages();
    _initiateMemories();
    // _initiatePlugins();
    // _setupHasSpeakerProfile();
    _migrationScripts();
    authenticateGCP();
    if (SharedPreferencesUtil().deviceId.isNotEmpty) {
      scanAndConnectDevice().then((device) {
        if (!mounted) return;
        _onConnected(device);
        BlocProvider.of<BluetoothBloc>(context).startListening(device!.id);
      });
    }

    createNotification(
      title: 'Suit up with Capsaul today',
      body: 'Your memories await. Don’t forget to wear Capsaul!',
      notificationId: 4,
      isMorningNotification: true,
    );
    createNotification(
      title: 'Plan ahead for success.',
      body: 'Crush tomorrow’s goals—see your action plan now.',
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
            batteryLevel = -1; // Reset battery level
          });
          if (SharedPreferencesUtil().reconnectNotificationIsChecked) {
            if (SharedPreferencesUtil().showDisconnectionNotification) {
              createNotification(
                title: 'Heads up! Capsaul is disconnected.',
                body: 'Your Capsaul needs a quick reconnection to stay active.',
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
    await foregroundUtil.startForegroundTask();
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
      _controller.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return DefaultTabController(
      length: 3,
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
        tabIndex: widget.tabIndex ?? _controller.index,
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
                            tabController: _controller,
                          ),
                          ActionItems(),
                          ChatScreen(
                            textFieldFocusNode: chatTextFieldFocusNode,
                          ),
                          const AboutYouScreen(),
                          const SettingsPage(),
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
                              isChat: _controller.index == 1,
                              isMemory: _controller.index == 0,
                              onTabChange: (index) =>
                                  _controller.animateTo(index),
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
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionStateListener?.cancel();
    _bleBatteryLevelListener?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
