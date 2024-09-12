import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/api_requests/cloud_storage.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/features/chat/presentation/pages/chat_page.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/pages/capture/connect.dart';
import 'package:friend_private/pages/capture/location_service.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/pages/capture/page.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/home/device.dart';
import 'package:friend_private/pages/settings/page.dart';
import 'package:friend_private/scripts.dart';
import 'package:friend_private/utils/audio/foreground.dart';
import 'package:friend_private/utils/audio/wav_bytes.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:friend_private/utils/ble/connected.dart';
import 'package:friend_private/utils/ble/scan.dart';
import 'package:friend_private/utils/features/backups.dart';
import 'package:friend_private/utils/memories/integrations.dart';
import 'package:friend_private/utils/memories/process.dart';
import 'package:friend_private/utils/other/notifications.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/scanning_ui.dart';
import 'package:friend_private/widgets/upgrade_alert.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:uuid/uuid.dart';

class HomePageWrapperTest extends StatefulWidget {
  final dynamic btDevice;

  const HomePageWrapperTest({super.key, this.btDevice});

  @override
  State<HomePageWrapperTest> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapperTest>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, WebSocketMixin {
  ForegroundUtil foregroundUtil = ForegroundUtil();
  // List<Widget> screens = [Container(), const SizedBox(), const SizedBox()];
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
  final _upgrader = MyUpgrader(debugLogging: false, debugDisplayOnce: false);

  int _selectedIndex = 0;

  List<Widget> screens = [];
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

  // @override
  // void didUpdateWidget(covariant HomePageWrapperTest oldWidget) {
  //   screens = [
  //     CapturePage(
  //       key: capturePageKey,
  //       device: _device,
  //       refreshMemories: _initiateMemories,
  //       refreshMessages: _refreshMessages,
  //     ),
  //     ChatPageTest(
  //       textFieldFocusNode: chatTextFieldFocusNode,
  //     ),
  //     const SettingsPage(),
  //   ];
  //   setState(() {});
  //   super.didUpdateWidget(oldWidget);
  // }
  void restartWebSocket() {
    // closeWebSocket();
    initiateWebsocket();
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

  @override
  void initState() {
    super.initState();

    SharedPreferencesUtil().pageToShowFromNotification = 1;
    SharedPreferencesUtil().onboardingCompleted = true;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      requestNotificationPermissions();
      foregroundUtil.requestPermissionForAndroid();
    });

    _refreshMessages();
     initiateWebsocket();
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
    // screens = [
    //   //   const Scaffold(
    //   //   body: Center(
    //   //     child: Text('capture page'),
    //   //   ),
    //   // ),
    //   // const Scaffold(
    //   //   body: Center(
    //   //     child: Text('chat Page'),
    //   //   ),
    //   // ),
    //   CapturePage(
    //     key: capturePageKey,
    //     device: _device,
    //     refreshMemories: _initiateMemories,
    //     refreshMessages: _refreshMessages,
    //   ),
    //   ChatPageTest(
    //     textFieldFocusNode: chatTextFieldFocusNode,
    //   ),
    //   const SettingsPage(),
    // ];
  }

