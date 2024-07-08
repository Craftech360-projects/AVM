// // import 'package:flutter/material.dart';
// // import 'package:AVMe/backend/mixpanel.dart';
// // import 'package:AVMe/backend/preferences.dart';
// // import 'package:AVMe/backend/schema/bt_device.dart';
// // import 'package:AVMe/pages/speaker_id/page.dart';
// // import 'package:AVMe/widgets/device_widget.dart';
// // import 'package:AVMe/widgets/scanning_ui.dart';

// // import 'widgets/transcript.dart';

// // class CapturePage extends StatefulWidget {
// //   final Function refreshMemories;
// //   final BTDeviceStruct? device;

// //   // final int batteryLevel;
// //   final GlobalKey<TranscriptWidgetState> transcriptChildWidgetKey;

// //   const CapturePage({
// //     super.key,
// //     required this.device,
// //     required this.refreshMemories,
// //     required this.transcriptChildWidgetKey,
// //   });

// //   @override
// //   State<CapturePage> createState() => _CapturePageState();
// // }

// // class _CapturePageState extends State<CapturePage>
// //     with AutomaticKeepAliveClientMixin {
// //   bool _hasTranscripts = false;

// //   @override
// //   bool get wantKeepAlive => true;

// //   @override
// //   Widget build(BuildContext context) {
// //     return ListView(children: [
// //       SharedPreferencesUtil().hasSpeakerProfile
// //           ? const SizedBox(height: 16)
// //           : Stack(
// //               children: [
// //                 GestureDetector(
// //                   onTap: () {
// //                     Navigator.of(context).push(MaterialPageRoute(
// //                         builder: (c) => const SpeakerIdPage()));
// //                     MixpanelManager().speechProfileCapturePageClicked();
// //                   },
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey.shade900,
// //                       borderRadius: const BorderRadius.all(Radius.circular(12)),
// //                     ),
// //                     margin: const EdgeInsets.symmetric(
// //                         vertical: 16, horizontal: 24),
// //                     padding: const EdgeInsets.all(16),
// //                     child: const Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Expanded(
// //                           child: Row(
// //                             children: [
// //                               Icon(Icons.multitrack_audio),
// //                               SizedBox(width: 16),
// //                               Text(
// //                                 'Set up speech profile',
// //                                 style: TextStyle(
// //                                     color: Colors.white, fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         Icon(Icons.arrow_forward_ios)
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 Positioned(
// //                   top: 12,
// //                   right: 24,
// //                   child: Container(
// //                     width: 12,
// //                     height: 12,
// //                     decoration: const BoxDecoration(
// //                         color: Colors.red, shape: BoxShape.circle),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //       ..._getConnectedDeviceWidgets(),
// //       TranscriptWidget(
// //           btDevice: widget.device,
// //           key: widget.transcriptChildWidgetKey,
// //           refreshMemories: widget.refreshMemories,
// //           setHasTranscripts: (hasTranscripts) {
// //             if (_hasTranscripts == hasTranscripts) return;
// //             setState(() {
// //               _hasTranscripts = hasTranscripts;
// //             });
// //           }),
// //       const SizedBox(height: 16)
// //     ]);
// //   }

// //   _getConnectedDeviceWidgets() {
// //     if (_hasTranscripts) return [];
// //     if (widget.device == null) {
// //       return [
// //         const DeviceAnimationWidget(
// //           sizeMultiplier: 0.7,
// //         ),
// //         const ScanningUI(
// //             string1: 'Looking for AVMe wearable',
// //             string2: 'Locating your AVMe device.',
// //             string3: 'Keep it near your phone for pairing'),
// //       ];
// //     }
// //     // return [const DeviceAnimationWidget()];
// //     return [
// //       const Center(child: DeviceAnimationWidget(sizeMultiplier: 0.7)),
// //       Center(
// //           child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           const SizedBox(width: 24),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             mainAxisAlignment: MainAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 'Listening',
// //                 style: TextStyle(
// //                     fontFamily: 'SF Pro Display',
// //                     color: Colors.white,
// //                     fontSize: 29.0,
// //                     letterSpacing: 0.0,
// //                     fontWeight: FontWeight.w700,
// //                     height: 1.2),
// //                 textAlign: TextAlign.center,
// //               ),
// //               Text(
// //                 'DEVICE-${widget.device?.id.split('-').last.substring(0, 6)}',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 16.0,
// //                   fontWeight: FontWeight.w500,
// //                   height: 1.5,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               )
// //             ],
// //           ),
// //           const SizedBox(width: 24),
// //           Container(
// //             width: 10,
// //             height: 10,
// //             decoration: const BoxDecoration(
// //               color: Color.fromARGB(255, 0, 255, 8),
// //               shape: BoxShape.circle,
// //             ),
// //           ),
// //         ],
// //       )),
// //       const SizedBox(height: 8),
// //       const Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [],
// //       ),
// //     ];
// //   }
// // }

// import 'package:AVMe/widgets/custom_scaffold.dart';
// import 'package:AVMe/widgets/sin_wave.dart';
// import 'package:flutter/material.dart';
// import 'package:AVMe/backend/mixpanel.dart';
// import 'package:AVMe/backend/preferences.dart';
// import 'package:AVMe/backend/schema/bt_device.dart';
// import 'package:AVMe/pages/speaker_id/page.dart';
// import 'package:AVMe/widgets/device_widget.dart';
// import 'package:AVMe/widgets/scanning_widget.dart';
// import 'package:AVMe/widgets/scanning_ui.dart';
// import 'widgets/transcript.dart';

// class CapturePage extends StatefulWidget {
//   final Function refreshMemories;
//   final BTDeviceStruct? device;
//   final GlobalKey<TranscriptWidgetState> transcriptChildWidgetKey;

//   const CapturePage({
//     super.key,
//     required this.device,
//     required this.refreshMemories,
//     required this.transcriptChildWidgetKey,
//   });

//   @override
//   State<CapturePage> createState() => _CapturePageState();
// }

// class _CapturePageState extends State<CapturePage>
//     with AutomaticKeepAliveClientMixin {
//   bool _hasTranscripts = false;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       body: ListView(
//         children: [
//           SharedPreferencesUtil().hasSpeakerProfile
//               ? const SizedBox(height: 16)
//               : Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (c) => const SpeakerIdPage()));
//                         MixpanelManager().speechProfileCapturePageClicked();
//                       },
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Color.fromARGB(120, 130, 129, 131),
//                               Color.fromARGB(120, 71, 71, 72),
//                               Color.fromARGB(122, 49, 11, 125),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(12)),
//                         ),
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 24),
//                         padding: const EdgeInsets.all(16),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.multitrack_audio),
//                                   SizedBox(width: 16),
//                                   Text(
//                                     'Set up speech profile',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 16),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(Icons.arrow_forward_ios)
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 12,
//                       right: 24,
//                       child: Container(
//                         width: 12,
//                         height: 12,
//                         decoration: const BoxDecoration(
//                             color: Colors.red, shape: BoxShape.circle),
//                       ),
//                     ),
//                   ],
//                 ),
//           ..._getConnectedDeviceWidgets(),
//           TranscriptWidget(
//               btDevice: widget.device,
//               key: widget.transcriptChildWidgetKey,
//               refreshMemories: widget.refreshMemories,
//               setHasTranscripts: (hasTranscripts) {
//                 if (_hasTranscripts == hasTranscripts) return;
//                 setState(() {
//                   _hasTranscripts = hasTranscripts;
//                 });
//               }),
//           const SizedBox(height: 16)
//         ],
//       ),
//     );
//   }

