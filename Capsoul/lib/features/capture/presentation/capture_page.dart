import 'dart:async';
import 'dart:convert';

import 'package:capsoul/backend/api_requests/api/prompt.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/message.dart';
import 'package:capsoul/backend/database/message_provider.dart';
import 'package:capsoul/backend/database/transcript_segment.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/widgets/custom_dialog_box.dart';
import 'package:capsoul/features/capture/logic/openglass_mixin.dart';
import 'package:capsoul/features/capture/presentation/capture_memory_page.dart';
import 'package:capsoul/features/memories/bloc/memory_bloc.dart';
import 'package:capsoul/pages/capture/location_service.dart';
import 'package:capsoul/utils/audio/wals.dart';
import 'package:capsoul/utils/audio/wav_bytes.dart';
import 'package:capsoul/utils/ble/communication.dart';
import 'package:capsoul/utils/features/backup_util.dart';
import 'package:capsoul/utils/features/backups.dart';
import 'package:capsoul/utils/memories/integrations.dart';
import 'package:capsoul/utils/memories/process.dart';
import 'package:capsoul/utils/other/notifications.dart';
import 'package:capsoul/utils/websockets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../../pages/capture/phone_recorder_mixin.dart';
import '../logic/websocket_mixin.dart';

class CapturePage extends StatefulWidget {
  final Function refreshMemories;
  final Function refreshMessages;
  final BTDeviceStruct? device;
  final int batteryLevel;
  final bool hasSeenTutorial;

