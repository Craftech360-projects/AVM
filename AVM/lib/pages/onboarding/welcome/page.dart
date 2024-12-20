import 'dart:io';

import 'package:avm/backend/mixpanel.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/src/common_widget/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback goNext;
  final VoidCallback skipDevice;

  const WelcomePage(
      {super.key, required this.goNext, required this.skipDevice});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var screenSize = MediaQuery.of(context).size;
    // Calculate the padding from the bottom based on the screen height for responsiveness

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: screenSize.width * 0.1, right: screenSize.width * 0.1),
          child: CustomElevatedButton(
            onPressed: () async {
              bool permissionsAccepted = false;
              if (Platform.isIOS) {
                PermissionStatus bleStatus =
                    await Permission.bluetooth.request();
                debugPrint('bleStatus: $bleStatus');
                permissionsAccepted = bleStatus.isGranted;
              } else {
                PermissionStatus bleScanStatus =
                    await Permission.bluetoothScan.request();
                PermissionStatus bleConnectStatus =
                    await Permission.bluetoothConnect.request();
                // PermissionStatus locationStatus = await Permission.location.request();

                permissionsAccepted = bleConnectStatus.isGranted &&
                    bleScanStatus.isGranted; // && locationStatus.isGranted;

                debugPrint(
                    'bleScanStatus: $bleScanStatus ~ bleConnectStatus: $bleConnectStatus');
              }
              if (!permissionsAccepted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        'Permissions Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'This app needs Bluetooth and Location permissions to function properly. Please enable them in the settings.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            openAppSettings();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                widget.goNext();
              }
            },
            child: Container(
              width: double.infinity,
              height: 45,
              alignment: Alignment.center,
              child: Text(
                'Connect My AVM',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: screenSize.width * 0.045,
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ),
        TextButton(
            onPressed: () {
              widget.skipDevice();
              MixpanelManager().useWithoutDeviceOnboardingWelcome();
            },
            child: Text(
              'Skip for now',
              style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey, decoration: TextDecoration.underline),
            )),
        const SizedBox(height: 16)
      ],
    );
  }
}
