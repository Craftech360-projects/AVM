import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:capsaul/backend/api_requests/api/prompt.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/message.dart';
import 'package:capsaul/backend/database/message_provider.dart';
import 'package:capsaul/backend/database/transcript_segment.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/bt_device.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/core/widgets/custom_dialog_box.dart';
import 'package:capsaul/core/widgets/typing_indicator.dart';
import 'package:capsaul/features/capture/logic/openglass_mixin.dart';
import 'package:capsaul/features/capture/presentation/capture_memory_page.dart';
import 'package:capsaul/features/capture/presentation/wals.dart';
import 'package:capsaul/features/capture/widgets/real_time_bot.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/pages/capture/location_service.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:capsaul/utils/audio/wav_bytes.dart';
import 'package:capsaul/utils/ble/communication.dart';
import 'package:capsaul/utils/features/backup_util.dart';
import 'package:capsaul/utils/features/backups.dart';
import 'package:capsaul/utils/memories/integrations.dart';
import 'package:capsaul/utils/memories/process.dart';
import 'package:capsaul/utils/other/notifications.dart';
import 'package:capsaul/utils/websockets.dart';
import 'package:capsaul/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../../pages/capture/phone_recorder_mixin.dart';
import '../logic/websocket_mixin.dart';

class CapturePage extends StatefulWidget {
  final Function? refreshMemories;
  final Function? refreshMessages;
  final BTDeviceStruct? device;
  final int batteryLevel;
  final bool? hasSeenTutorial;

