import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/BackupButton.dart';
import 'package:friend_private/pages/settings/RestoreButton.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/custom_prompt_page.dart';
import 'package:friend_private/pages/settings/developer_page.dart';
import 'package:friend_private/pages/settings/profile.dart';
import 'package:friend_private/pages/settings/widgets.dart';
import 'package:friend_private/pages/settings/widgets/customExpandiblewidget.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WebSocketMixin {
  late String _selectedLanguage;
  late bool optInAnalytics;
  late bool devModeEnabled;
  late bool backupsEnabled;
  late bool postMemoryNotificationIsChecked;
  late bool reconnectNotificationIsChecked;
  String? version;
  String? buildVersion;
  final bool _customTileExpanded = false;

  @override
  void initState() {
    _selectedLanguage = SharedPreferencesUtil().recordingsLanguage;
    optInAnalytics = SharedPreferencesUtil().optInAnalytics;
    devModeEnabled = SharedPreferencesUtil().devModeEnabled;
    postMemoryNotificationIsChecked =
        SharedPreferencesUtil().postMemoryNotificationIsChecked;
    reconnectNotificationIsChecked =
        SharedPreferencesUtil().reconnectNotificationIsChecked;
    backupsEnabled = SharedPreferencesUtil().backupsEnabled;
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      buildVersion = packageInfo.buildNumber.toString();
      setState(() {});
    });
    super.initState();
  }

  bool loadingExportMemories = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: true,
      child: CustomScaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: true,
          title: const Text('Settings'),
          centerTitle: false,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 8,
              right: 8),
          child: Column(
            children: [
              const SizedBox(height: 32.0),
              ...getRecordingSettings((String? newValue) {
                if (newValue == null) return;
                if (newValue == _selectedLanguage) return;
                if (newValue != 'en') {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => getDialog(
                      context,
                      () => Navigator.of(context).pop(),
                      () => {},
                      'Language Limitations',
                      'Speech profiles are only available for English language. We are working on adding support for other languages.',
                      singleButton: true,
                    ),
                  );
                }
                setState(() => _selectedLanguage = newValue);
                SharedPreferencesUtil().recordingsLanguage = _selectedLanguage;
                MixpanelManager().recordingLanguageChanged(_selectedLanguage);
              }, _selectedLanguage),
              // TODO: do not works like this, fix if reusing
              // ...getNotificationsWidgets(setState, postMemoryNotificationIsChecked, reconnectNotificationIsChecked),
              //! Disabled As of now

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ADD ONS',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              getItemAddOn('Profile', () {
                routeToPage(context, const ProfilePage());
              }, icon: Icons.person),
              getItemAddOn('Calendar Integration', () {
                routeToPage(context, const CalendarPage());
              }, icon: Icons.calendar_month),
              getItemAddOn('Developers Option', () {
                routeToPage(context, const DeveloperPage());
              }, icon: Icons.settings_suggest),
              const SizedBox(height: 16),
              const BackupButton(),
              const SizedBox(height: 16), // Backup button added here
              const RestoreButton(), // Backup button added here

              const SizedBox(height: 16),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Version: $version+$buildVersion',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 150, 150, 150),
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