  const CapturePage({
    super.key,
    required this.device,
    required this.refreshMemories,
    required this.refreshMessages,
    this.batteryLevel = -1,
    required this.hasSeenTutorial,
  });

  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        PhoneRecorderMixin,
        WebSocketMixin,
        OpenGlassMixin {
  final ScrollController _scrollController = ScrollController();
  WalService? _wal;

  @override
  bool get wantKeepAlive => true;
  List<TranscriptSegment> segments = [];
  List<bool> dismissedList = [];
  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  static const defaultQuietSecondsForMemoryCreation = 60;

  StreamSubscription? _bleBytesStream;
  WavBytesUtil? audioStorage;

  Timer? _memoryCreationTimer;
  bool memoryCreating = false;

  bool _isWalSupported = false;

  bool get isWalSupported => _isWalSupported;
  DateTime? currentTranscriptStartedAt;
  DateTime? currentTranscriptFinishedAt;
  static const quietSecondsForMemoryCreation = 60;
  InternetStatus? _internetStatus;

  bool isGlasses = false;
  String conversationId = const Uuid().v4();

  double? streamStartedAtSecond;
  DateTime? firstStreamReceivedAt;
  int? secondsMissedOnReconnect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> getNotificationPluginValue() async {
    // Implement the logic to get the notification plugin value
    return SharedPreferencesUtil().notificationPlugin;
  }

  // ignore: unused_element
  void _pluginNotification() async {
    String transcript = TranscriptSegment.segmentsAsString(segments);
    // Replace with actual transcript
    String friendlyReplyJson = await generateFriendlyReply(transcript);
    var friendlyReplyMap = jsonDecode(friendlyReplyJson);
    debugPrint(friendlyReplyMap.toString());
    String friendlyReply =
        friendlyReplyMap['reply'] ?? 'Default friendly reply';
    // createNotification(
    //   title: 'Notification Title',
    //   body: friendlyReply,
    //   notificationId: 10,
    // );
    createMessagingNotification('AVM', friendlyReply);

    await widget.refreshMemories();
    SharedPreferencesUtil().transcriptSegments = [];
    segments = [];
    if (mounted) {
      setState(() => memoryCreating = false);
    }
    audioStorage?.clearAudioBytes();
    setHasTranscripts(false);

    currentTranscriptStartedAt = null;
    currentTranscriptFinishedAt = null;
    elapsedSeconds = 0;

    streamStartedAtSecond = null;
    firstStreamReceivedAt = null;
    secondsMissedOnReconnect = null;
    photos = [];
    conversationId = const Uuid().v4();
  }

  Future<void> initiateWebsocket(
      [BleAudioCodec? audioCodec, int? sampleRate]) async {
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
        if (mounted) {
          setState(() {});
        }
      },
      onConnectionFailed: (err) => setState(() {}),
      onConnectionClosed: (int? closeCode, String? closeReason) {
        // avmSnackBar(context,
        //     "Connection was lost! Please check your internet connection.");
      },
      onConnectionError: (err) {
        avmSnackBar(context,
            "Connection was lost! Please check your internet connection.");
      },
      onMessageReceived: (List<TranscriptSegment> newSegments) {
        debugPrint("====> Message Received");
        if (newSegments.isEmpty) return;

        if (segments.isEmpty) {
          debugPrint('newSegments: ${newSegments.last}');
          // small bug -> when memory A creates, and memory B starts, memory B will clean a lot more seconds than available,
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

  // Future<void> initiateBytesStreamingProcessing() async {
  //   debugPrint("====> Byte Streaming Initiated");
  //   if (btDevice == null) return;
  //   BleAudioCodec codec = await getAudioCodec(btDevice!.id);
  //   audioStorage = WavBytesUtil(codec: codec);
  //   _bleBytesStream = await getBleAudioBytesListener(
  //     btDevice!.id,
  //     onAudioBytesReceived: (List<int> value) {
  //       if (value.isEmpty) return;
  //       audioStorage!.storeFramePacket(value);
  //       value.removeRange(0, 3);

  //       var checkWalSupported = codec == BleAudioCodec.opus &&
  //           SharedPreferencesUtil().localSyncEnabled;
  //       if (wsConnectionState == WebsocketConnectionStatus.connected) {
  //         // debugPrint("Adding audio>>>>>>>>>>>>>,$value");
  //         print(SharedPreferencesUtil().localSyncEnabled);
  //         websocketChannel?.sink.add(value);
  //         SharedPreferencesUtil().localSyncEnabled;

  //       } else {
  //         print(SharedPreferencesUtil().localSyncEnabled);
  //         debugPrint("Adding audio>>>>>>>>>>>>>,$value");
  //       }
  //     },
  //   );
  // }

//with local sync

  Future<void> initiateBytesStreamingProcessing() async {
    debugPrint("====> Byte Streaming Initiated");
    if (btDevice == null) return;

    BleAudioCodec codec = await getAudioCodec(btDevice!.id);
    audioStorage = WavBytesUtil(codec: codec);

    _bleBytesStream = await getBleAudioBytesListener(
      btDevice!.id,
      onAudioBytesReceived: (List<int> value) {
        if (value.isEmpty) return;

        // Store frame packet for Wav processing
        audioStorage!.storeFramePacket(value);

        // Remove first 3 bytes (if required by your processing logic)
        value.removeRange(0, 3);

        // Check if Wal synchronization is supported
        var checkWalSupported = codec == BleAudioCodec.opus &&
            SharedPreferencesUtil().localSyncEnabled;

        if (checkWalSupported) {
          // Add data to LocalWalSync buffer for periodic flush
          _wal?.getSyncs().onByteStream(value);
        }

        // Handle WebSocket connection
        if (wsConnectionState == WebsocketConnectionStatus.connected) {
          // Send data via WebSocket
          websocketChannel?.sink.add(value);
        } else {
          // Debug output for offline case
          debugPrint("WebSocket disconnected; audio packet: $value");
        }
      },
    );
  }

  int elapsedSeconds = 0;

  Future<void> startOpenGlass() async {
    if (btDevice == null) return;
    // isGlasses = await hasPhotoStreamingCharacteristic(btDevice!.id);
    debugPrint('startOpenGlass isGlasses: $isGlasses');
    if (!isGlasses) return;

    await openGlassProcessing(
        btDevice!, (p) => setState(() {}), setHasTranscripts);
    closeWebSocket();
  }

  void setIsWalSupported(bool value) {
    _isWalSupported = value;
    // notifyListeners();
  }

  void resetState(
      {bool restartBytesProcessing = true, BTDeviceStruct? btDevice}) {
    debugPrint('resetState: $restartBytesProcessing');
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    if (!restartBytesProcessing && (segments.isNotEmpty || photos.isNotEmpty)) {
      _createMemory(forcedCreation: true);
    }
    if (btDevice != null) setState(() => this.btDevice = btDevice);
    if (restartBytesProcessing) {
      startOpenGlass();
      initiateBytesStreamingProcessing();
      // restartWebSocket(); // DO NOT USE FOR NOW, this ties the websocket to the device, and logic is much more complex
    }
  }

  void restartWebSocket() {
    closeWebSocket();
    initiateWebsocket();
  }

  void sendMessageToChat(Message message, Memory? memory) {
    if (memory != null) message.memories.add(memory);
    MessageProvider().saveMessage(message);
    widget.refreshMessages();
  }

  _createMemory({bool forcedCreation = false}) async {
    bool backupsEnabled = SharedPreferencesUtil().backupsEnabled;
    if (memoryCreating) return;

    if (mounted) {
      setState(() {
        memoryCreating = true;
      });
    }

    Memory? memory;
    try {
      memory = await processTranscriptContent(
        context,
        TranscriptSegment.segmentsAsString(segments),
        segments,
        null,
        startedAt: currentTranscriptStartedAt,
        finishedAt: currentTranscriptFinishedAt,
        geolocation: await LocationService().getGeolocationDetails(),
        photos: photos,
        sendMessageToChat: sendMessageToChat,
      );
    } catch (e) {
      debugPrint('Error during memory creation: $e');
      avmSnackBar(context, "Something went wrong while creating the memory.");
    }

    if (memory == null) {
      debugPrint('Memory creation failed, resetting state...');
      setHasTranscripts(false);
      if (mounted) {
        setState(() => memoryCreating = false);
      }
      return;
    }

    if (!memory.discarded) {
      executeBackupWithUid();
      context
          .read<MemoryBloc>()
          .add(DisplayedMemory(isNonDiscarded: !memory.discarded));

      if (!memory.discarded &&
          SharedPreferencesUtil().postMemoryNotificationIsChecked) {
        // postMemoryCreationNotification(memory).then((r) {
        //   debugPrint('Notification response: $r');
        //   if (r.isEmpty) return;
        //   sendMessageToChat(Message(DateTime.now(), r, 'ai'), memory);
        createNotification(
          notificationId: 2,
          title:
              'New Memory Created! ${memory.structured.target?.getEmoji() ?? ''}',
        );
      }
      backupsEnabled ? manualBackup(context) : null; // Call manualBackup here
    }

    await widget.refreshMemories();
    SharedPreferencesUtil().transcriptSegments = [];
    segments = [];

    // Reset the states
    if (mounted) {
      setState(() => memoryCreating = false);
    }

    // Perform cleanup
    audioStorage?.clearAudioBytes();
    setHasTranscripts(false);
    currentTranscriptStartedAt = null;
    currentTranscriptFinishedAt = null;
    elapsedSeconds = 0;
    streamStartedAtSecond = null;
    firstStreamReceivedAt = null;
    secondsMissedOnReconnect = null;
    photos = [];
    conversationId = const Uuid().v4();
  }

  setHasTranscripts(bool hasTranscripts) {
    if (_hasTranscripts == hasTranscripts) return;
    if (mounted) {
      setState(() => _hasTranscripts = hasTranscripts);
    }
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
    // include created at and finished at for this cached transcript
  }

  @override
  void initState() {
    super.initState();
    btDevice = widget.device;
    WavBytesUtil.clearTempWavFiles();
    initiateWebsocket();
    startOpenGlass();
    initiateBytesStreamingProcessing();
    processCachedTranscript();
    // Initialize the WalService
    _wal = WalService();
    _wal?.start(); // Start the Wal service

    dismissedList = List.generate(segments.length, (index) => false);

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (await LocationService().displayPermissionsDialog()) {
        showDialog(
          context: context,
          builder: (c) => CustomDialogWidget(
            icon: Icons.location_on_rounded,
            title: "Enable Location Services? 🌍",
            message:
                "We need your location permissions to add a location tag to your memories. This will help you remember where they happened.",
            yesPressed: () async {
              Navigator.of(context).pop();
              await requestLocationPermission();
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _memoryCreationTimer?.cancel();
    _bleBytesStream?.cancel();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future requestLocationPermission() async {
    LocationService locationService = LocationService();
    bool serviceEnabled = await locationService.enableService();
    if (!serviceEnabled) {
      debugPrint('Location service not enabled');
      if (mounted) {
        avmSnackBar(
            context, "Location services are required to capture memories.");
      }
    } else {
      PermissionStatus permissionGranted =
          await locationService.requestPermission();
      if (permissionGranted == PermissionStatus.denied) {
        debugPrint('Location permission not granted');
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        debugPrint('Location permission denied forever');
        if (mounted) {
          avmSnackBar(context,
              "If you change your mind, you can enable location services in your device settings.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CaptureMemoryPage(
      context: context,
      hasTranscripts: _hasTranscripts,
      wsConnectionState: wsConnectionState,
      device: widget.device,
      internetStatus: _internetStatus,
      segments: segments,
      memoryCreating: memoryCreating,
      photos: photos,
      scrollController: _scrollController,
      onDismissmissedCaptureMemory: (direction) {
        _createMemory();
        setState(() {});
      },
      hasSeenTutorial: widget.hasSeenTutorial,
    );
  }
}