  const CapturePage({
    super.key,
    this.device,
    this.refreshMemories,
    this.refreshMessages,
    this.batteryLevel = -1,
    this.hasSeenTutorial,
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
        OpenGlassMixin,
        TickerProviderStateMixin,
        IWalSyncListener {
  final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;
  List<TranscriptSegment> segments = [];
  List<bool> dismissedList = [];
  BTDeviceStruct? btDevice;
  bool _hasTranscripts = false;
  final bool _isWalSupported = true;
  FocusNode memoriesTextFieldFocusNode = FocusNode(canRequestFocus: true);
  static const defaultQuietSecondsForMemoryCreation = 60;

  final GlobalKey _floatingActionKey = GlobalKey();

  late Animation<double> _animation;
  late AnimationController _animationController;
  bool _isFlippingRight = true;
  bool _switchValue = SharedPreferencesUtil().notificationPlugin;

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

  late WalSyncs _walSyncs; // Will be properly initialized in initState

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
    String friendlyReplyJson = await generateCapsaullyReply(transcript);
    var friendlyReplyMap = jsonDecode(friendlyReplyJson);
    String friendlyReply =
        friendlyReplyMap['reply'] ?? 'Default friendly reply';
    createMessagingNotification('Capsaul', friendlyReply);

    await widget.refreshMemories!();
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
          streamStartedAtSecond = null;
          secondsMissedOnReconnect =
              (DateTime.now().difference(firstStreamReceivedAt!).inSeconds);
        }
        if (mounted) {
          setState(() {});
        }
      },
      onConnectionFailed: (err) {},
      onConnectionClosed: (int? closeCode, String? closeReason) {},
      onConnectionError: (err) {},
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

  // Future streamAudioToWs(String id, BleAudioCodec codec) async {
  //   debugPrint('streamAudioToWs in capture_provider');
  //   _bleBytesStream?.cancel();
  //   _bleBytesStream = await _getBleAudioBytesListener(id,
  //       onAudioBytesReceived: (List<int> value) {
  //     if (value.isEmpty) return;

  //     // command button triggered
  //     if (_voiceCommandSession != null) {
  //       _commandBytes.add(value.sublist(3));
  //     }

  //     // support: opus codec, 1m from the first device connectes
  //     var deviceFirstConnectedAt = _deviceService.getFirstConnectedAt();
  //     var checkWalSupported = codec == BleAudioCodec.opus &&
  //         (deviceFirstConnectedAt != null &&
  //             deviceFirstConnectedAt.isBefore(
  //                 DateTime.now().subtract(const Duration(seconds: 15)))) &&
  //         SharedPreferencesUtil().localSyncEnabled;
  //     if (checkWalSupported != _isWalSupported) {
  //       setIsWalSupported(checkWalSupported);
  //     }
  //     // print(_isWalSupported);

  //     if (_isWalSupported) {
  //       _wal.getSyncs().phone.onByteStream(value);
  //     }
  //     // print('value: $value');
  //     // send ws
  //     if (_socket?.state == SocketServiceState.connected) {
  //       final trimmedValue = value.sublist(3);
  //       _socket?.send(trimmedValue);

  //       // synced
  //       if (_isWalSupported) {
  //         _wal.getSyncs().phone.onBytesSync(value);
  //       }
  //       // print('trimmedValue: $trimmedValue');
  //     }
  //   });
  //   notifyListeners();
  // }

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

        // Handle audio storage and websocket
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

  // Future<void> startOpenGlass() async {
  //   if (btDevice == null) return;
  //   if (!isGlasses) return;

  //   await openGlassProcessing(
  //       btDevice!, (p) => setState(() {}), setHasTranscripts);
  //   closeWebSocket();
  // }

  void resetState(
      {bool restartBytesProcessing = true, BTDeviceStruct? btDevice}) {
    _bleBytesStream?.cancel();
    _memoryCreationTimer?.cancel();
    if (!restartBytesProcessing && (segments.isNotEmpty || photos.isNotEmpty)) {
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

  void sendMessageToChat(Message message, Memory? memory) {
    if (memory != null) message.memories.add(memory);
    MessageProvider().saveMessage(message);
    widget.refreshMessages!();
  }
void createMemory2({String? transcript, bool forcedCreation = true}) async {
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
      transcript ?? TranscriptSegment.segmentsAsString(segments),
      segments,
      null,
      startedAt: currentTranscriptStartedAt,
      finishedAt: currentTranscriptFinishedAt,
      geolocation: await LocationService().getGeolocationDetails(),
      photos: photos,
      sendMessageToChat: sendMessageToChat,
    );

    if (mounted) {
      avmSnackBar(context, "Memory processed successfully!");
    }
  } catch (e) {
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
    executeBackupWithUid();
    if (mounted) {
      context
          .read<MemoryBloc>()
          .add(DisplayedMemory(isNonDiscarded: !memory.discarded));
    }

    if (!memory.discarded &&
        SharedPreferencesUtil().postMemoryNotificationIsChecked) {
      createNotification(
        notificationId: 2,
        title:
            'New Memory Created! ${memory.structured.target?.getEmoji() ?? ''}',
      );
    }
    if (backupsEnabled && mounted) {
      manualBackup(context);
    }
  }

  if (mounted) {
    await widget.refreshMemories!();
    SharedPreferencesUtil().transcriptSegments = [];
    segments = [];

    // Reset the states
    setState(() => memoryCreating = false);

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

      if (mounted) {
        avmSnackBar(context, "Memory processed successfully!");
      }
    } catch (e) {
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
      executeBackupWithUid();
      if (mounted) {
        context
            .read<MemoryBloc>()
            .add(DisplayedMemory(isNonDiscarded: !memory.discarded));
      }

      if (!memory.discarded &&
          SharedPreferencesUtil().postMemoryNotificationIsChecked) {
        createNotification(
          notificationId: 2,
          title:
              'New Memory Created! ${memory.structured.target?.getEmoji() ?? ''}',
        );
      }
      if (backupsEnabled && mounted) {
        manualBackup(context);
      }
    }

    if (mounted) {
      await widget.refreshMemories!();
      SharedPreferencesUtil().transcriptSegments = [];
      segments = [];

      // Reset the states
      setState(() => memoryCreating = false);

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
  }

  setHasTranscripts(bool hasTranscripts) {
    if (_hasTranscripts == hasTranscripts) return;
    if (mounted) {
      setState(() => _hasTranscripts = hasTranscripts);
    }
  }

  processCachedTranscript() async {
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

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              contentPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: br2),
              content: FittedBox(
                fit: BoxFit.scaleDown,
                child: buildPopupContent(
                  setState,
                  _switchValue,
                  (bool value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize _walSyncs with proper listener
    _walSyncs = WalSyncs(this);
    _walSyncs.start(); // Start the WalSync service

    btDevice = widget.device;
    WavBytesUtil.clearTempWavFiles();
    initiateWebsocket();
    //startOpenGlass();
    initiateBytesStreamingProcessing();
    processCachedTranscript();

    dismissedList = List.generate(segments.length, (index) => false);

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (await LocationService().displayPermissionsDialog()) {
        if (!mounted) return;
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isFlippingRight = !_isFlippingRight;
            });
            _animationController.reset();
            _animationController.forward();
          }
        });
      }
    });

    // Start the first flip
    _animationController.forward();
  }

  @override
  void dispose() {
    _walSyncs.stop(); // Stop the WalSync service
    _memoryCreationTimer?.cancel();
    _bleBytesStream?.cancel();
    _scrollController.dispose();
    _animationController.dispose();
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
  void onMissingWalUpdated() {
    // Implement the method from IWalSyncListener
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    super.build(context);
    return CustomScaffold(
      titleSpacing: 10.0,
      centerTitle: false,
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
      showBackBtn: false,
      body: Stack(children: [
        CaptureMemoryPage(
          context: context,
          hasTranscripts: _hasTranscripts,
          wsConnectionState: wsConnectionState,
          device: widget.device,
          segments: segments,
          memoryCreating: memoryCreating,
          photos: photos,
          scrollController: _scrollController,
          onDismissmissedCaptureMemory: (direction) {
            _createMemory();
            setState(() {});
          },
          hasSeenTutorial: true,
        ),
        Positioned(
          bottom: 10,
          right: 0,
          child: Align(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    double flipValue =
                        _isFlippingRight ? _animation.value : -_animation.value;

                    Matrix4 transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(flipValue);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: FloatingActionButton(
                        key: _floatingActionKey,
                        shape: const CircleBorder(),
                        elevation: 8.0,
                        backgroundColor: AppColors.purpleDark,
                        onPressed: _showPopup,
                        child: Image.asset(
                          AppImages.botIcon,
                          width: 45,
                          height: 45,
                        ),
                      ),
                    );
                  },
                ),
                h8,
                if (SharedPreferencesUtil().notificationPlugin)
                  TypingIndicator(),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomNavBar(
            onMemorySearch: (query) {
              BlocProvider.of<MemoryBloc>(context).add(
                SearchMemory(query: query),
              );
            },
          ),
        ),
      ]),
    );
  }
}
