import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/settings/widgets/custom_expandible_widget.dart';
import 'package:friend_private/pages/settings/widgets/custom_prompt_page.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});
  static const name = "developer";
  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  bool developerEnabled = false;
  @override
  void initState() {
    super.initState();
    developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
    // if (developerEnabled) _getCalendars();
  }

  @override
  Widget build(BuildContext context) {
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
                        title: const Text('Deepgram'),
                        onTap: () {
                          developerModeSelected(modeSelected: 'Deepgram');
                        },
                      ),
                      ListTile(
                        title: const Text('Sarvam'),
                        onTap: () {
                          developerModeSelected(modeSelected: 'Sarvam');
                        },
                      ),
                      ListTile(
                        title: const Text('Whisper'),
                        onTap: () {
                          developerModeSelected(modeSelected: 'Whisper');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.purpleBright, height: 1),
                  const SizedBox(height: 12),
                  CustomExpansionTile(
                    title: 'Prompt',
                    children: [
                      ListTile(
                        title: const Text('Default'),
                        onTap: () {
                          summarizeMemory(
                            '',
                            [],
                            customPromptDetails: null,
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Customize Prompt'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CustomPromptPage(),
                            ),
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
      content: Text('To Reflect selected Changes\nApp Restarting...'),
    );
    Future.delayed(const Duration(seconds: 3));
    // if (Platform.isAndroid) Restart.restartApp();
  }
}
