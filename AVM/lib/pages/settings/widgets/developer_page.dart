<<<<<<< HEAD
import 'dart:developer';
=======
// import 'package:avm/backend/database/prompt_provider.dart';
// import 'package:avm/backend/database/transcript_segment.dart';
// import 'package:avm/backend/preferences.dart';
// import 'package:avm/core/constants/constants.dart';
// import 'package:avm/core/theme/app_colors.dart';
// import 'package:avm/features/capture/logic/websocket_mixin.dart';
// import 'package:avm/pages/home/custom_scaffold.dart';
// import 'package:avm/pages/settings/widgets/custom_expandible_widget.dart';
// import 'package:avm/pages/settings/widgets/custom_prompt_page.dart';
// import 'package:flutter/material.dart';

// class DeveloperPage extends StatefulWidget {
//   const DeveloperPage({super.key});
//   static const name = "developer";
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
//     // if (developerEnabled) _getCalendars();
//   }

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
//     String? codecType = SharedPreferencesUtil().getCodecType('NewCodec');

//     return CustomScaffold(
//       showBackBtn: true,
//       showGearIcon: true,
//       title: const Text(
//         "Developer Options",
//         style: TextStyle(fontWeight: FontWeight.w500),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: AppColors.purpleDark,
//                       child: Icon(
//                         Icons.people,
//                         color: AppColors.commonPink,
//                       ),
//                     ),
//                     w15,
//                     Text(
//                       'Developer Options',
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                     ),
//                   ],
//                 ),
//                 Switch(
//                   activeTrackColor: AppColors.purpleDark,
//                   activeColor: AppColors.commonPink,
//                   value: developerEnabled,
//                   onChanged: _onSwitchChanged,
//                 ),
//               ],
//             ),
//           ),
//           h5,
//           if (!developerEnabled)
//             const Text(
//               'By Enabling Developer Mode You can customize prompts & Transcript Services',
//               textAlign: TextAlign.start,
//               style: TextStyle(
//                 color: AppColors.greyMedium,
//               ),
//             ),
//           if (developerEnabled)
//             Visibility(
//               visible: developerEnabled,
//               child: Column(
//                 children: [
//                   if (codecType == 'pcm')
//                     CustomExpansionTile(
//                       title: 'Transcript Service',
//                       subtitle:
//                           SharedPreferencesUtil().getApiType('NewApiKey') ?? '',
//                       children: [
//                         ListTile(
//                           title: const Text('Deepgram'),
//                           onTap: () async {
//                             developerModeSelected(modeSelected: 'Deepgram');

//                             closeWebSocket();

//                             await initWebSocket(
//                               onConnectionClosed:
//                                   (int? closeCode, String? closeReason) {
//                                 setState(() {});
//                               },
//                               onConnectionSuccess: () {
//                                 setState(() {});
//                               },
//                               onConnectionError: (p1) {},
//                               onConnectionFailed: (p1) {},
//                               onMessageReceived:
//                                   (List<TranscriptSegment> p1) {},
//                             );
//                           },
//                         ),
//                         ListTile(
//                           title: const Text('Sarvam'),
//                           onTap: () async {
//                             closeWebSocket();
//                             developerModeSelected(modeSelected: 'Sarvam');
//                             await initWebSocket(
//                               onConnectionClosed:
//                                   (int? closeCode, String? closeReason) {
//                                 setState(() {});
//                               },
//                               onConnectionSuccess: () {
//                                 setState(() {});
//                               },
//                               onConnectionError: (p1) {},
//                               onConnectionFailed: (p1) {},
//                               onMessageReceived:
//                                   (List<TranscriptSegment> p1) {},
//                             );
//                           },
//                         ),
//                         ListTile(
//                           title: const Text('Whisper'),
//                           onTap: () async {
//                             closeWebSocket();
//                             developerModeSelected(modeSelected: 'Whisper');
//                             await initWebSocket(
//                               onConnectionClosed:
//                                   (int? closeCode, String? closeReason) {
//                                 setState(() {});
//                               },
//                               onConnectionSuccess: () {
//                                 setState(() {});
//                               },
//                               onConnectionError: (p1) {},
//                               onConnectionFailed: (p1) {},
//                               onMessageReceived:
//                                   (List<TranscriptSegment> p1) {},
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   h5,
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
//                   h5,
//                   CustomExpansionTile(
//                     title: 'Select Codec',
//                     subtitle: SharedPreferencesUtil()
//                         .getCodecType('NewCodec')
//                         .toUpperCase(),
//                     children: [
//                       ListTile(
//                         title: const Text('OPUS'),
//                         onTap: () async {
//                           codecSelected(modeSelected: 'opus');

