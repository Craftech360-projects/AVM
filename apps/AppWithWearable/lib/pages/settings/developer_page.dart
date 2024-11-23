import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/custom_prompt_page.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:go_router/go_router.dart';

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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      // backgroundColor: const Color(0xFFE6F5FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F5FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Return to the previous screen
          },
        ),
        title: Text(
          'Developer\'s Option',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png', // Replace with your image path
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: CustomColors.greyLavender,
                              child: Icon(Icons.people),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Enable Developer',
                              style: TextStyle(
                                color: CustomColors.blackPrimary,
                                fontSize: 16.h,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        CustomExpansionTile(
                          title: 'Transcript Service',
                          subtitle:
                              SharedPreferencesUtil().getApiType('NewApiKey') ??
                                  '',
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
                        const Divider(
                            color: CustomColors.purpleBright, height: 1),
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
                                    builder: (context) =>
                                        const CustomPromptPage(),
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

      // if (Platform.isAndroid) Restart.restartApp();

      // Restart.restartApp(
      //     // notificationTitle: 'Restarting App',
      //     // notificationBody: 'Please tap here to open the app again.',
      //     );
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
    // if (Platform.isAndroid) Restart.restartApp();

    // Restart.restartApp(
    // notificationTitle: 'Restarting App',
    // notificationBody: 'Please tap here to open the app again.',
    //     );
  }
}