  _initiateConnectionListener() async {
    print('connectionListener $_connectionStateListener');
    if (_connectionStateListener != null) return;
    _connectionStateListener = getConnectionStateListener(
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
    _bleBatteryLevelListener = await getBleBatteryLevelListener(
      _device!.id,
      onBatteryLevelChange: (int value) {
        setState(() {
          batteryLevel = value;
        });
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;

  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  static const quietSecondsForMemoryCreation = 120;

  /// ----
  List<TranscriptSegment> segments = [];

  // StreamSubscription? _bleBytesStream;
  WavBytesUtil? audioStorage;

  Timer? _memoryCreationTimer;
  bool memoryCreating = false;

  DateTime? currentTranscriptStartedAt;
  DateTime? currentTranscriptFinishedAt;

  InternetStatus? _internetStatus;

  late StreamSubscription<InternetStatus> _internetListener;
  bool isGlasses = false;
  String conversationId = const Uuid().v4();

  double? streamStartedAtSecond;
  DateTime? firstStreamReceivedAt;
  int? secondsMissedOnReconnect;
  int elapsedSeconds = 0;
  void sendMessageToChat(Message message, Memory? memory) {
    if (memory != null) message.memories.add(memory);
    MessageProvider().saveMessage(message);
    _refreshMessages();
  }

  setHasTranscripts(bool hasTranscripts) {
    if (_hasTranscripts == hasTranscripts) return;
    setState(() => _hasTranscripts = hasTranscripts);
  }

  _createMemory({bool forcedCreation = false}) async {
    if (memoryCreating) return;
    // TODO: should clean variables here? and keep them locally?
    setState(() => memoryCreating = true);
    File? file;
    // if (audioStorage?.frames.isNotEmpty == true) {
    //   try {
    //     var secs = !forcedCreation ? quietSecondsForMemoryCreation : 0;
    //     file =
    //         (await audioStorage!.createWavFile(removeLastNSeconds: secs)).item1;
    //     uploadFile(file);
    //   } catch (e) {} // in case was a local recording and not a BLE recording
    // }
    Memory? memory = await processTranscriptContent(
      context,
      TranscriptSegment.segmentsAsString(segments),
      segments,
      file?.path,
      startedAt: currentTranscriptStartedAt,
      finishedAt: currentTranscriptFinishedAt,
      geolocation: await LocationService().getGeolocationDetails(),
      // photos: photos,
      photos: [],
      // TODO: determinePhotosToKeep(photos);
      sendMessageToChat: sendMessageToChat,
    );
    debugPrint(memory.toString());
    // TODO: backup when useful memory created, maybe less later, 2k memories occupy 3MB in the json payload
    if (memory != null && !memory.discarded) executeBackupWithUid();
    context
        .read<MemoryBloc>()
        .add(DisplayedMemory(isNonDiscarded: !memory!.discarded));
    if (!memory.discarded &&
        SharedPreferencesUtil().postMemoryNotificationIsChecked) {
      postMemoryCreationNotification(memory).then((r) {
        // TODO: this should be a plugin instead.
        debugPrint('Notification response: $r');
        if (r.isEmpty) return;
        sendMessageToChat(Message(DateTime.now(), r, 'ai'), memory);
        createNotification(
          notificationId: 2,
          title: 'New Memory Created! ${memory.structured.target!.getEmoji()}',
          body: r,
        );
      });
    }
    await _initiateMemories();
    SharedPreferencesUtil().transcriptSegments = [];
    segments = [];
    setState(() => memoryCreating = false);
    audioStorage?.clearAudioBytes();
    setHasTranscripts(false);

    currentTranscriptStartedAt = null;
    currentTranscriptFinishedAt = null;
    elapsedSeconds = 0;

    streamStartedAtSecond = null;
    firstStreamReceivedAt = null;
    secondsMissedOnReconnect = null;
    // photos = [];
    conversationId = const Uuid().v4();
  }

  Future<void> initiateWebsocket(
      [BleAudioCodec? audioCodec, int? sampleRate]) async {
    // TODO: this will not work with opus for now, more complexity, unneeded rn
    BleAudioCodec codec = audioCodec ??
        (btDevice?.id == null
            ? BleAudioCodec.pcm8
            : await getAudioCodec(btDevice!.id));
    await initWebSocket(
      codec: codec,
      sampleRate: sampleRate,
      onConnectionSuccess: () {
        if (segments.isNotEmpty) {
          // means that it was a reconnection, so we need to reset
          streamStartedAtSecond = null;
          secondsMissedOnReconnect =
              (DateTime.now().difference(firstStreamReceivedAt!).inSeconds);
        }
        setState(() {});
      },
      onConnectionFailed: (err) => setState(() {}),
      onConnectionClosed: (int? closeCode, String? closeReason) {
        // connection was closed, either on resetState, or by backend, or by some other reason.
        setState(() {});
      },
      onConnectionError: (err) {
        // connection was okay, but then failed.
        setState(() {});
      },
      onMessageReceived: (List<TranscriptSegment> newSegments) {
        if (newSegments.isEmpty) return;

        if (segments.isEmpty) {
          debugPrint('newSegments: ${newSegments.last}');
          // TODO: small bug -> when memory A creates, and memory B starts, memory B will clean a lot more seconds than available,
          //  losing from the audio the first part of the recording. All other parts are fine.
          audioStorage?.removeFramesRange(
              fromSecond: 0, toSecond: newSegments[0].start.toInt());
          firstStreamReceivedAt = DateTime.now();
        }
        streamStartedAtSecond ??= newSegments[0].start;

        TranscriptSegment.combineSegments(
          segments,
          newSegments,
          toRemoveSeconds: streamStartedAtSecond ?? 0,
          toAddSeconds: secondsMissedOnReconnect ?? 0,
        );
        triggerTranscriptSegmentReceivedEvents(newSegments, conversationId,
            sendMessageToChat: sendMessageToChat);
        SharedPreferencesUtil().transcriptSegments = segments;
        setHasTranscripts(true);
        debugPrint('Memory creation timer restarted');
        _memoryCreationTimer?.cancel();
        _memoryCreationTimer = Timer(
            const Duration(seconds: quietSecondsForMemoryCreation),
            () => _createMemory());
        currentTranscriptStartedAt ??= DateTime.now();
        currentTranscriptFinishedAt = DateTime.now();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('lenth of this screen ${screens.length}');
    List<Widget> screens = [
      // const Scaffold(
      //   body: Center(
      //     child: Text('capture page'),
      //   ),
      // ),
      // const Scaffold(
      //   body: Center(
      //     child: Text('chat Page'),
      //   ),
      // ),
      CapturePage(
        key: capturePageKey,
        device: _device,
        refreshMemories: _initiateMemories,
        refreshMessages: _refreshMessages,
        // restartWebSocket: restartWebSocket,
        initiateWebsocket: initiateWebsocket,
      ),
      ChatPageTest(
        textFieldFocusNode: chatTextFieldFocusNode,
      ),
      const SettingsPage(),
    ];
    super.build(context);
    // The different screens for the bottom navigation

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
                Center(
                  // Display the selected screen based on the selectedIndex
                  child: screens[_selectedIndex],
                ),
              ],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: TextButton(
              onPressed: () async {
                // if (SharedPreferencesUtil().deviceId.isEmpty) {
                //   routeToPage(context, const ConnectDevicePage());
                //   MixpanelManager().connectFriendClicked();
                // } else {
                //   await routeToPage(context,
                //       const ConnectedDevice(device: null, batteryLevel: 0));
                // }
                // setState(() {});
              },
              // style: TextButton.styleFrom(
              //   padding: EdgeInsets.zero,
              //   backgroundColor: Colors.transparent,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10),
              //     side: const BorderSide(color: Colors.white, width: 1),
              //   ),
              // ),
              child: Image.asset(
                'assets/images/herologo.png',
                width: 60,
                height: 40,
              ),
            ),
            //*-- Chat Plugin --*//
            // title: _selectedIndex == 1
            //     ? DropdownButton<String>(
            //         menuMaxHeight: 350,
            //         value: SharedPreferencesUtil().selectedChatPluginId,
            //         onChanged: (s) async {
            //           if ((s == 'no_selected' &&
            //                   SharedPreferencesUtil().pluginsEnabled.isEmpty) ||
            //               s == 'enable') {
            //             await routeToPage(
            //                 context, const PluginsPage(filterChatOnly: true));
            //             setState(() {});
            //             return;
            //           }
            //           print(
            //               'Selected: $s prefs: ${SharedPreferencesUtil().selectedChatPluginId}');
            //           if (s == null ||
            //               s == SharedPreferencesUtil().selectedChatPluginId) {
            //             return;
            //           }

            //           SharedPreferencesUtil().selectedChatPluginId = s;
            //          plugins.firstWhereOrNull((p) => p.id == s);
            //           // chatPageKey.currentState
            //           //     ?.sendInitialPluginMessage(plugin);
            //           setState(() {});
            //         },
            //         icon: Container(),
            //         alignment: Alignment.center,
            //         dropdownColor: Colors.black,
            //         style: const TextStyle(color: Colors.white, fontSize: 16),
            //         underline: Container(height: 0, color: Colors.transparent),
            //         isExpanded: false,
            //         itemHeight: 48,
            //         padding: EdgeInsets.zero,
            //         items: _getPluginsDropdownItems(context),
            //       )
            //     : const SizedBox.shrink(),
            actions: [
              //* AVM Battery indecator
              _device != null && batteryLevel != -1
                  ? GestureDetector(
                      onTap: _device == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (c) => ConnectedDevice(
                                    device: _device!,
                                    batteryLevel: batteryLevel,
                                  ),
                                ),
                              );
                              MixpanelManager().batteryIndicatorClicked();
                            },
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 10, top: 15, bottom: 15),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(106, 158, 158, 158),
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
            centerTitle: true,
            elevation: 0,
          ),
          // Add the BottomNavigationBar here
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            // onTap: (value) {
            //   Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => Scaffold(
            //             body: Center(
            //               child: Text('data'),
            //             ),
            //           )));
            // },
            onTap: _onItemTapped,
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
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
    super.dispose();
  }

  // @override
  // bool get wantKeepAlive => true;
}
