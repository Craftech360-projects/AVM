import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/capture/logic/websocket_mixin.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/settings/widgets/custom_expandible_widget.dart';
import 'package:friend_private/pages/settings/widgets/custom_prompt_page.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});
  static const name = "developer";
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
    // if (developerEnabled) _getCalendars();
  }

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
    String? codecType = SharedPreferencesUtil().getCodecType('NewCodec');

    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: const Text(
        "Developer Options",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        children: [
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
                            await closeWebSocket();

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
                            await closeWebSocket();
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
                            await closeWebSocket();
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
                          await closeWebSocket();
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
                          await closeWebSocket();
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
        ],
      ),
    );
  }

  void _onSwitchChanged(bool value) {
    SharedPreferencesUtil().developerOptionEnabled = value;
    if (!value) {
      SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
      PromptProvider().removeAllPrompts();
      SharedPreferencesUtil().isPromptSaved = false;
    }
    setState(() {
      developerEnabled = value;
    });
  }

  void developerModeSelected({required String modeSelected}) {
    // print('Mode Selected $modeSelected');
    SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
    // SharedPreferencesUtil().isPromptSaved = false;
    const AlertDialog(
      content: Text('App will restart to apply selected changes.'),
    );
    Future.delayed(const Duration(seconds: 3));
    // if (Platform.isAndroid) Restart.restartApp();
  }

  void codecSelected({required String modeSelected}) {
    // print('Mode Selected $modeSelected');
    SharedPreferencesUtil().saveCodecType('NewCodec', modeSelected);
    // SharedPreferencesUtil().isPromptSaved = false;
    const AlertDialog(
      content: Text('App will restart to apply selected changes.'),
    );
    Future.delayed(const Duration(seconds: 3));
    // if (Platform.isAndroid) Restart.restartApp();
  }
}
