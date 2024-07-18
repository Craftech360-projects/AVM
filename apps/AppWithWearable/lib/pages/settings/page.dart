import 'package:AVMe/pages/onboarding/welcome/page.dart';
import 'package:AVMe/pages/settings/calendar.dart';
import 'package:AVMe/pages/settings/widgets.dart';
import 'package:AVMe/utils/other/temp.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:AVMe/backend/api_requests/cloud_storage.dart';
import 'package:AVMe/backend/mixpanel.dart';
import 'package:AVMe/backend/preferences.dart';
import 'package:AVMe/backend/utils.dart';
import 'package:AVMe/backend/schema/bt_device.dart';
import 'package:AVMe/utils/ble/connect.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController openaiApiKeyController = TextEditingController();
  final TextEditingController gcpCredentialsController =
      TextEditingController();
  final TextEditingController gcpBucketNameController = TextEditingController();
  final TextEditingController deepgramAPIKeyController =
      TextEditingController();
  final TextEditingController openAIKeyController = TextEditingController();
  bool openaiApiIsVisible = false;
  late String _selectedLanguage;
  late bool optInAnalytics;
  late bool devModeEnabled;
  late bool coachIsChecked;
  late bool reconnectNotificationIsChecked;
  String? version;
  String? buildVersion;

  @override
  void initState() {
    openaiApiKeyController.text = SharedPreferencesUtil().openAIApiKey;
    deepgramAPIKeyController.text = SharedPreferencesUtil().deepgramApiKey;
    gcpCredentialsController.text = SharedPreferencesUtil().gcpCredentials;
    gcpBucketNameController.text = SharedPreferencesUtil().gcpBucketName;
    _selectedLanguage = SharedPreferencesUtil().recordingsLanguage;
    optInAnalytics = SharedPreferencesUtil().optInAnalytics;
    devModeEnabled = SharedPreferencesUtil().devModeEnabled;
    coachIsChecked = SharedPreferencesUtil().coachIsChecked;
    reconnectNotificationIsChecked =
        SharedPreferencesUtil().reconnectNotificationIsChecked;
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      print(packageInfo.toString());
      version = packageInfo.version;
      buildVersion = packageInfo.buildNumber.toString();
      setState(() {});
    });
    super.initState();
  }

  // void _showRemoveDeviceDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         backgroundColor:
  //             Color.fromARGB(54, 0, 0, 0), // Make the dialog transparent
  //         title: const Text(
  //           "Warning",
  //           style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.w500,
  //               fontSize: 24), // Style the text color
  //         ),
  //         content: const Text(
  //           "This will remove the saved AVM device. Do you want to proceed?",
  //           style: TextStyle(color: Colors.white), // Style the text color
  //         ),
  //         actions: [
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //             child: const Text(
  //               "Cancel",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               backgroundColor: Colors.green,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: const Text(
  //               "Confirm",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onPressed: () {
  //               _removeDevice();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _showRemoveDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
              Colors.transparent, // Make the dialog background transparent
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(120, 130, 129, 131),
                  Color.fromARGB(120, 71, 71, 72),
                  Color.fromARGB(122, 49, 11, 125),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Warning",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "This will remove the saved AVM device. Do you want to proceed?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _removeDevice();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeDevice() async {
    // Replace 'your_device_id' with the actual device ID
    String deviceId = SharedPreferencesUtil().deviceId;
    String deviceName = 'Your Device Name'; // You need to retrieve this

    BTDeviceStruct btDevice = BTDeviceStruct(id: deviceId, name: deviceName);
    await bleDisconnectDevice(btDevice);

    // Clear device data from shared preferences
    await SharedPreferencesUtil().remove('deviceId');
    setState(() {
      // Update UI if necessary
    });

    // Navigate to FoundDevices page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
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
              actions: [
                MaterialButton(
                  onPressed: _saveSettings,
                  color: Colors.transparent,
                  elevation: 0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 8,
                  right: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 28.0),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'RECORDING SETTINGS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                  top: 8,
                                  bottom: 8,
                                ),
                                child: DropdownButton<String>(
                                  menuMaxHeight: 350,
                                  value: _selectedLanguage,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedLanguage = newValue!;
                                    });
                                  },
                                  dropdownColor: Colors.black,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  underline: Container(
                                    height: 0,
                                    color: Colors.white,
                                  ),
                                  isExpanded: true,
                                  itemHeight: 48,
                                  items: availableLanguages.keys
                                      .map<DropdownMenuItem<String>>(
                                          (String key) {
                                    return DropdownMenuItem<String>(
                                      value: availableLanguages[key],
                                      child: Text(
                                        '$key (${availableLanguages[key]})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28.0),
                            ..._getDeveloperOnlyFields(),
                            const SizedBox(height: 28.0),
                            getItemAddOn('Calendar Integration', () {
                              routeToPage(context, const CalendarPage());
                            }, icon: Icons.calendar_month),
                            const SizedBox(height: 28.0),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width:
                                double.infinity, // Make the button full-width
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(
                                    color: Colors.red), // White border
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              onPressed: () {
                                _showRemoveDeviceDialog(context);
                              },
                              // onPressed: _removeDevice,
                              child: const Text(
                                "Remove Device",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            SharedPreferencesUtil().uid,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 150, 150, 150),
                              fontSize: 16,
                            ),
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getDeveloperOnlyFields() {
    if (!devModeEnabled) return [const SizedBox.shrink()];
    return [
      const SizedBox(height: 24.0),
      Container(
        height: 0.2,
        color: Colors.grey[400],
        width: double.infinity,
      ),
      const SizedBox(height: 40),
      _getText('Set your own keys', underline: false),
      const SizedBox(height: 16.0),
      TextField(
        controller: openAIKeyController,
        obscureText: false,
        autocorrect: false,
        enabled: true,
        enableSuggestions: false,
        decoration:
            _getTextFieldDecoration('Open AI Key', hintText: 'sk-.......'),
        style: const TextStyle(color: Colors.white),
      ),
      const SizedBox(height: 24.0),
      TextField(
        controller: deepgramAPIKeyController,
        obscureText: false,
        autocorrect: false,
        enabled: true,
        enableSuggestions: false,
        decoration: _getTextFieldDecoration('Deepgram API Key', hintText: ''),
        style: const TextStyle(color: Colors.white),
      ),
      const SizedBox(height: 40),
      _getText('[Optional] Store your recordings in Google Cloud',
          underline: false),
      const SizedBox(height: 16.0),
      TextField(
        controller: gcpCredentialsController,
        obscureText: false,
        autocorrect: false,
        enableSuggestions: false,
        enabled: true,
        decoration: _getTextFieldDecoration('GCP Credentials (Base64)'),
        style: const TextStyle(color: Colors.white),
      ),
      const SizedBox(height: 16.0),
      TextField(
        controller: gcpBucketNameController,
        obscureText: false,
        autocorrect: false,
        enabled: true,
        enableSuggestions: false,
        decoration: _getTextFieldDecoration('GCP Bucket Name'),
        style: const TextStyle(color: Colors.white),
      ),
      const SizedBox(height: 64),
    ];
  }

  _getTextFieldDecoration(String label,
      {IconButton? suffixIcon,
      bool canBeDisabled = false,
      String hintText = ''}) {
    return InputDecoration(
      labelText: label,
      enabled: true && canBeDisabled,
      hintText: hintText,
      labelStyle: TextStyle(
        color: false && canBeDisabled
            ? Colors.white.withOpacity(0.2)
            : Colors.white,
      ),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: false && canBeDisabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: false && canBeDisabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: false && canBeDisabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  _getText(String text, {bool canBeDisabled = false, bool underline = false}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: true && canBeDisabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white,
          decoration:
              underline ? TextDecoration.underline : TextDecoration.none,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _saveSettings() {
    saveSettings();
    Navigator.pop(context);
  }

  void saveSettings() async {
    final prefs = SharedPreferencesUtil();
    prefs.gcpCredentials = gcpCredentialsController.text.trim();
    prefs.gcpBucketName = gcpBucketNameController.text.trim();
    prefs.optInAnalytics = optInAnalytics;
    prefs.devModeEnabled = devModeEnabled;
    prefs.coachIsChecked = coachIsChecked;
    prefs.reconnectNotificationIsChecked = reconnectNotificationIsChecked;
    prefs.openAIApiKey = openaiApiKeyController.text.trim();
    prefs.deepgramApiKey = deepgramAPIKeyController.text.trim();

    optInAnalytics
        ? MixpanelManager().optInTracking()
        : MixpanelManager().optOutTracking();

    if (_selectedLanguage != prefs.recordingsLanguage) {
      prefs.recordingsLanguage = _selectedLanguage;
      MixpanelManager().recordingLanguageChanged(_selectedLanguage);
    }

    if (gcpCredentialsController.text.isNotEmpty &&
        gcpBucketNameController.text.isNotEmpty) {
      authenticateGCP();
    }

    MixpanelManager().settingsSaved();
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  GradientText({
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style:
            style.copyWith(color: Colors.white), // Required for the shader mask
      ),
    );
  }
}
