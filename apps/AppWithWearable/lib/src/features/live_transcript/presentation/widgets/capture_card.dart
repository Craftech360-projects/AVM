import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/pages/capture/location_service.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/data/datasources/ble_connection_datasource.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/live_transcript/live_transcript_bloc.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/utils/audio/wav_bytes.dart';
import 'package:friend_private/utils/features/backups.dart';
import 'package:friend_private/utils/memories/integrations.dart';
import 'package:friend_private/utils/memories/process.dart';
import 'package:friend_private/utils/other/notifications.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class CaptureCard extends StatefulWidget {
  const CaptureCard({super.key});

  @override
  State<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends State<CaptureCard>
    with WebSocketMixin, WidgetsBindingObserver {
  bool get wantKeepAlive => true;

  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  static const quietSecondsForMemoryCreation = 60;

  /// ----
  List<TranscriptSegment> segments = [];

  StreamSubscription? _bleBytesStream;
  WavBytesUtil? audioStorage;

  Timer? _memoryCreationTimer;
  bool memoryCreating = false;

  DateTime? currentTranscriptStartedAt;
  DateTime? currentTranscriptFinishedAt;

  InternetStatus? _internetStatus;
  List<Memory> memories = [];
  List<Message> messages = [];
  late StreamSubscription<InternetStatus> _internetListener;
  bool isGlasses = false;
  String conversationId =
      const Uuid().v4(); // used only for transcript segment plugins

  double? streamStartedAtSecond;
  DateTime? firstStreamReceivedAt;
  int? secondsMissedOnReconnect;

  Future<void> initiateWebsocket(
      [BleAudioCodec? audioCodec, int? sampleRate]) async {
    // TODO: this will not work with opus for now, more complexity, unneeded rn
    BleAudioCodec codec = audioCodec ??
        (btDevice?.id == null
            ? BleAudioCodec.pcm8
            : await BleConnectionDatasource().getAudioCodec(btDevice!.id));
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
        // if (_scrollController.hasClients) {
        //   _scrollController.animateTo(
        //     _scrollController.position.maxScrollExtent,
        //     duration: const Duration(milliseconds: 100),
        //     curve: Curves.easeOut,
        //   );
        // }
        setState(() {});
      },
    );
  }

  Future<void> initiateBytesStreamingProcessing() async {
    if (btDevice == null) return;
    BleAudioCodec codec =
        await BleConnectionDatasource().getAudioCodec(btDevice!.id);
    audioStorage = WavBytesUtil(
        codec: liveTranscriptBloc.state.codec ?? BleAudioCodec.pcm8);
    List<int> rawAudio = liveTranscriptBloc.state.rawAudio;
    // _bleBytesStream = await BleConnectionDatasource().getBleAudioBytesListener(
    //   btDevice!.id,
    //   onAudioBytesReceived: (List<int> value) {
    log('message receiverd ${rawAudio.toString()}');
    if (rawAudio.isEmpty) return;
    audioStorage!.storeFramePacket(rawAudio);
    rawAudio.removeRange(0, 3);
    if (wsConnectionState == WebsocketConnectionStatus.connected) {
      //    debugPrint("Adding audio>>>>>>>>>>>>>,$value");
      websocketChannel?.sink.add(rawAudio);
    }
    //   },
    // );
  }

  int elapsedSeconds = 0;
  void resetState(
      {bool restartBytesProcessing = true, BTDeviceStruct? btDevice}) {
    debugPrint('resetState: $restartBytesProcessing');
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    if (!restartBytesProcessing && (segments.isNotEmpty)) {
      // if (!restartBytesProcessing && (segments.isNotEmpty || photos.isNotEmpty)) {
      _createMemory(forcedCreation: true);
    }
    if (btDevice != null) setState(() => this.btDevice = btDevice);
    if (restartBytesProcessing) {
      // startOpenGlass();
      initiateBytesStreamingProcessing();
      // restartWebSocket(); // DO NOT USE FOR NOW, this ties the websocket to the device, and logic is much more complex
    }
  }

  void restartWebSocket() {
    closeWebSocket();
    initiateWebsocket();
  }

  _refreshMessages() async {
    messages = MessageProvider().getMessages();
    setState(() {});
  }

  _initiateMemories() async {
    memories = MemoryProvider()
        .getMemoriesOrdered(includeDiscarded: true)
        .reversed
        .toList();
    setState(() {});
  }

  void sendMessageToChat(Message message, Memory? memory) {
    if (memory != null) message.memories.add(memory);
    MessageProvider().saveMessage(message);
    _refreshMessages;
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

  setHasTranscripts(bool hasTranscripts) {
    if (_hasTranscripts == hasTranscripts) return;
    setState(() => _hasTranscripts = hasTranscripts);
  }

  processCachedTranscript() async {
    debugPrint('_processCachedTranscript');
    var segments = SharedPreferencesUtil().transcriptSegments;
    if (segments.isEmpty) return;
    String transcript = TranscriptSegment.segmentsAsString(
        SharedPreferencesUtil().transcriptSegments);
    processTranscriptContent(
      context,
      transcript,
      SharedPreferencesUtil().transcriptSegments,
      null,
      retrievedFromCache: true,
      sendMessageToChat: sendMessageToChat,
    ).then((m) {
      if (m != null && !m.discarded) executeBackupWithUid();
    });
    SharedPreferencesUtil().transcriptSegments = [];
    // TODO: include created at and finished at for this cached transcript
  }

  late LiveTranscriptBloc liveTranscriptBloc;
  @override
  void initState() {
    liveTranscriptBloc = BlocProvider.of<LiveTranscriptBloc>(context);
    btDevice = liveTranscriptBloc.state.connectedDevice;
    // btDevice = context.read<LiveTranscriptBloc>().state.connectedDevice;
    WavBytesUtil.clearTempWavFiles();
    initiateWebsocket();
    // startOpenGlass();
    initiateBytesStreamingProcessing();
    processCachedTranscript();

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (await LocationService().displayPermissionsDialog()) {
        showDialog(
          context: context,
          builder: (c) => getDialog(
            context,
            () => Navigator.of(context).pop(),
            () async {
              Navigator.of(context).pop();
              await requestLocationPermission();
            },
            'Enable Location Services?  🌍',
            'We need your location permissions to add a location tag to your memories. This will help you remember where they happened.',
            singleButton: false,
          ),
        );
      }
    });
    _internetListener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          _internetStatus = InternetStatus.connected;
          break;
        case InternetStatus.disconnected:
          _internetStatus = InternetStatus.disconnected;
          // so if you have a memory in progress, it doesn't get created, and you don't lose the remaining bytes.
          _memoryCreationTimer?.cancel();
          break;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // Cancel all listeners, timers, and WebSockets first
    WidgetsBinding.instance.removeObserver(this);
    // record.dispose(); // Make sure this method does not throw errors
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    closeWebSocket();
    _internetListener.cancel();
    // _scrollController.dispose();

    // Ensure this is called last
    super.dispose();
  }

  Future requestLocationPermission() async {
    LocationService locationService = LocationService();
    bool serviceEnabled = await locationService.enableService();
    if (!serviceEnabled) {
      debugPrint('Location service not enabled');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Enable them for a better experience.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        );
      }
    } else {
      PermissionStatus permissionGranted =
          await locationService.requestPermission();
      if (permissionGranted == PermissionStatus.denied) {
        debugPrint('Location permission not granted');
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        debugPrint('Location permission denied forever');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'If you change your mind, you can enable location services in your device settings.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      borderRadius: 40.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40.h),
              child: Image.asset(
                IconImage.avmdevice,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 80.h,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '👋Hi! Joe,\nChange is inevitable. '
                    'Always strive for the next big thing.!',
                    textStyle: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "AVM Status",
              style:
                  textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            ),
            BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
              bloc: context.read<LiveTranscriptBloc>(),
              builder: (context, state) {
                final bool avmDisconnected = state.bluetoothDeviceStatus ==
                    BluetoothDeviceStatus.disconnected;
                return Row(
                  children: [
                    Container(
                      width: 8.h,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: avmDisconnected
                            ? CustomColors.yellowAccent
                            : CustomColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.h),
                    Text(
                      avmDisconnected ? "Disconnected" : "Connected",
                      style: textTheme.bodySmall?.copyWith(
                          color: CustomColors.greyLight, fontSize: 10.h),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
