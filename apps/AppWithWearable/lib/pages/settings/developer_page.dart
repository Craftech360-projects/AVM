import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/custom_prompt_page.dart';
import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
import 'package:restart_app/restart_app.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  bool developerEnabled = false;
  bool isModeSelected = false;
  bool isPromptSaved = false; 

  @override
  void initState() {
    super.initState();
    developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
    isPromptSaved = SharedPreferencesUtil()
        .isPromptSaved; 
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
                        onTap: () {
                          developerModeSelected(modeSelected: 'Deepgram');
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
                        onTap: () {
                          developerModeSelected(modeSelected: 'Sarvam');
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
}

void developerModeSelected({required String modeSelected}) async {
  print('Mode Selected $modeSelected');


  SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
  // SharedPreferencesUtil().isPromptSaved = false;
  const AlertDialog(
    content: Text('To Reflect selected Changes\nApp Restarting...'),
  );
  Future.delayed(const Duration(seconds: 3));
  if (Platform.isAndroid) Restart.restartApp();

  Restart.restartApp(
    notificationTitle: 'Restarting App',
    notificationBody: 'Please tap here to open the app again.',
  );

}