//                           closeWebSocket();
//                           codecSelected(modeSelected: 'opus');

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
//                         title: const Text('PCM'),
//                         onTap: () async {
//                           closeWebSocket();
//                           print('PCM Selected');
//                           codecSelected(modeSelected: 'pcm');
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
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _onSwitchChanged(bool value) {
//     SharedPreferencesUtil().developerOptionEnabled = value;
//     if (!value) {
//       SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
//       PromptProvider().removeAllPrompts();
//       SharedPreferencesUtil().isPromptSaved = false;
//     }
//     setState(() {
//       developerEnabled = value;
//     });
//   }

//   void developerModeSelected({required String modeSelected}) {
//     // print('Mode Selected $modeSelected');
//     SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
//     // SharedPreferencesUtil().isPromptSaved = false;
//     const AlertDialog(
//       content: Text('App will restart to apply selected changes.'),
//     );
//     Future.delayed(const Duration(seconds: 3));
//     // if (Platform.isAndroid) Restart.restartApp();
//   }

//   void codecSelected({required String modeSelected}) {
//     print('Mode Selected $modeSelected');
//     SharedPreferencesUtil().saveCodecType('NewCodec', modeSelected);
//     // SharedPreferencesUtil().isPromptSaved = false;
//     const AlertDialog(
//       content: Text('App will restart to apply selected changes.'),
//     );
//     Future.delayed(const Duration(seconds: 3));
//     // if (Platform.isAndroid) Restart.restartApp();
//   }
// }
>>>>>>> origin/fix/reconnectdevice

import 'package:avm/backend/database/prompt_provider.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/capture/logic/websocket_mixin.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/settings/widgets/custom_expandible_widget.dart';
import 'package:avm/pages/settings/widgets/custom_prompt_page.dart';
import 'package:avm/pages/settings/widgets/keywords_popup.dart';
import 'package:flutter/material.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});
  static const name = "developer";

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> with WebSocketMixin {
  String _currentApiType = '';
  String _currentCodecType = '';
  String _currentKeywordStatus = '';
  bool _developerEnabled = false;
  bool _isPromptSaved = false;
  final List<String> previouslySelected =
      SharedPreferencesUtil().getSelectedKeywords();
  Set<String> selectedKeywords = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    selectedKeywords.addAll(previouslySelected);
  }

  void _loadPreferences() {
    _developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
    _isPromptSaved = SharedPreferencesUtil().isPromptSaved;
    _currentApiType = SharedPreferencesUtil().getApiType('NewApiKey') ?? '';
    _currentCodecType = SharedPreferencesUtil().getCodecType('NewCodec');
    _currentKeywordStatus = SharedPreferencesUtil()
        .getKeywordDetectionStatus('newKeywordDetectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: Center(
        child: const Text(
          "Developer Options",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      children: [
        _buildDeveloperSwitch(),
        h5,
        if (!_developerEnabled)
          _buildDeveloperDescription()
        else
          _buildDeveloperOptions(),
      ],
    );
  }

  Widget _buildDeveloperSwitch() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
<<<<<<< HEAD
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purpleDark,
                child: Icon(Icons.people, color: AppColors.commonPink),
              ),
              w15,
              Text(
                'Developer Options',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          Switch(
            activeTrackColor: AppColors.purpleDark,
            activeColor: AppColors.commonPink,
            activeThumbImage: AssetImage(AppImages.appLogo),
            value: _developerEnabled,
            onChanged: _handleDeveloperModeToggle,
          ),
=======
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.greyLavender,
                      child: Icon(Icons.people),
                    ),
                    w15,
                    Text(
                      'Developer Options',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
          h5,
          if (!developerEnabled)
            const Text(
              'By Enabling Developer Mode You can customize prompts & Transcript Services',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.greyMedium,
              ),
            ),
          if (!developerEnabled) h20,
          if (developerEnabled)
            Visibility(
              visible: developerEnabled,
              child: Column(
                children: [
                  if (codecType == 'pcm')
                    CustomExpansionTile(
                      title: 'Transcript Service',
                      subtitle:
                          SharedPreferencesUtil().getApiType('NewApiKey') ?? '',
                      children: [
                        ListTile(
                          title: const Text('Deepgram'),
                          onTap: () async {
                            developerModeSelected(modeSelected: 'Deepgram');
                            print(SharedPreferencesUtil()
                                .getApiType('NewApiKey'));
                            closeWebSocket();

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
                              onMessageReceived:
                                  (List<TranscriptSegment> p1) {},
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Sarvam'),
                          onTap: () async {
                            closeWebSocket();
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
                              onMessageReceived:
                                  (List<TranscriptSegment> p1) {},
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Whisper'),
                          onTap: () async {
                            closeWebSocket();
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
                              onMessageReceived:
                                  (List<TranscriptSegment> p1) {},
                            );
                          },
                        ),
                      ],
                    ),
                  h5,
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
                  h5,
                  CustomExpansionTile(
                    title: 'Select Codec',
                    subtitle: SharedPreferencesUtil()
                        .getCodecType('NewCodec')
                        .toUpperCase(),
                    children: [
                      ListTile(
                        title: const Text('OPUS'),
                        onTap: () async {
                          codecSelected(modeSelected: 'opus');
                          print(
                              SharedPreferencesUtil().getCodecType('NewCodec'));
                          closeWebSocket();
                          codecSelected(modeSelected: 'opus');

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
                        title: const Text('PCM'),
                        onTap: () async {
                          codecSelected(modeSelected: 'pcm');
                          print(
                              SharedPreferencesUtil().getCodecType('NewCodec'));
                          closeWebSocket();
                          codecSelected(modeSelected: 'pcm');

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
                ],
              ),
            ),
>>>>>>> origin/fix/reconnectdevice
        ],
      ),
    );
  }

  Widget _buildDeveloperDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Text(
          'By Enabling Developer Mode You can customize prompts & Transcript Services',
          textAlign: TextAlign.center),
    );
  }

  Widget _buildDeveloperOptions() {
    final codecType = SharedPreferencesUtil().getCodecType('NewCodec');

    return Column(
      children: [
        if (codecType == 'pcm') _buildTranscriptServiceTile(),
        _buildPromptTile(),
        _buildCodecTile(),
        _buildKeywordDetectionTile(),
      ],
    );
  }

  void _handleDeveloperModeToggle(bool value) {
    if (!value) {
      SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
      PromptProvider().removeAllPrompts();
      SharedPreferencesUtil().isPromptSaved = false;
    }

    SharedPreferencesUtil().developerOptionEnabled = value;
    setState(() => _developerEnabled = value);
  }

  Future<void> _handleServiceSelection(String service) async {
    closeWebSocket();
    developerModeSelected(modeSelected: service);
    await _reconnectWebSocket();
  }

  Widget _buildPromptTile() {
    return CustomExpansionTile(
      title: 'Prompt Settings',
      subtitle: _isPromptSaved ? 'Saved' : 'Not Saved',
      children: [
        ListTile(
          title: const Text('Manage Prompts'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomPromptPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTranscriptServiceTile() {
    return CustomExpansionTile(
      title: 'Transcript Service',
      subtitle: _currentApiType,
      children: [
        for (final service in ['Deepgram', 'Sarvam', 'Whisper'])
          ListTile(
            title: Text(service),
            onTap: () => _handleServiceSelection(service),
          ),
      ],
    );
  }

  Widget _buildCodecTile() {
    return CustomExpansionTile(
      title: 'Codec Type',
      subtitle: _currentCodecType,
      children: [
        for (final codec in ['pcm', 'opus'])
          ListTile(
            title: Text(codec),
            onTap: () => codecSelected(modeSelected: codec),
          ),
      ],
    );
  }

  Widget _buildKeywordDetectionTile() {
    return CustomExpansionTile(
      title: 'Keyword Detection',
      subtitle: _currentKeywordStatus.toUpperCase(),
      children: [
        for (final status in ['ON', 'OFF'])
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
            title: Text(
              status,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () => updateKeywordDetectionStatus(modeSelected: status),
          ),
      ],
    );
  }

  void developerModeSelected({required String modeSelected}) {
    SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('App will restart to apply selected changes.'),
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
    _reconnectWebSocket();
  }

  void codecSelected({required String modeSelected}) {
<<<<<<< HEAD
=======
    print('Mode Selected $modeSelected');
>>>>>>> origin/fix/reconnectdevice
    SharedPreferencesUtil().saveCodecType('NewCodec', modeSelected);
    if (mounted) {
      setState(() {
        _currentCodecType = modeSelected;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('App will restart to apply selected changes.'),
        );
      },
    );
    _reconnectWebSocket();
  }

  Future<void> _reconnectWebSocket() async {
    try {
      await initWebSocket(
        onConnectionClosed: (closeCode, closeReason) {
          if (mounted) {
            setState(() {});
          }
        },
        onConnectionSuccess: () {
          if (mounted) {
            setState(() {});
          }
        },
        onConnectionError: (_) {},
        onConnectionFailed: (_) {},
        onMessageReceived: (_) {},
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void updateKeywordDetectionStatus({required String modeSelected}) async {
    if (modeSelected == 'ON') {
      final List<String>? userSelectedKeywords = await showDialog<List<String>>(
        context: context,
        builder: (context) =>
            KeywordsDialog(initialSelectedKeywords: selectedKeywords),
      );

      // Check if user selected keywords and saved
      if (userSelectedKeywords != null && userSelectedKeywords.isNotEmpty) {
        // Save selected keywords to preferences
        final keywordStatusSaved =
            await SharedPreferencesUtil().updateKeywordDetectionStatus(
          'newKeywordDetectionStatus',
          modeSelected,
        );

        await SharedPreferencesUtil().preferences?.setStringList(
              'selectedKeywords',
              userSelectedKeywords,
            );

        if (keywordStatusSaved) {
          setState(() {
            _currentKeywordStatus = modeSelected;
            selectedKeywords = userSelectedKeywords.toSet();
          });
        }
      } else {
        // Do not enable if no keywords selected
        return;
      }
    } else {
      // Disable keyword detection
      await SharedPreferencesUtil().updateKeywordDetectionStatus(
        'newKeywordDetectionStatus',
        modeSelected,
      );
      setState(() {
        _currentKeywordStatus = modeSelected;
      });
    }
  }

  @override
  void dispose() {
    closeWebSocket();
    super.dispose();
  }
}
