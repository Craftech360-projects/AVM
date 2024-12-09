import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/growthbook.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/capture/connect.dart';
import 'package:friend_private/features/capture/widgets/sin_wave.dart';
import 'package:friend_private/pages/speaker_id/page.dart';
import 'package:friend_private/utils/enums.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:friend_private/widgets/device_widget.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:friend_private/widgets/photos_grid.dart';
import 'package:friend_private/widgets/scanning_ui.dart';
import 'package:friend_private/widgets/transcript.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class CaptureCard extends StatelessWidget {
  const CaptureCard({
    super.key,
    required this.context,
    required this.hasTranscripts,
    this.device,
    required this.wsConnectionState,
    this.internetStatus,
    this.segments,
    this.memoryCreating = false,
    this.photos = const [],
    this.scrollController,
  });

  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final List<Tuple2<String, String>> photos;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (segments!.isNotEmpty) {
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (context) => Stack(
              children: [
                Image.asset(
                  'assets/images/splash.png',
                  fit: BoxFit.fill,
                  width: double.maxFinite,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: getTranscriptWidget(
                          memoryCreating,
                          segments ?? [],
                          photos,
                          device,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: segments == null || segments!.isEmpty
                      ? Text(
                          '👋🏻 Hi ${SharedPreferencesUtil().givenName},\nReady to hear what awesome task you’ve got for me today!',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: segments!.length,
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            TranscriptSegment segment = segments![index];
                            String speakerName = segment.speaker == '0'
                                ? '${SharedPreferencesUtil().givenName}(You)'
                                : 'Speaker: ${segment.speaker}';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  speakerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  utf8.decode(segment.text.toString().codeUnits,
                                      allowMalformed: true),
                                  style: const TextStyle(
                                      letterSpacing: 0.0, color: Colors.grey),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
              GetConnectionStateWidgets(
                context: context,
                hasTranscripts: hasTranscripts,
                wsConnectionState: wsConnectionState,
                device: device,
                internetStatus: internetStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetConnectionStateWidgets extends StatelessWidget {
  const GetConnectionStateWidgets({
    super.key,
    required this.context,
    required this.hasTranscripts,
    this.device,
    required this.wsConnectionState,
    this.internetStatus,
    this.sizeMultiplier = 0.3,
  });

  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final double sizeMultiplier;

  // final RecordingState micRecordState;
  @override
  Widget build(BuildContext context) {
    bool isWifiDisconnected = internetStatus == InternetStatus.disconnected;
    bool isWebsocketError =
        wsConnectionState == WebsocketConnectionStatus.failed ||
            wsConnectionState == WebsocketConnectionStatus.error;

    bool isDeviceDisconnected = device == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(146, 0, 0, 0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: 100,
              width: 100,
              child: Builder(
                builder: (context) {
                  checkBluetoothStatus(context);
                  if (isDeviceDisconnected) {
                    if (SharedPreferencesUtil().deviceId.isEmpty) {
                      return const Icon(
                        Icons.power_off_outlined,
                        size: 40,
                        color: Colors.grey,
                      );
                    } else {
                      return Image.asset('assets/images/device.png');
                    }
                  } else if (isWifiDisconnected || isWebsocketError) {
                    return Lottie.asset(
                      'assets/lottie_animations/no_internet.json',
                      height: 12,
                      width: 12,
                    );
                  } else {
                    return SineWaveWidget(
                      internetStatus: internetStatus,
                      isWifiDisconnected: isWifiDisconnected,
                      isWebsocketError: isWebsocketError,
                      device: device,
                      sizeMultiplier: 0.71,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isWifiDisconnected
              ? 'No Internet'
              : isWebsocketError
                  ? 'Server Issue'
                  : isDeviceDisconnected
                      ? 'Check AVM'
                      : 'Listening...',
          style: const TextStyle(
              fontFamily: 'SF Pro Display',
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 0.0,
              height: 1.2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            isWifiDisconnected || isWebsocketError
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                : isDeviceDisconnected
                    ? Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 242, 0),
                          shape: BoxShape.circle,
                        ),
                      )
                    : Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 0, 255, 9),
                          shape: BoxShape.circle,
                        ),
                      ),
            const SizedBox(width: 8),
            Text(
              isDeviceDisconnected
                  ? 'Disconnected'
                  : '${device?.name ?? ''} ${device?.id.replaceAll(':', '').split('-').last.substring(0, 6) ?? ''}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ],
    );
  }

  Widget _getNoFriendConnectedYet(BuildContext context) {
    return const Center(
        child: Icon(
      Icons.power_off_outlined,
      size: 50,
      color: Colors.grey,
    ));
  }

  void checkBluetoothStatus(BuildContext context) async {
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {}
  }
}

getConnectionStateWidgets(
    BuildContext context,
    bool hasTranscripts,
    BTDeviceStruct? device,
    WebsocketConnectionStatus wsConnectionState,
    InternetStatus? internetStatus,
    {double sizeMultiplier = .3}) {
  if (hasTranscripts) return [];
  if (device == null) {
    return [
      SizedBox(
        height: MediaQuery.of(context).size.height <= 700
            ? 280 * sizeMultiplier
            : 400 * sizeMultiplier,
      ),
      // const DeviceAnimationWidget(sizeMultiplier: 0.7),
      SharedPreferencesUtil().deviceId.isEmpty
          ? _getNoFriendConnectedYet(context)
          : const ScanningUI(),
    ];
  }

  bool isWifiDisconnected = internetStatus == InternetStatus.disconnected;
  bool isWebsocketError =
      wsConnectionState == WebsocketConnectionStatus.failed ||
          wsConnectionState == WebsocketConnectionStatus.error;

  return [
    const Center(child: DeviceAnimationWidget()),
    GestureDetector(
      onTap: isWifiDisconnected || isWebsocketError
          ? () {
              showDialog(
                context: context,
                builder: (c) => getDialog(
                  context,
                  () => Navigator.pop(context),
                  () => Navigator.pop(context),
                  isWifiDisconnected
                      ? 'Internet Connection Lost'
                      : 'Connection Issue',
                  isWifiDisconnected
                      ? 'Your device is offline. Transcription is paused until connection is restored.'
                      : 'Unable to connect to the transcript service. Please restart the app or contact support if the problem persists.',
                  okButtonText: 'Ok',
                  singleButton: true,
                ),
              );
            }
          : null,
      child: SineWaveWidget(
        internetStatus: internetStatus,
        isWifiDisconnected: isWifiDisconnected,
        isWebsocketError: isWebsocketError,
        device: device,
        sizeMultiplier: 0.71,
      ),
    ),
    const SizedBox(height: 8),
  ];
}

_getNoFriendConnectedYet(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 24),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                border: const GradientBoxBorder(
                  gradient: LinearGradient(colors: [
                    Color.fromARGB(127, 208, 208, 208),
                    Color.fromARGB(127, 188, 99, 121),
                    Color.fromARGB(127, 86, 101, 182),
                    Color.fromARGB(127, 126, 190, 236)
                  ]),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://craftech360.com'));
                    MixpanelManager().getFriendClicked();
                  },
                  child: const Text(
                    'Get an AVM',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => const ConnectDevicePage()));
              MixpanelManager().connectFriendClicked();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Connect',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ],
  );
}

speechProfileWidget(
    BuildContext context, StateSetter setState, Function restartWebSocket) {
  return !SharedPreferencesUtil().hasSpeakerProfile &&
          SharedPreferencesUtil().useTranscriptServer
      ? Stack(
          children: [
            GestureDetector(
              onTap: () async {
                MixpanelManager().speechProfileCapturePageClicked();
                bool hasSpeakerProfile =
                    SharedPreferencesUtil().hasSpeakerProfile;
                await routeToPage(context, const SpeakerIdPage());
                setState(() {});
                if (hasSpeakerProfile !=
                        SharedPreferencesUtil().hasSpeakerProfile &&
                    GrowthbookUtil().hasStreamingTranscriptFeatureOn()) {
                  restartWebSocket();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.multitrack_audio),
                          SizedBox(width: 16),
                          Text(
                            'Set up speech profile',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 24,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        )
      : const SizedBox(height: 16);
}

getTranscriptWidget(
  bool memoryCreating,
  List<TranscriptSegment> segments,
  List<Tuple2<String, String>> photos,
  BTDeviceStruct? btDevice,
) {
  if (memoryCreating) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  if (photos.isNotEmpty) return PhotosGridComponent(photos: photos);
  return TranscriptWidget(segments: segments);
}

connectionStatusWidgets(
  BuildContext context,
  List<TranscriptSegment> segments,
  WebsocketConnectionStatus wsConnectionState,
  InternetStatus? internetStatus,
) {
  if (segments.isEmpty) return [];

  bool isWifiDisconnected = internetStatus == InternetStatus.disconnected;
  bool isWebsocketError =
      wsConnectionState == WebsocketConnectionStatus.failed ||
          wsConnectionState == WebsocketConnectionStatus.error;
  if (!isWifiDisconnected && !isWebsocketError) return [];
  return [
    GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (c) => getDialog(
            context,
            () => Navigator.pop(context),
            () => Navigator.pop(context),
            isWifiDisconnected
                ? 'Internet Connection Lost'
                : 'Connection Issue',
            isWifiDisconnected
                ? 'Your device is offline. Transcription is paused until connection is restored.'
                : 'Unable to connect to the transcript service. Please restart the app or contact support if the problem persists.',
            okButtonText: 'Ok',
            singleButton: true,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              isWifiDisconnected ? 'No Internet' : 'Server Issue',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: isWifiDisconnected
                  ? Lottie.asset('assets/lottie_animations/no_internet.json',
                      height: 48, width: 48)
                  : Lottie.asset('assets/lottie_animations/no_internet.json',
                      height: 48, width: 48),
            )
          ],
        ),
      ),
    )
  ];
}

getPhoneMicRecordingButton(
    VoidCallback recordingToggled, RecordingState state) {
  if (SharedPreferencesUtil().deviceId.isNotEmpty) {
    return const SizedBox.shrink();
  }
  return Visibility(
    visible: true,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 128),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // side: BorderSide(color: state == RecordState.record ? Colors.red : Colors.white),
          ),
          onPressed:
              state == RecordingState.initialising ? null : recordingToggled,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                state == RecordingState.initialising
                    ? const SizedBox(
                        height: 8,
                        width: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : (state == RecordingState.record
                        ? const Icon(Icons.stop, color: Colors.red, size: 24)
                        : const Icon(Icons.mic)),
                const SizedBox(width: 8),
                Text(
                  state == RecordingState.initialising
                      ? 'Initialising Recorder'
                      : (state == RecordingState.record
                          ? 'Stop Recording'
                          : 'Try With Phone Mic'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}