import 'package:flutter/material.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/BackupButton.dart';
import 'package:friend_private/pages/settings/RestoreButton.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/developer_page.dart';
import 'package:friend_private/pages/settings/profile.dart';
import 'package:friend_private/pages/settings/widgets.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/utils/walkthrough/walkthrough_tutorial.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

GlobalKey<_SettingsPageState> settingPageState = GlobalKey();

class _SettingsPageState extends State<SettingsPage> with WebSocketMixin {
  late String _selectedLanguage;
  late bool optInAnalytics;
  late bool devModeEnabled;
  late bool backupsEnabled;
  late bool postMemoryNotificationIsChecked;
  late bool reconnectNotificationIsChecked;
  String? version;
  String? buildVersion;
  // final bool _customTileExpanded = false;
  GlobalKey calenderTour = GlobalKey();
  GlobalKey ProfileTour = GlobalKey();
  GlobalKey DeveloperTour = GlobalKey();
  // List<TargetFocus> settingtargets = [];
  late TutorialCoachMark tutorialCoachMark;
  @override
  void initState() {
    createSecondPageTutorial();
    print(
        'second page tutorial completed ${SharedPreferencesUtil().secondPageTutorialCompleted}');
    if (SharedPreferencesUtil().secondPageTutorialCompleted==false) {
      Future.delayed(Duration.zero, showSecondPageTutorial);
    }

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

  settingTour() {
    settingtargets.add(
      CustomTargetFocus().buildTarget(
        keyTarget: ProfileTour,
        identify: "Target 5",
        titleText: "Configure your profile",
        descriptionText: "Change your name to which AVM is recognised you",
      ),
    );
    settingtargets.add(
      CustomTargetFocus().buildTarget(
        keyTarget: calenderTour,
        identify: "Target 6",
        titleText: "Manage the calendar",
        descriptionText:
            "Integrate the Google calendar and get notifications of it",
      ),
    );
    settingtargets.add(
      CustomTargetFocus().buildTarget(
        keyTarget: DeveloperTour,
        identify: "Target 7",
        titleText: "Customise your needs",
        descriptionText: "By using custom prompt, Customise the AVM",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: CustomScaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
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


              getItemAddOn(
                key: ProfileTour,
                'Profile',
                () {
                  routeToPage(
                    context,
                    const ProfilePage(),
                  );
                },
                icon: Icons.person,
              ),
              getItemAddOn(
                key: calenderTour,
                'Calendar Integration',
                () {
                  routeToPage(
                    context,
                    const CalendarPage(),
                  );
                },
                icon: Icons.calendar_month,
              ),
              getItemAddOn(
                key: DeveloperTour,
                'Developers Option',
                () {
                  routeToPage(
                    context,
                    const DeveloperPage(),
                  );
                },
                icon: Icons.settings_suggest,
              ),
              //  const SizedBox(height: 16),
              // const BackupButton(),
              // const SizedBox(height: 16), 
              // const RestoreButton(), 
              // const SizedBox(height: 16),
           Spacer(),
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

  void showSecondPageTutorial() {
    tutorialCoachMark.show(context: context);
    SharedPreferencesUtil().secondPageTutorialCompleted = true;
  }

  void createSecondPageTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createSecondPageTargets(),
      colorShadow: Colors.black,
      textSkip: "SKIP",
      opacityShadow: 0.8,
      onFinish: () {
        print("Second Page Tutorial Finished");
      },
      onSkip: () {
        print("Second Page Tutorial Skipped");
        return true;
      },
    );
  }

  List<TargetFocus> _createSecondPageTargets() {
    return [
      CustomTargetFocus().buildTarget(
        keyTarget: ProfileTour,
        identify: "Target 5",
        titleText: "Configure your profile",
        descriptionText: "Change your name to which AVM is recognised you",
      ),
      CustomTargetFocus().buildTarget(
        keyTarget: calenderTour,
        identify: "Target 6",
        titleText: "Manage the calendar",
        descriptionText:
            "Integrate the Google calendar and get notifications of it",
      ),
      CustomTargetFocus().buildTarget(
        keyTarget: DeveloperTour,
        identify: "Target 7",
        titleText: "Customise your needs",
        descriptionText: "By using custom prompt, Customise the AVM",
      ),
    ];
  }
}
