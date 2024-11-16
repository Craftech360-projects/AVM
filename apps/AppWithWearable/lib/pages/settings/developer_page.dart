import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/custom_prompt_page.dart';
import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
import 'package:restart_app/restart_app.dart';

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
                      Visibility(
                        visible: false,
                        child: ListTile(
                          title: const Text('Wisper'),
                          onTap: () {
                            developerModeSelected(modeSelected: 'Wisper');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomExpansionTile(
                    title: 'Prompt',
                    children: [
                      ListTile(
                        title: const Text('Default'),
                        onTap: () {
                          // final customPromptDetails = CustomPrompt(
                          //   prompt: null,
                          //   title: null,
                          //   overview: null,
                          //   actionItems: null,
                          //   category: null,
                          //   calendar: null,
                          // );

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

      if (Platform.isAndroid) Restart.restartApp();

      Restart.restartApp(
          // notificationTitle: 'Restarting App',
          // notificationBody: 'Please tap here to open the app again.',
          );
      print('developer option not true');
    }
    setState(() {
      developerEnabled = value;
    });
  }

  void developerModeSelected({required String modeSelected}) {
    print('Mode Selected $modeSelected');
    SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
    // SharedPreferencesUtil().isPromptSaved = false;
    const AlertDialog(
      content: Text('To Reflect selected Changes\nApp Restarting...'),
    );
    Future.delayed(const Duration(seconds: 3));
    if (Platform.isAndroid) Restart.restartApp();

    Restart.restartApp(
        // notificationTitle: 'Restarting App',
        // notificationBody: 'Please tap here to open the app again.',
        );
  }
}
