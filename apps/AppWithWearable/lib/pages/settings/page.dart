import 'package:flutter/material.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/plugins/page.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/developer.dart';
import 'package:friend_private/pages/settings/widgets.dart';
import 'package:friend_private/pages/speaker_id/page.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedLanguage;
  late bool optInAnalytics;
  late bool devModeEnabled;
  late bool backupsEnabled;
  late bool postMemoryNotificationIsChecked;
  late bool reconnectNotificationIsChecked;
  String? version;
  String? buildVersion;

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

    // Request Calendar Permission
    requestCalendarPermission();

    super.initState();
  }

  bool loadingExportMemories = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: CustomScaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: true,
          title: const Text('Settings'),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
              getItemAddOn('Plugins', () {
                MixpanelManager().pluginsOpened();
                routeToPage(context, const PluginsPage());
              }, icon: Icons.integration_instructions),
                SharedPreferencesUtil().useTranscriptServer
                    ? getItemAddOn('Speech Profile', () {
                        routeToPage(context, const SpeakerIdPage());
                      }, icon: Icons.multitrack_audio)
                    : Container(),
                getItemAddOn('Calendar Integration', () {
                  routeToPage(context, const CalendarPage());
                }, icon: Icons.calendar_month),
              getItemAddOn('Developer Mode', () async {
                MixpanelManager().devModePageOpened();
                await routeToPage(context, const DeveloperSettingsPage());
                setState(() {});
              }, icon: Icons.code, visibility: devModeEnabled),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  SharedPreferencesUtil().uid,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> requestCalendarPermission() async {
    if (await Permission.calendarFullAccess.isGranted) {
      // Permission is already granted
    } else {
      // Request the permission
      PermissionStatus status = await Permission.calendarFullAccess.request();
      if (status.isGranted) {
        // Permission granted
      } else if (status.isDenied || status.isPermanentlyDenied) {
        // Permission denied or permanently denied
        // You might want to show a dialog to the user explaining why the permission is needed
      }
    }
  }
}
