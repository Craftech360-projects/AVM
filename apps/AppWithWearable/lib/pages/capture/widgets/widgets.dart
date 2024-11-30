import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/growthbook.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/pages/capture/connect.dart';
import 'package:friend_private/pages/capture/widgets/sin_wave.dart';
import 'package:friend_private/pages/speaker_id/page.dart';
import 'package:friend_private/src/core/constant/constant.dart';
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
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
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
                          '👋🏻 Hi! ${SharedPreferencesUtil().givenName},\nReady to hear what awesome task you’ve got for me today!',
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
                                  // segment.isUser
                                  //     ? SharedPreferencesUtil()
                                  //             .givenName
                                  //             .isNotEmpty
                                  //         ? SharedPreferencesUtil().givenName
                                  //         : 'You'
                                  //     : 'Speaker ${segment.speaker}',
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
                                // const SizedBox(height: 10),
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
                // Lottie.asset('assets/lottie_animations/no_internet.json',
                //     height: 16, width: 16)
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
      // Check for Bluetooth status on Android
      // if (await FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      //   showTopSnackBar(
      //     Overlay.of(context),
      //     const CustomSnackBar.error(
      //       message: "Bluetooth Disconnected",
      //     ),
      //   );
      // }
      // else{
      //    showTopSnackBar(
      //     Overlay.of(context),
      //     const CustomSnackBar.success(
      //       message: "Bluetooth Connected",
      //     ),
      //   );
      // }
    } else if (Platform.isIOS) {
      // Check for Bluetooth status on iOS
      // if (await FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      //   showTopSnackBar(
      //     Overlay.of(context),
      //     const CustomSnackBar.error(
      //       message: "Bluetooth Disconnected",
      //     ),
      //   );
      // }
      // else{
      //    showTopSnackBar(
      //     Overlay.of(context),
      //     const CustomSnackBar.success(
      //       message: "Bluetooth Connected",
      //     ),
      //   );
      // }
    }
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
          : const ScanningUI(
              // string1: 'Looking for AVM wearable',
              // string2:
              //     'Locating your AVM device. Keep it near your phone for pairing',
              ),
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
      // child: Lottie.asset('assets/lottie_animations/ani.json'),
    ),
    const SizedBox(height: 8),
    // const Row(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [],
    // ),
  ];
}

_getNoFriendConnectedYet(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 24),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // const Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 32),
          //     child: Text(
          //       'Get a Friend wearable to start capturing your memories.',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(color: Colors.white, fontSize: 18),
          //     )),
          // const SizedBox(height: 32),
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
      // const Text(
      //   'Or you can use your phone as\nthe audio source 👇',
      //   style: TextStyle(color: Colors.white, fontSize: 18),
      //   textAlign: TextAlign.center,
      // ),
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
  print('abcd $recordingToggled');
  print('abcd $state');
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

class GreetingCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isDisconnected;
  final BuildContext context;
  final bool hasTranscripts;
  // Changed from ConnectionState to WebsocketConnectionStatus
  final WebsocketConnectionStatus wsConnectionState;
  final BTDeviceStruct? device; // Changed to match CaptureCard
  final InternetStatus? internetStatus; // Made nullable to match CaptureCard
  final List<TranscriptSegment>? segments; // Changed to match CaptureCard type
  final bool memoryCreating;
  final List<Tuple2<String, String>>
      photos; // Changed to match CaptureCard type
  final ScrollController?
      scrollController; // Made nullable to match CaptureCard

  const GreetingCard({
    Key? key,
    required this.name,
    required this.isDisconnected,
    required this.context,
    required this.hasTranscripts,
    required this.wsConnectionState,
    this.device,
    this.internetStatus,
    this.segments,
    this.memoryCreating = false,
    this.photos = const [],
    this.scrollController,
    this.avatarUrl,
  }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool isDeviceDisconnected = device == null;
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with avatar and greeting
//             Row(
//               children: [
//                 // Avatar
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey[200],
//                   ),
//                   child: avatarUrl != null
//                       ? ClipOval(
//                           child: Image.network(
//                             avatarUrl!,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Icon(Icons.person,
//                                   color: Colors.grey);
//                             },
//                           ),
//                         )
//                       : const Icon(Icons.person, color: Colors.grey),
//                 ),
//                 const SizedBox(width: 12),

//                 // Greeting text with wave emoji
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       AnimatedTextKit(
//                         animatedTexts: [
//                           TyperAnimatedText(
//                             SharedPreferencesUtil().givenName != null
//                                 ? '👋 Hi! ${SharedPreferencesUtil().givenName},\nChange is inevitable. '
//                                     'Always strive for the next big thing!'
//                                 : '👋 Hi! Guest,\nChange is inevitable. '
//                                     'Always strive for the next big thing!',
//                             textStyle: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                         repeatForever: true, // Keep animating infinitely
//                         pause: const Duration(milliseconds: 500),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Divider
//             Container(height: 2, color: CustomColors.purpleDark),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (segments != null && segments!.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   AnimatedTextKit(
//                     animatedTexts: [
//                       TyperAnimatedText(
//                         'Swipe to create memory',
//                         textStyle: TextStyle(
//                           color: Colors.grey[300],
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         speed:
//                             const Duration(milliseconds: 100), // Typing speed
//                       ),
//                     ],
//                     repeatForever: true, // Keep animating infinitely
//                     pause: const Duration(
//                         milliseconds: 500), // Pause between animations
//                   ),
//                 ],
//               ],
//             ),

//             // Connection Status
//             Padding(
//               padding: const EdgeInsets.only(top: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment
//                     .spaceBetween, // Distribute items to both ends
//                 children: [
//                   // Left Status: INTERNET Connection

//                   Row(
//                     children: [
//                       if (internetStatus != null)
//                         Container(
//                           width: 6,
//                           height: 6,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: internetStatus == InternetStatus.connected
//                                 ? Colors.green
//                                 : Colors.red,
//                           ),
//                         ),
//                       const SizedBox(width: 12),
//                       // : ${internetStatus.toString().split('.').last}
//                       Text(
//                         'Internet',
//                         style: TextStyle(
//                           color: internetStatus == InternetStatus.connected
//                               ? Colors.green
//                               : Colors.red,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Right Status: DEVICE Status
//                   Row(
//                     children: [
//                       Container(
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isDeviceDisconnected
//                               ? Colors.amber
//                               : Colors.green,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         isDeviceDisconnected
//                             ? 'Disconnected'
//                             : '${device?.name ?? ''} ${device?.id.replaceAll(':', '').split('-').last.substring(0, 6) ?? ''}',
//                         style: TextStyle(
//                           color: isDeviceDisconnected
//                               ? Colors.amber
//                               : Colors.green,
//                           fontSize: 12,
//                           height: 1.5,
//                         ),
//                         overflow: TextOverflow.fade,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    bool isDeviceDisconnected = device == null;
    return GestureDetector(
        onTap: () {
          print(internetStatus);
          if (segments != null && segments!.isNotEmpty) {
            showModalBottomSheet(
              useSafeArea: true,
              isScrollControlled: true,
              context: context,
              builder: (context) => Stack(
                children: [
                  Image.asset(
                    'assets/images/bg_image.png',
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
        child: Padding(
          // Add padding for margin-like behavior
          padding: const EdgeInsets.all(8.0), // Margin of 16 from all sides
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade200,
                  Colors.blueGrey.shade200,
                ], // Gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              // border: Border.all(
              //   // Add white border here
              //   color: Colors.white,
              //   width: 3,
              // ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors
                  .transparent, // Transparent to show the gradient background
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and greeting
                    Row(
                      children: [
                        // Avatar

                        // Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     color: Colors.grey[200],
                        //   ),
                        //   child: avatarUrl != null
                        //       ? ClipOval(
                        //           child: Image.network(
                        //             avatarUrl!,
                        //             fit: BoxFit.cover,
                        //             errorBuilder: (context, error, stackTrace) {
                        //               return const Icon(Icons.person,
                        //                   color: Colors.grey);
                        //             },
                        //           ),
                        //         )
                        //       : const Icon(Icons.person, color: Colors.grey),
                        // ),
                        const SizedBox(width: 12),

                        // Greeting text with wave emoji
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '👋 Hi! ${SharedPreferencesUtil().givenName ?? "Guest"},',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600, // Regular weight
                                  fontFamily:
                                      'Montserrat-Bold', // Built-in material design font
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Change is inevitable. Always strive for the next big thing!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600, // Regular weight
                                  fontFamily:
                                      'Montserrat-Bold', // Built-in material design font
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Container(height: 1, color: CustomColors.purpleDark),

                    // Swipe message
                    if (segments != null && segments!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Swipe to create memory',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 31, 31, 31),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    // CustomSnackBar.info(
                    //     maxLines: 6,
                    //     // textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    //     message:
                    //         "Audio processing failed due to noise \n Please try again in a \n quieter place!",
                    //    ),
                    // Connection Status
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Status: INTERNET Connection
                          Row(
                            children: [
                              if (internetStatus != null)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: InternetStatus.connected ==
                                            InternetStatus.connected
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Text(
                                'Internet',
                                style: TextStyle(
                                  color: InternetStatus.connected ==
                                          InternetStatus.connected
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // Right Status: DEVICE Status
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDeviceDisconnected
                                      ? Colors.amber
                                      : Colors.green,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isDeviceDisconnected
                                    ? 'Disconnected'
                                    : '${device?.name ?? ''} ${device?.id.replaceAll(':', '').split('-').last.substring(0, 6) ?? ''}',
                                style: TextStyle(
                                  color: isDeviceDisconnected
                                      ? Colors.amber
                                      : Colors.green,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}


  // child: Card(
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //   ),
      //   color: CustomColors.card,
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         // Header with avatar and greeting
      //         Row(
      //           children: [
      //             // Avatar
      //             Container(
      //               width: 40,
      //               height: 40,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.circle,
      //                 color: Colors.grey[200],
      //               ),
      //               child: avatarUrl != null
      //                   ? ClipOval(
      //                       child: Image.network(
      //                         avatarUrl!,
      //                         fit: BoxFit.cover,
      //                         errorBuilder: (context, error, stackTrace) {
      //                           return const Icon(Icons.person,
      //                               color: Colors.grey);
      //                         },
      //                       ),
      //                     )
      //                   : const Icon(Icons.person, color: Colors.grey),
      //             ),
      //             const SizedBox(width: 12),

      //             // Greeting text with wave emoji
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   AnimatedTextKit(
      //                     animatedTexts: [
      //                       TyperAnimatedText(
      //                         SharedPreferencesUtil().givenName != null
      //                             ? '👋 Hi! ${SharedPreferencesUtil().givenName},\nChange is inevitable. '
      //                                 'Always strive for the next big thing!'
      //                             : '👋 Hi! Guest,\nChange is inevitable. '
      //                                 'Always strive for the next big thing!',
      //                         textStyle: TextStyle(
      //                           fontSize: 16,
      //                           color: Colors.white,
      //                           fontWeight: FontWeight.w500,
      //                         ),
      //                       ),
      //                     ],
      //                     repeatForever: false,
      //                     //  pause: const Duration(milliseconds: 500),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),

      //         const SizedBox(height: 16),

      //         // Divider
      //         Container(height: 2, color: CustomColors.purpleDark),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             if (segments != null && segments!.isNotEmpty) ...[
      //               const SizedBox(height: 16),
      //               AnimatedTextKit(
      //                 animatedTexts: [
      //                   TyperAnimatedText(
      //                     'Swipe to create memory',
      //                     textStyle: TextStyle(
      //                       color: Colors.grey[300],
      //                       fontSize: 14,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                     speed: const Duration(milliseconds: 100),
      //                   ),
      //                 ],
      //                 repeatForever: true,
      //                 pause: const Duration(milliseconds: 500),
      //               ),
      //             ],
      //           ],
      //         ),

      //         // Connection Status
      //         Padding(
      //           padding: const EdgeInsets.only(top: 12),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               // Left Status: INTERNET Connection
      //               Row(
      //                 children: [
      //                   if (internetStatus != null)
      //                     Container(
      //                       width: 6,
      //                       height: 6,
      //                       decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         color: internetStatus == InternetStatus.connected
      //                             ? Colors.green
      //                             : Colors.red,
      //                       ),
      //                     ),
      //                   const SizedBox(width: 12),
      //                   Text(
      //                     'Internet',
      //                     style: TextStyle(
      //                       color: internetStatus == InternetStatus.connected
      //                           ? Colors.green
      //                           : Colors.red,
      //                       fontSize: 14,
      //                     ),
      //                   ),
      //                 ],
      //               ),

      //               // Right Status: DEVICE Status
      //               Row(
      //                 children: [
      //                   Container(
      //                     width: 6,
      //                     height: 6,
      //                     decoration: BoxDecoration(
      //                       shape: BoxShape.circle,
      //                       color: isDeviceDisconnected
      //                           ? Colors.amber
      //                           : Colors.green,
      //                     ),
      //                   ),
      //                   const SizedBox(width: 6),
      //                   Text(
      //                     isDeviceDisconnected
      //                         ? 'Disconnected'
      //                         : '${device?.name ?? ''} ${device?.id.replaceAll(':', '').split('-').last.substring(0, 6) ?? ''}',
      //                     style: TextStyle(
      //                       color: isDeviceDisconnected
      //                           ? Colors.amber
      //                           : Colors.green,
      //                       fontSize: 12,
      //                       height: 1.5,
      //                     ),
      //                     overflow: TextOverflow.fade,
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),