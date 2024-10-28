import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/custom_prompt_page.dart';
import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
import 'package:friend_private/utils/ble/communication.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> with WebSocketMixin {
  bool developerEnabled = false;
  bool isModeSelected = false;
  bool isPromptSaved = false;

  @override
  void initState() {
    super.initState();
    developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
    isPromptSaved = SharedPreferencesUtil().isPromptSaved;
  }

  // void developerModeSelected({required String modeSelected}) {
  //   setState(() {
  //     isModeSelected = true;
  //     SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
  //   });
  // }

  void _setDefaultPrompt() {
    setState(() {
      PromptProvider().removeAllPrompts();
      SharedPreferencesUtil().isPromptSaved = false;
      isPromptSaved = false;
    });
  }

  void _customizePrompt() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CustomPromptPage(),
      ),
    )
        .then((_) {
      setState(() {
        isPromptSaved = SharedPreferencesUtil().isPromptSaved;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String apiType =
        SharedPreferencesUtil().getApiType('NewApiKey') ?? '';

    return CustomScaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Developer\'s Option'),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 16),
                      Text(
                        'Enable Developer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: developerEnabled,
                    onChanged: _onSwitchChanged,
                  ),
                ],
              ),
            ),
          ),
          if (!developerEnabled)
            const Text(
              'By Enabling Developer Mode\nYou can customize prompt\'s & Transcript Services',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          if (!developerEnabled) const SizedBox(height: 24),
          if (developerEnabled)
            Visibility(
              visible: developerEnabled,
              child: ListView(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  CustomExpansionTile(
                    title: 'Transcript Service',
                    subtitle:
                        SharedPreferencesUtil().getApiType('NewApiKey') ?? '',
                    children: [
                      ListTile(
                        leading: apiType == 'Deepgram'
                            ? const Icon(
                                Icons.done_all_rounded,
                                color: Colors.green,
                                size: 18,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                        title: const Text('Deepgram'),
                        onTap: () async {
                          await closeWebSocket2();
                          // developerModeSelected(modeSelected: 'Deepgram');
                          // closeWebSocket();
                          //   closeWebSocket2();
                          developerModeSelected(modeSelected: 'Deepgram');

                          await initWebSocket(
                            onConnectionClosed:
                                (int? closeCode, String? closeReason) {
                              setState(() {});
                            },
                            onConnectionSuccess: () {
                              setState(() {});
                            },
                            onConnectionError: (p1) {},
                            onConnectionFailed: (p1) {},
                            onMessageReceived: (List<TranscriptSegment> p1) {},
                          );
                        },
                      ),
                      ListTile(
                        leading: apiType == 'Sarvam'
                            ? const Icon(
                                Icons.done_all_rounded,
                                color: Colors.green,
                                size: 18,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                        title: const Text('Sarvam'),
                        onTap: () async {
                          // developerModeSelected(modeSelected: 'Sarvam');
                          // closeWebSocket();
                          await closeWebSocket2();
                          developerModeSelected(modeSelected: 'Sarvam');
                          await initWebSocket(
                            onConnectionClosed:
                                (int? closeCode, String? closeReason) {
                              setState(() {});
                            },
                            onConnectionSuccess: () {
                              setState(() {});
                            },
                            onConnectionError: (p1) {},
                            onConnectionFailed: (p1) {},
                            onMessageReceived: (List<TranscriptSegment> p1) {},
                          );
                        },
                      ),
                      ListTile(
                        leading: apiType == 'Whisper'
                            ? const Icon(
                                Icons.done_all_rounded,
                                color: Colors.green,
                                size: 18,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                        title: const Text('Whisper'),
                        onTap: () async {
                          await closeWebSocket2();
                          developerModeSelected(modeSelected: 'Whisper');
                          await initWebSocket(
                            onConnectionClosed:
                                (int? closeCode, String? closeReason) {
                              setState(() {});
                            },
                            onConnectionSuccess: () {
                              setState(() {});
                            },
                            onConnectionError: (p1) {},
                            onConnectionFailed: (p1) {},
                            onMessageReceived: (List<TranscriptSegment> p1) {},
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomExpansionTile(
                    title: 'Prompt',
                    subtitle: isPromptSaved ? 'Customize Prompt' : 'Default',
                    children: [
                      ListTile(
                        leading: !isPromptSaved
                            ? const Icon(
                                Icons.done_all_rounded,
                                color: Colors.green,
                                size: 18,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                        title: const Text('Default'),
                        onTap: _setDefaultPrompt,
                      ),
                      ListTile(
                        leading: isPromptSaved
                            ? const Icon(
                                Icons.done_all_rounded,
                                color: Colors.green,
                                size: 18,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                        title: const Text('Customize Prompt'),
                        onTap: _customizePrompt,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Future<void> initWebSocket(
      {required Function onConnectionSuccess,
      required Function(dynamic p1) onConnectionFailed,
      required Function(int? p1, String? p2) onConnectionClosed,
      required Function(dynamic p1) onConnectionError,
      required Function(List<TranscriptSegment> p1) onMessageReceived,
      BleAudioCodec codec = BleAudioCodec.pcm8,
      int? sampleRate = 16000}) {
    // TODO: implement initWebSocket
    return super.initWebSocket(
        onConnectionSuccess: onConnectionSuccess,
        onConnectionFailed: onConnectionFailed,
        onConnectionClosed: onConnectionClosed,
        onConnectionError: onConnectionError,
        onMessageReceived: onMessageReceived,
        codec: codec,
        sampleRate: sampleRate);
  }

  void _onSwitchChanged(bool value) async {
    SharedPreferencesUtil().developerOptionEnabled = value;
    if (!value) {
      SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
      PromptProvider().removeAllPrompts();
      SharedPreferencesUtil().isPromptSaved = false;

      //  developerModeSelected(modeSelected: 'Deepgram');
      // if (Platform.isAndroid) Restart.restartApp();

      // Restart.restartApp(
      //     // notificationTitle: 'Restarting App',
      //     // notificationBody: 'Please tap here to open the app again.',
      //     );
      await closeWebSocket2();
      await initWebSocket(
        onConnectionClosed: (int? closeCode, String? closeReason) {
          setState(() {});
        },
        onConnectionSuccess: () {
          setState(() {});
        },
        onConnectionError: (p1) {},
        onConnectionFailed: (p1) {},
        onMessageReceived: (List<TranscriptSegment> p1) {},
      );
      print('developer option not true');
    }
    setState(() {
      developerEnabled = value;
    });
  }
}

void developerModeSelected({required String modeSelected}) async {
  print('Mode Selected $modeSelected');

  SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
  print("updated type");
  // // SharedPreferencesUtil().isPromptSaved = false;
  // const AlertDialog(
  //   content: Text('To Reflect selected Changes\nApp Restarting...'),
  // );
  // Future.delayed(const Duration(seconds: 3));
  // if (Platform.isAndroid) Restart.restartApp();

  // Restart.restartApp(
  //   notificationTitle: 'Restarting App',
  //   notificationBody: 'Please tap here to open the app again.',
  // );
}
// =======
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:friend_private/backend/database/prompt_provider.dart';
// import 'package:friend_private/backend/database/transcript_segment.dart';
// import 'package:friend_private/backend/preferences.dart';
// import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
// import 'package:friend_private/pages/home/backgrund_scafold.dart';
// import 'package:friend_private/pages/settings/custom_prompt_page.dart';
// import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
// import 'package:friend_private/utils/ble/communication.dart';
// import 'package:friend_private/utils/websockets.dart';
// import 'package:restart_app/restart_app.dart';

// class DeveloperPage extends StatefulWidget {
//   const DeveloperPage({super.key});

//   @override
//   State<DeveloperPage> createState() => _DeveloperPageState();
// }

// class _DeveloperPageState extends State<DeveloperPage> with WebSocketMixin {
//   bool developerEnabled = false;
//   bool isModeSelected = false;
//   bool isPromptSaved = false;

//   @override
//   void initState() {
//     super.initState();
//     developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
//     isPromptSaved = SharedPreferencesUtil().isPromptSaved;
//   }

//   // void developerModeSelected({required String modeSelected}) {
//   //   setState(() {
//   //     isModeSelected = true;
//   //     SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
//   //   });
//   // }

//   void _setDefaultPrompt() {
//     setState(() {
//       PromptProvider().removeAllPrompts();
//       SharedPreferencesUtil().isPromptSaved = false;
//       isPromptSaved = false;
//     });
//   }

//   void _customizePrompt() {
//     Navigator.of(context)
//         .push(
//       MaterialPageRoute(
//         builder: (context) => const CustomPromptPage(),
//       ),
//     )
//         .then((_) {
//       setState(() {
//         isPromptSaved = SharedPreferencesUtil().isPromptSaved;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String apiType =
//         SharedPreferencesUtil().getApiType('NewApiKey') ?? '';

//     return CustomScaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Developer\'s Option'),
//       ),
//       body: ListView(
//         children: [
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: SizedBox(
//               width: double.infinity,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.people),
//                       SizedBox(width: 16),
//                       Text(
//                         'Enable Developer',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Switch(
//                     value: developerEnabled,
//                     onChanged: _onSwitchChanged,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (!developerEnabled)
//             const Text(
//               'By Enabling Developer Mode\nYou can customize prompt\'s & Transcript Services',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           if (!developerEnabled) const SizedBox(height: 24),
//           if (developerEnabled)
//             Visibility(
//               visible: developerEnabled,
//               child: ListView(
//                 shrinkWrap: true,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 children: [
//                   CustomExpansionTile(
//                     title: 'Transcript Service',
//                     subtitle:
//                         SharedPreferencesUtil().getApiType('NewApiKey') ?? '',
//                     children: [
//                       ListTile(
//                         leading: apiType == 'Deepgram'
//                             ? const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.green,
//                                 size: 18,
//                               )
//                             : const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.grey,
//                                 size: 18,
//                               ),
//                         title: const Text('Deepgram'),
//                         onTap: () async {
//                           await closeWebSocket();
//                           // developerModeSelected(modeSelected: 'Deepgram');
//                           // closeWebSocket();
//                           //   closeWebSocket2();
//                           developerModeSelected(modeSelected: 'Deepgram');

//                           await initWebSocket(
//                             onConnectionClosed:
//                                 (int? closeCode, String? closeReason) {
//                               setState(() {});
//                             },
//                             onConnectionSuccess: () {
//                               setState(() {});
//                             },
//                             onConnectionError: (p1) {},
//                             onConnectionFailed: (p1) {},
//                             onMessageReceived: (List<TranscriptSegment> p1) {},
//                           );
//                         },
//                       ),
//                       ListTile(
//                         leading: apiType == 'Sarvam'
//                             ? const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.green,
//                                 size: 18,
//                               )
//                             : const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.grey,
//                                 size: 18,
//                               ),
//                         title: const Text('Sarvam'),
//                         onTap: () async {
//                           // developerModeSelected(modeSelected: 'Sarvam');
//                           // closeWebSocket();
//                           await closeWebSocket();
//                           developerModeSelected(modeSelected: 'Sarvam');
//                           await initWebSocket(
//                             onConnectionClosed:
//                                 (int? closeCode, String? closeReason) {
//                               setState(() {});
//                             },
//                             onConnectionSuccess: () {
//                               setState(() {});
//                             },
//                             onConnectionError: (p1) {},
//                             onConnectionFailed: (p1) {},
//                             onMessageReceived: (List<TranscriptSegment> p1) {},
//                           );
//                         },
//                       ),
//                       ListTile(
//                         leading: apiType == 'Whisper'
//                             ? const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.green,
//                                 size: 18,
//                               )
//                             : const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.grey,
//                                 size: 18,
//                               ),
//                         title: const Text('Whisper'),
//                         onTap: () async {
//                           // developerModeSelected(modeSelected: 'Sarvam');
//                           // closeWebSocket();
//                           await closeWebSocket();
//                           developerModeSelected(modeSelected: 'Whisper');
//                           await initWebSocket(
//                             onConnectionClosed:
//                                 (int? closeCode, String? closeReason) {
//                               setState(() {});
//                             },
//                             onConnectionSuccess: () {
//                               setState(() {});
//                             },
//                             onConnectionError: (p1) {},
//                             onConnectionFailed: (p1) {},
//                             onMessageReceived: (List<TranscriptSegment> p1) {},
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   CustomExpansionTile(
//                     title: 'Prompt',
//                     subtitle: isPromptSaved ? 'Customize Prompt' : 'Default',
//                     children: [
//                       ListTile(
//                         leading: !isPromptSaved
//                             ? const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.green,
//                                 size: 18,
//                               )
//                             : const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.grey,
//                                 size: 18,
//                               ),
//                         title: const Text('Default'),
//                         onTap: _setDefaultPrompt,
//                       ),
//                       ListTile(
//                         leading: isPromptSaved
//                             ? const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.green,
//                                 size: 18,
//                               )
//                             : const Icon(
//                                 Icons.done_all_rounded,
//                                 color: Colors.grey,
//                                 size: 18,
//                               ),
//                         title: const Text('Customize Prompt'),
//                         onTap: _customizePrompt,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Future<void> initWebSocket(
//       {required Function onConnectionSuccess,
//       required Function(dynamic p1) onConnectionFailed,
//       required Function(int? p1, String? p2) onConnectionClosed,
//       required Function(dynamic p1) onConnectionError,
//       required Function(List<TranscriptSegment> p1) onMessageReceived,
//       BleAudioCodec codec = BleAudioCodec.pcm8,
//       int? sampleRate = 16000}) {
//     // TODO: implement initWebSocket
//     return super.initWebSocket(
//         onConnectionSuccess: onConnectionSuccess,
//         onConnectionFailed: onConnectionFailed,
//         onConnectionClosed: onConnectionClosed,
//         onConnectionError: onConnectionError,
//         onMessageReceived: onMessageReceived,
//         codec: codec,
//         sampleRate: sampleRate);
//   }

//   void _onSwitchChanged(bool value) async {
//     SharedPreferencesUtil().developerOptionEnabled = value;
//     if (!value) {
//       SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
//       PromptProvider().removeAllPrompts();
//       SharedPreferencesUtil().isPromptSaved = false;

//       //  developerModeSelected(modeSelected: 'Deepgram');
//       // if (Platform.isAndroid) Restart.restartApp();

//       // Restart.restartApp(
//       //     // notificationTitle: 'Restarting App',
//       //     // notificationBody: 'Please tap here to open the app again.',
//       //     );
//       await closeWebSocket();
//       await initWebSocket(
//         onConnectionClosed: (int? closeCode, String? closeReason) {
//           setState(() {});
//         },
//         onConnectionSuccess: () {
//           setState(() {});
//         },
//         onConnectionError: (p1) {},
//         onConnectionFailed: (p1) {},
//         onMessageReceived: (List<TranscriptSegment> p1) {},
//       );
//       print('developer option not true');
//     }
//     setState(() {
//       developerEnabled = value;
//     });
//   }
// }

// void developerModeSelected({required String modeSelected}) async {
//   print('Mode Selected $modeSelected');

//   SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
//   print("updated type");
//   // // SharedPreferencesUtil().isPromptSaved = false;
//   // const AlertDialog(
//   //   content: Text('To Reflect selected Changes\nApp Restarting...'),
//   // );
//   // Future.delayed(const Duration(seconds: 3));
//   // if (Platform.isAndroid) Restart.restartApp();

//   // Restart.restartApp(
//   //   notificationTitle: 'Restarting App',
//   //   notificationBody: 'Please tap here to open the app again.',
//   // );
// }

