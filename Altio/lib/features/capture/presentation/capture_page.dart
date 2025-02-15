import 'dart:async';
import 'dart:convert';

import 'package:altio/backend/api_requests/api/prompt.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/message_provider.dart';
import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/websocket/websockets.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:altio/features/capture/logic/wals.dart';
import 'package:altio/features/capture/presentation/capture_memory_page.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/pages/capture/location_service.dart';
import 'package:altio/utils/audio/wav_bytes.dart';
import 'package:altio/utils/ble/communication.dart';
import 'package:altio/utils/features/backup_util.dart';
import 'package:altio/utils/features/backups.dart';
import 'package:altio/utils/memories/integrations.dart';
import 'package:altio/utils/memories/process.dart';
import 'package:altio/utils/other/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../../backend/websocket/websocket_mixin.dart';
import '../../../pages/capture/phone_recorder_mixin.dart';

class CapturePage extends StatefulWidget {
  final Function refreshMemories;
  final Function refreshMessages;
  final BTDeviceStruct? device;
  final int batteryLevel;
  final bool hasSeenTutorial;
  final TabController? tabController;

  const CapturePage({
    super.key,
    required this.device,
    required this.refreshMemories,
    required this.refreshMessages,
    this.batteryLevel = -1,
    required this.hasSeenTutorial,
    this.tabController,
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
        IWalSyncListener {
  final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;
  List<TranscriptSegment> segments = [];
  List<bool> dismissedList = [];
  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  final bool _isWalSupported = true;
  static const defaultQuietSecondsForMemoryCreation = 60;
  StreamSubscription? _bleBytesStream;
  WavBytesUtil? audioStorage;

  Timer? _memoryCreationTimer;
  bool memoryCreating = false;

  DateTime? currentTranscriptStartedAt;
  DateTime? currentTranscriptFinishedAt;
  static const quietSecondsForMemoryCreation = 60;

  bool isGlasses = false;
  String conversationId = const Uuid().v4();

  double? streamStartedAtSecond;
  DateTime? firstStreamReceivedAt;
  int? secondsMissedOnReconnect;

  static const chunkSizeInSeconds = 60;
  static const flushIntervalInSeconds = 90;

  late WalSyncs _walSyncs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> getNotificationPluginValue() async {
    return SharedPreferencesUtil().notificationPlugin;
  }

  void _pluginNotification() async {
    String transcript = TranscriptSegment.segmentsAsString(segments);
    String friendlyReplyJson = await generateAltioReply(transcript);
    var friendlyReplyMap = jsonDecode(friendlyReplyJson);
    String friendlyReply =
        friendlyReplyMap['reply'] ?? 'Default friendly reply';
    createMessagingNotification('Altio', friendlyReply);

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
    conversationId = const Uuid().v4();
  }

  Future<void> initiateWebsocket(
      [BleAudioCodec? audioCodec, int? sampleRate]) async {
    // this will not work with opus for now, more complexity, unneeded rn
    BleAudioCodec codec = BleAudioCodec.pcm8;

    await initWebSocket(
      codec: codec,
      sampleRate: sampleRate,
      onConnectionSuccess: () {
        if (segments.isNotEmpty) {
          streamStartedAtSecond = null;
          secondsMissedOnReconnect =
              (DateTime.now().difference(firstStreamReceivedAt!).inSeconds);
        }
        if (mounted) {
          setState(() {});
        }
      },
      onConnectionFailed: (err) {
        debugPrint("Websocket connection failed: $err");
      },
      onConnectionClosed: (int? closeCode, String? closeReason) {
        debugPrint("Websocket connection closed: $closeReason");
      },
      onConnectionError: (err) {
        debugPrint("Websocket connection error: $err");
      },
      onMessageReceived: (List<TranscriptSegment> newSegments) async {
        if (newSegments.isEmpty) return;

        if (segments.isEmpty) {
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
        await triggerTranscriptSegmentReceivedEvents(
            newSegments, conversationId,
            sendMessageToChat: sendMessageToChat);
        SharedPreferencesUtil().transcriptSegments = segments;
        setHasTranscripts(true);
        _memoryCreationTimer?.cancel();

        bool notificationPluginValue = await getNotificationPluginValue();
        if (notificationPluginValue) {
          _memoryCreationTimer =
              Timer(const Duration(seconds: 10), () => _pluginNotification());
        } else {
          _memoryCreationTimer = Timer(
            const Duration(seconds: 60),
            () => _createMemory(),
          );
        }
        currentTranscriptStartedAt ??= DateTime.now();
        currentTranscriptFinishedAt = DateTime.now();
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> initiateBytesStreamingProcessing() async {
    if (btDevice == null) return;

    BleAudioCodec codec = await getAudioCodec(btDevice!.id);
    audioStorage = WavBytesUtil(codec: codec);
    _bleBytesStream = await getBleAudioBytesListener(
      btDevice!.id,
      onAudioBytesReceived: (List<int> value) {
        if (value.isEmpty) return;

        // Send to WalSync for immediate processing
        if (_isWalSupported) {
          _walSyncs.phone.onByteStream(value);
        }

        audioStorage!.storeFramePacket(value);
        List<int> trimmedValue = List<int>.from(value);
        trimmedValue.removeRange(0, 3);
        if (wsConnectionState == WebsocketConnectionStatus.connected) {
          websocketChannel?.sink.add(trimmedValue);
        }
      },
    );
  }

  int elapsedSeconds = 0;

  void resetState(
      {bool restartBytesProcessing = true, BTDeviceStruct? btDevice}) {
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    if (!restartBytesProcessing && (segments.isNotEmpty)) {
      _createMemory(forcedCreation: true);
    }
    if (btDevice != null) setState(() => this.btDevice = btDevice);
    if (restartBytesProcessing) {
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
      final geolocation = await LocationService().getGeolocationDetails();
      if (!mounted) return;
      memory = await processTranscriptContent(
        context,
        TranscriptSegment.segmentsAsString(segments),
        segments,
        null,
        startedAt: currentTranscriptStartedAt,
        finishedAt: currentTranscriptFinishedAt,
        geolocation: geolocation,
        sendMessageToChat: sendMessageToChat,
      );
    } on Exception catch (e) {
      debugPrint("Error creating memory: $e");
      if (mounted) {
        avmSnackBar(context, "Something went wrong while creating the memory.");
      }
    }
    if (memory == null) {
      setHasTranscripts(false);
      if (mounted) {
        setState(() => memoryCreating = false);
      }
      return;
    }

    if (!memory.discarded) {
      await executeBackupWithUid();
      if (!mounted) return;
      context
          .read<MemoryBloc>()
          .add(DisplayedMemory(isNonDiscarded: !memory.discarded));

      if (!memory.discarded &&
          SharedPreferencesUtil().postMemoryNotificationIsChecked) {
        createNotification(
          notificationId: 2,
          title:
              'New Memory Created! ${memory.structured.target?.getEmoji() ?? ''}',
        );
      }
      unawaited(backupsEnabled ? manualBackup(context) : null);
    }

    await widget.refreshMemories();
    SharedPreferencesUtil().transcriptSegments = [];
    segments = [];

    // Reset the states
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
    conversationId = const Uuid().v4();
  }

  void setHasTranscripts(bool hasTranscripts) {
    if (_hasTranscripts == hasTranscripts) return;
    if (mounted) {
      setState(() => _hasTranscripts = hasTranscripts);
    }
  }

  void processCachedTranscript() async {
    var segments = SharedPreferencesUtil().transcriptSegments;
    if (segments.isEmpty) return;
    String transcript = TranscriptSegment.segmentsAsString(
        SharedPreferencesUtil().transcriptSegments);
    if (!mounted) return;
    await processTranscriptContent(
      context,
      transcript,
      SharedPreferencesUtil().transcriptSegments,
      null,
      retrievedFromCache: true,
      sendMessageToChat: sendMessageToChat,
    ).then((m) {
      if (m != null && !m.discarded) {
        if (mounted) {
          executeBackupWithUid();
        }
      }
    });
    SharedPreferencesUtil().transcriptSegments = [];
    // include created at and finished at for this cached transcript
  }

  @override
  void initState() {
    super.initState();

    _walSyncs = WalSyncs(this);
    _walSyncs.start();

    btDevice = widget.device;

    WavBytesUtil.clearTempWavFiles();
    initiateWebsocket();
    initiateBytesStreamingProcessing();
    processCachedTranscript();

    dismissedList = List.generate(segments.length, (index) => false);

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (await LocationService().displayPermissionsDialog()) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (c) => CustomDialogWidget(
            icon: Icons.location_on_rounded,
            title: "Enable Location Services? 🌍",
            message:
                "We need your location permissions to add a location tag to your memories. This will help you remember where they happened.",
            yesPressed: () async {
              if (!mounted) return;
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
    _walSyncs.stop();
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
      if (mounted) {
        avmSnackBar(
            context, "Location services are required to capture memories.");
      }
    } else {
      PermissionStatus permissionGranted =
          await locationService.requestPermission();
      if (permissionGranted == PermissionStatus.denied) {
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        if (mounted) {
          avmSnackBar(context,
              "If you change your mind, you can enable location services in your device settings.");
        }
      }
    }
  }

  @override
  void onMissingWalUpdated() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!mounted) return Container();
    return CaptureMemoryPage(
      context: context,
      tabController: widget.tabController,
      hasTranscripts: _hasTranscripts,
      device: widget.device,
      segments: segments,
      memoryCreating: memoryCreating,
      scrollController: _scrollController,
      onDismissmissedCaptureMemory: (direction) {
        _createMemory();
        if (mounted) {
          setState(() {});
        }
      },
      hasSeenTutorial: widget.hasSeenTutorial,
    );
  }

  @override
  @override
  bool isInternetAvailable() {
    return wsConnectionState == WebsocketConnectionStatus.connected;
  }
}
