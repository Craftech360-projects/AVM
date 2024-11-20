import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/api_requests/cloud_storage.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:friend_private/features/chat/presentation/pages/chat_page.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/main.dart';
import 'package:friend_private/pages/capture/connect.dart';
import 'package:friend_private/pages/capture/page.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/home/device.dart';
import 'package:friend_private/pages/settings/page.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/scripts.dart';
import 'package:friend_private/src/features/home/presentation/pages/navbar.dart';
import 'package:friend_private/src/features/live_transcript/data/datasources/ble_connection_datasource.dart';
import 'package:friend_private/utils/audio/foreground.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:friend_private/utils/ble/connected.dart';
import 'package:friend_private/utils/ble/scan.dart';
import 'package:friend_private/utils/features/backups.dart';
import 'package:friend_private/utils/other/notifications.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/scanning_ui.dart';
import 'package:friend_private/widgets/upgrade_alert.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:upgrader/upgrader.dart';

class HomePageWrapper extends StatefulWidget {
  final dynamic btDevice;

  const HomePageWrapper({super.key, this.btDevice});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  ForegroundUtil foregroundUtil = ForegroundUtil();
  TabController? _controller;
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
    '/settings': const SettingsPage(),
  };

  @override
  void initState() {
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
      // initialIndex: SharedPreferencesUtil().pageToShowFromNotification,
    );

    SharedPreferencesUtil().pageToShowFromNotification = 1;
    SharedPreferencesUtil().onboardingCompleted = true;
    print('Selected: ${SharedPreferencesUtil().selectedChatPluginId}');

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
      BleConnectionDatasource().scanAndConnectDevice().then(_onConnected);
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
    // TODO: when disconnected manually need to remove this connection state listener
    _connectionStateListener = BleConnectionDatasource()
        .getConnectionStateListener(
            deviceId: _device!.id,
            onDisconnected: () {
              debugPrint('onDisconnected');
              capturePageKey.currentState
                  ?.resetState(restartBytesProcessing: false);
              setState(() => _device = null);
              InstabugLog.logInfo('AVM Device Disconnected');
              if (SharedPreferencesUtil().reconnectNotificationIsChecked) {
                createNotification(
                  title: 'AVM Device Disconnected',
                  body: 'Please reconnect to continue using your AVM.',
                );
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

  _onConnected(BTDeviceStruct? connectedDevice,
      {bool initiateConnectionListener = true}) {
    debugPrint('_onConnected: $connectedDevice');
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
    setState(() {});
  }

  _initiateBleBatteryListener() async {
    _bleBatteryLevelListener?.cancel();
    _bleBatteryLevelListener =
        await BleConnectionDatasource().getBleBatteryLevelListener(
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
      _controller!.index = index; // Update the TabController index
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            chatTextFieldFocusNode.unfocus();
            memoriesTextFieldFocusNode.unfocus();
          },
          child: Stack(
            children: [
              TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  CapturePage(
                    key: capturePageKey,
                    device: _device,
                    refreshMemories: _initiateMemories,
                    refreshMessages: _refreshMessages,
                  ),
                  ChatPageTest(
                    textFieldFocusNode: chatTextFieldFocusNode,
                  ),
                  const SettingPage(),
                ],
              ),
              if (chatTextFieldFocusNode.hasFocus ||
                  memoriesTextFieldFocusNode.hasFocus)
                const SizedBox.shrink()
              else
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0), // Add padding for floating effect
                    child: CustomNavBar(
                      isChat: _controller!.index == 1,
                      isMemory: _controller!.index == 0,
                      onTabChange: (index) =>
                          _controller?.animateTo(index), // Optional callback
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
                  ),
                )
            ],
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {},
                child: Image.asset(
                  'assets/images/herologo.png',
                  width: 50,
                  height: 20,
                ),
              ),
              //*-- Chat Plugin --*//

              //* AVM Battery indecator
              _device != null && batteryLevel != -1
                  ? GestureDetector(
                      onTap: _device == null
                          ? null
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (c) => ConnectedDevice(
                                        device: _device!,
                                        batteryLevel: batteryLevel,
                                      )));
                              MixpanelManager().batteryIndicatorClicked();
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              color: batteryLevel > 75
                                  ? const Color.fromARGB(255, 0, 255, 8)
                                  : batteryLevel > 20
                                      ? Colors.yellow.shade700
                                      : Colors.red,
                              size: 12,
                            ),
                            // Container(
                            //   width: 10,
                            //   height: 10,
                            //   decoration: BoxDecoration(
                            //     color: batteryLevel > 75
                            //         ? const Color.fromARGB(255, 0, 255, 8)
                            //         : batteryLevel > 20
                            //             ? Colors.yellow.shade700
                            //             : Colors.red,
                            //     shape: BoxShape.circle,
                            //   ),
                            // ),
                            // const SizedBox(width: 8.0),
                            Text(
                              '${batteryLevel.toString()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                          onTap: () async {
                            if (SharedPreferencesUtil().deviceId.isEmpty) {
                              routeToPage(context, const ConnectDevicePage());
                              MixpanelManager().connectFriendClicked();
                            } else {
                              await routeToPage(
                                  context,
                                  const ConnectedDevice(
                                      device: null, batteryLevel: 0));
                            }
                            setState(() {});
                          },
                          child: const ScanningUI()),
                    )
            ],
          ),
          elevation: 0,
          centerTitle: true,
        ),
      ),
    ));
  }

  _getPluginsDropdownItems(BuildContext context) {
    var items = [
          DropdownMenuItem<String>(
            value: 'no_selected',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(size: 20, Icons.chat, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  SharedPreferencesUtil().pluginsEnabled.isEmpty
                      ? 'Enable Plugins   '
                      : 'Select a plugin',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                )
              ],
            ),
          )
        ] +
        plugins
            .where((p) =>
                SharedPreferencesUtil().pluginsEnabled.contains(p.id) &&
                p.worksWithChat())
            .map<DropdownMenuItem<String>>((Plugin plugin) {
          return DropdownMenuItem<String>(
            value: plugin.id,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  maxRadius: 12,
                  backgroundImage: NetworkImage(plugin.getImageUrl()),
                ),
                const SizedBox(width: 8),
                Text(
                  plugin.name.length > 18
                      ? '${plugin.name.substring(0, 18)}...'
                      : plugin.name + ' ' * (18 - plugin.name.length),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                )
              ],
            ),
          );
        }).toList();
    if (SharedPreferencesUtil().pluginsEnabled.isNotEmpty) {
      items.add(const DropdownMenuItem<String>(
        value: 'enable',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              maxRadius: 12,
              child: Icon(Icons.star, color: Colors.purpleAccent),
            ),
            SizedBox(width: 8),
            Text('Enable Plugins   ',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16))
          ],
        ),
      ));
    }
    return items;
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
  // IconButton(
              //   icon: const Icon(
              //     Icons.settings,
              //     color: Colors.white,
              //     size: 30,
              //   ),
              //   onPressed: () async {
              //     MixpanelManager().settingsOpened();
              //     String language = SharedPreferencesUtil().recordingsLanguage;
              //     bool hasSpeech = SharedPreferencesUtil().hasSpeakerProfile;
              //     await routeToPage(context, const SettingsPage());
              //     // TODO: this fails like 10 times, connects reconnects, until it finally works.
              //     if (GrowthbookUtil().hasStreamingTranscriptFeatureOn() &&
              //         (language != SharedPreferencesUtil().recordingsLanguage ||
              //             hasSpeech !=
              //                 SharedPreferencesUtil().hasSpeakerProfile)) {
              //       capturePageKey.currentState?.restartWebSocket();
              //     }
              //     setState(() {});
              //   },
              // )


               // _controller!.index == 1
              //     ? Padding(
              //         padding: const EdgeInsets.only(left: 0),
              //         child: Container(
              //           // decoration: BoxDecoration(
              //           //   border: Border.all(color: Colors.grey),
              //           //   borderRadius: BorderRadius.circular(30),
              //           // ),
              //           padding: const EdgeInsets.symmetric(horizontal: 16),
              //           child: DropdownButton<String>(
              //             menuMaxHeight: 350,
              //             value: SharedPreferencesUtil().selectedChatPluginId,
              //             onChanged: (s) async {
              //               if ((s == 'no_selected' &&
              //                       SharedPreferencesUtil()
              //                           .pluginsEnabled
              //                           .isEmpty) ||
              //                   s == 'enable') {
              //                 await routeToPage(context,
              //                     const PluginsPage(filterChatOnly: true));
              //                 setState(() {});
              //                 return;
              //               }
              //               print(
              //                   'Selected: $s prefs: ${SharedPreferencesUtil().selectedChatPluginId}');
              //               if (s == null ||
              //                   s ==
              //                       SharedPreferencesUtil()
              //                           .selectedChatPluginId) return;

              //               SharedPreferencesUtil().selectedChatPluginId = s;
              //               var plugin =
              //                   plugins.firstWhereOrNull((p) => p.id == s);
              //               // chatPageKey.currentState
              //               //     ?.sendInitialPluginMessage(plugin);
              //               setState(() {});
              //             },
              //             icon: Container(),
              //             alignment: Alignment.center,
              //             dropdownColor: Colors.black,
              //             style: const TextStyle(
              //                 color: Colors.white, fontSize: 16),
              //             underline:
              //                 Container(height: 0, color: Colors.transparent),
              //             isExpanded: false,
              //             itemHeight: 48,
              //             padding: EdgeInsets.zero,
              //             items: _getPluginsDropdownItems(context),
              //           ),
              //         ),
              //       )
              //     : const SizedBox(width: 16),



              //old navbar



               // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     margin: const EdgeInsets.all(
                //         16), // Add some margin for the floating effect
                //     padding: const EdgeInsets.symmetric(vertical: 8),
                //     decoration: BoxDecoration(
                //       color: Colors.black,
                //       borderRadius: BorderRadius.circular(20),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.2),
                //           blurRadius: 10,
                //           offset: const Offset(0, 4),
                //         ),
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Expanded(
                //           child: MaterialButton(
                //             onPressed: () => _tabChange(0),
                //             child: Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Icon(
                //                   Icons.home,
                //                   color: _controller!.index == 0
                //                       ? Colors.white
                //                       : Colors.grey,
                //                 ),
                //                 Padding(
                //                   padding: const EdgeInsets.only(top: 8.0),
                //                   child: Text(
                //                     'Home',
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: TextStyle(
                //                       color: _controller!.index == 0
                //                           ? Colors.white
                //                           : Colors.grey,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         Expanded(
                //           child: MaterialButton(
                //             onPressed: () => _tabChange(1),
                //             child: Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Icon(
                //                   Icons.chat,
                //                   color: _controller!.index == 1
                //                       ? Colors.white
                //                       : Colors.grey,
                //                 ),
                //                 Padding(
                //                   padding: const EdgeInsets.only(top: 8.0),
                //                   child: Text(
                //                     'Chat',
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: TextStyle(
                //                       color: _controller!.index == 1
                //                           ? Colors.white
                //                           : Colors.grey,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         Expanded(
                //           child: MaterialButton(
                //             onPressed: () => _tabChange(2),
                //             child: Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Icon(
                //                   Icons.settings,
                //                   color: _controller!.index == 2
                //                       ? Colors.white
                //                       : Colors.grey,
                //                 ),
                //                 Padding(
                //                   padding: const EdgeInsets.only(top: 8.0),
                //                   child: Text(
                //                     'Setting',
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: TextStyle(
                //                       color: _controller!.index == 2
                //                           ? Colors.white
                //                           : Colors.grey,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),

                //       ],
                //     ),
                //   ),
                // ),