//   _getConnectedDeviceWidgets() {
//     if (_hasTranscripts) return [];
//     if (widget.device == null) {
//       return [
//         const ScanningAnimationWidget(
//           sizeMultiplier: 0.7,
//         ),
//         const ScanningUI(
//             string1: 'Looking for AVMe wearable',
//             string2: 'Locating your AVMe device.',
//             string3: 'Keep it near your phone for pairing'),
//       ];
//     }
//     return [
//       Stack(
//         children: [
//           Center(
//             child: SizedBox(
//               height: 280, // Fixed height container
//               child: Center(
//                 child: SineWaveWidget(sizeMultiplier: 0.7),
//               ),
//             ),
//           ),
//           Positioned.fill(
//             top: 160, // Position the content below the sine wave
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 24),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Listening',
//                         style: TextStyle(
//                             fontFamily: 'SF Pro Display',
//                             color: Colors.white,
//                             fontSize: 29.0,
//                             letterSpacing: 0.0,
//                             fontWeight: FontWeight.w700,
//                             height: 1.2),
//                         textAlign: TextAlign.center,
//                       ),
//                       Text(
//                         'DEVICE-${widget.device?.id.split('-').last.substring(0, 6)}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16.0,
//                           fontWeight: FontWeight.w500,
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: const BoxDecoration(
//                       color: Color.fromARGB(255, 0, 255, 8),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 8),
//       const Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [],
//       ),
//     ];
//   }
// }

import 'package:flutter/material.dart';
import 'package:AVMe/widgets/custom_scaffold.dart';
import 'package:AVMe/widgets/sin_wave.dart';
import 'package:AVMe/backend/mixpanel.dart';
import 'package:AVMe/backend/preferences.dart';
import 'package:AVMe/backend/schema/bt_device.dart';
import 'package:AVMe/pages/speaker_id/page.dart';
import 'package:AVMe/widgets/device_widget.dart';
import 'package:AVMe/widgets/scanning_widget.dart';
import 'package:AVMe/widgets/scanning_ui.dart';
import 'widgets/transcript.dart';

class CapturePage extends StatefulWidget {
  final Function refreshMemories;
  final BTDeviceStruct? device;
  final GlobalKey<TranscriptWidgetState> transcriptChildWidgetKey;

  const CapturePage({
    super.key,
    required this.device,
    required this.refreshMemories,
    required this.transcriptChildWidgetKey,
  });

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage>
    with AutomaticKeepAliveClientMixin {
  bool _hasTranscripts = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: ListView(
        children: [
          SharedPreferencesUtil().hasSpeakerProfile
              ? const SizedBox(height: 16)
              : Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (c) => const SpeakerIdPage()));
                        MixpanelManager().speechProfileCapturePageClicked();
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(120, 130, 129, 131),
                              Color.fromARGB(120, 71, 71, 72),
                              Color.fromARGB(122, 49, 11, 125),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
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
                ),
          ..._getConnectedDeviceWidgets(),
          TranscriptWidget(
              btDevice: widget.device,
              key: widget.transcriptChildWidgetKey,
              refreshMemories: widget.refreshMemories,
              setHasTranscripts: (hasTranscripts) {
                if (_hasTranscripts == hasTranscripts) return;
                setState(() {
                  _hasTranscripts = hasTranscripts;
                });
              }),
          const SizedBox(height: 16)
        ],
      ),
    );
  }

  List<Widget> _getConnectedDeviceWidgets() {
    if (_hasTranscripts) return [];
    if (widget.device == null) {
      return [
        const ScanningAnimationWidget(
          sizeMultiplier: 0.7,
        ),
        const ScanningUI(
            string1: 'Looking for AVMe wearable',
            string2: 'Locating your AVMe device.',
            string3: 'Keep it near your phone for pairing'),
      ];
    }
    return [
      Stack(
        children: [
          Center(
            child: SizedBox(
              height: 280, // Fixed height container
              child: Center(
                child: SineWaveWidget(sizeMultiplier: 0.7),
              ),
            ),
          ),
          Positioned.fill(
            top: 160, // Position the content below the sine wave
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Listening',
                        style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            color: Colors.white,
                            fontSize: 29.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w700,
                            height: 1.2),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'DEVICE-${widget.device?.id.split('-').last.substring(0, 6)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 0, 255, 8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      ),
    ];
  }
}
