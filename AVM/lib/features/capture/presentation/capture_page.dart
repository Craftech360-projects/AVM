import 'dart:async';
import 'dart:convert';

import 'package:avm/backend/api_requests/api/prompt.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/message.dart';
import 'package:avm/backend/database/message_provider.dart';
import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/features/capture/logic/openglass_mixin.dart';
import 'package:avm/features/capture/presentation/capture_memory_page.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/pages/capture/location_service.dart';
import 'package:avm/utils/audio/wav_bytes.dart';
import 'package:avm/utils/ble/communication.dart';
import 'package:avm/utils/features/backups.dart';
import 'package:avm/utils/memories/integrations.dart';
import 'package:avm/utils/memories/process.dart';
import 'package:avm/utils/other/notifications.dart';
import 'package:avm/utils/websockets.dart';
import 'package:avm/widgets/custom_dialog_box.dart';
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
  const CapturePage({
    super.key,
    required this.device,
    required this.refreshMemories,
    required this.refreshMessages,
    this.batteryLevel = -1,
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
  @override
  bool get wantKeepAlive => true;

  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  static const defaultQuietSecondsForMemoryCreation = 60;

  List<TranscriptSegment> segments = [];
  static final isNotificationEnabled =
      SharedPreferencesUtil().notificationPlugin;
  int quietSecondsForMemoryCreation = isNotificationEnabled ? 10 : 60;
  StreamSubscription? _bleBytesStream;
  WavBytesUtil? audioStorage;

  Timer? _memoryCreationTimer;
  bool memoryCreating = false;

  DateTime? currentTranscriptStartedAt;
  DateTime? currentTranscriptFinishedAt;

  InternetStatus? _internetStatus;

  bool isGlasses = false;
  String conversationId =
      const Uuid().v4(); // used only for transcript segment plugins

  double? streamStartedAtSecond;
  DateTime? firstStreamReceivedAt;
  int? secondsMissedOnReconnect;

  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<bool> getNotificationPluginValue() async {
    // Implement the logic to get the notification plugin value
    return SharedPreferencesUtil().notificationPlugin;
  }

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
    // this will not work with opus for now, more complexity, unneeded rn
    BleAudioCodec codec = BleAudioCodec.pcm8;

    await initWebSocket(
      codec: codec,
      sampleRate: sampleRate,
      onConnectionSuccess: () {
        if (segments.isNotEmpty) {
          debugPrint("====> Segment Not Empty");
          // means that it was a reconnection, so we need to reset
          streamStartedAtSecond = null;
          secondsMissedOnReconnect =
              (DateTime.now().difference(firstStreamReceivedAt!).inSeconds);
        }
        if (mounted) {
          setState(() {});
        }
      },
      onConnectionFailed: (err) {
        if (mounted) {
          setState(() {
            debugPrint("====> Connection Failed");
          });
        }
      },
      onConnectionClosed: (int? closeCode, String? closeReason) {
        debugPrint("====> Connection Closed");
        if (mounted) {
          setState(() {});
        }
      },
      onConnectionError: (err) {
        debugPrint("====> Connection Error");
        if (mounted) {
          setState(() {});
        }
      },
      onMessageReceived: (List<TranscriptSegment> newSegments) async {
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
        _memoryCreationTimer?.cancel();

        bool notificationPluginValue = await getNotificationPluginValue();
        if (notificationPluginValue) {
          _memoryCreationTimer =
              Timer(Duration(seconds: 10), () => _pluginNotification());
        } else {
          _memoryCreationTimer = Timer(
            Duration(seconds: 60),
            () => _createMemory(),
          );
        }
        currentTranscriptStartedAt ??= DateTime.now();
        currentTranscriptFinishedAt = DateTime.now();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
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
    print('initiateBytesStreamingProcessing');
    if (btDevice == null) return;
    BleAudioCodec codec = await getAudioCodec(btDevice!.id);
    audioStorage = WavBytesUtil(codec: codec);
    _bleBytesStream = await getBleAudioBytesListener(
      btDevice!.id,
      onAudioBytesReceived: (List<int> value) {
        if (value.isEmpty) return;
        audioStorage!.storeFramePacket(value);
        value.removeRange(0, 3);
        if (wsConnectionState == WebsocketConnectionStatus.connected) {
          websocketChannel?.sink.add(value);
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

  void resetState(
      {bool restartBytesProcessing = true, BTDeviceStruct? btDevice}) {
    debugPrint('resetState: $restartBytesProcessing');
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    if (!restartBytesProcessing && (segments.isNotEmpty || photos.isNotEmpty)) {
      _createMemory(forcedCreation: true);
    }
    if (btDevice != null) {
      if (mounted) {
        setState(() => this.btDevice = btDevice);
      }
    }
    if (restartBytesProcessing) {
      startOpenGlass();
      initiateBytesStreamingProcessing();
      // restartWebSocket(); // DO NOT USE FOR NOW, this ties the websocket to the device, and logic is much more complex
    }
  }

  void restartWebSocket() {
    closeWebSocket();
    initiateWebsocket();
    initiateBytesStreamingProcessing();
  }

  void sendMessageToChat(Message message, Memory? memory) {
    if (memory != null) message.memories.add(memory);
    MessageProvider().saveMessage(message);
    widget.refreshMessages();
  }

  _createMemory({bool forcedCreation = false}) async {
    if (memoryCreating) return;
    // should clean variables here? and keep them locally?
    if (mounted) {
      setState(() => memoryCreating = true);
    }
    Memory? memory;
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

    // if (memory != null && !memory.discarded) executeBackupWithUid();
    context
        .read<MemoryBloc>()
        .add(DisplayedMemory(isNonDiscarded: !memory!.discarded));
    if (!memory.discarded &&
        SharedPreferencesUtil().postMemoryNotificationIsChecked) {
      debugPrint('Memory is not discarded and notifications are enabled.');

      // Log memory details
      debugPrint('Memory Details: ${memory.toString()}');

      postMemoryCreationNotification(memory).then((r) {
        debugPrint('Notification response received: $r');
        // this should be a plugin instead.

        if (r.isEmpty) {
          debugPrint('Notification response is empty. Exiting.');
          return;
        }
        debugPrint('Sending message to chat with response: $r');
        sendMessageToChat(
          Message(DateTime.now(), r, 'ai'),
          memory,
        );

        debugPrint('Creating notification with title and body.');
        createNotification(
          notificationId: 2,
          title:
              'New Memory Created! ${memory?.structured.target?.getEmoji() ?? ''}',
          body: r,
        );
      }).catchError((error) {
        // Log any errors that occur during the notification process
        debugPrint('Error during postMemoryCreationNotification: $error');
      });
    }

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
        _scaffoldMessenger?.showSnackBar(
          SnackBar(
            content: Text(
                "Location services are disabled. Enable them for a better experience."),
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
          _scaffoldMessenger?.showSnackBar(
            SnackBar(
              content: Text(
                  "If you change your mind, you can enable location services in your device settings."),
            ),
          );
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
        // setState(() {});
      },
    );
  }
}
