import 'dart:async';
import 'dart:io';

import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/bt_device.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/features/wizard/widgets/ble_animation.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:capsaul/utils/ble/find.dart';
import 'package:capsaul/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'found_devices.dart';

class FindDevicesPage extends StatefulWidget {
  final VoidCallback goNext;
  final bool includeSkip;

  const FindDevicesPage(
      {super.key, required this.goNext, this.includeSkip = true});
  static const String routeName = '/FindDevicesPage';
  @override
  FindDevicesPageState createState() => FindDevicesPageState();
}

class FindDevicesPageState extends State<FindDevicesPage>
    with SingleTickerProviderStateMixin {
  List<BTDeviceStruct> deviceList = [];
  late Timer? _didNotMakeItTimer;
  late Timer? _findDevicesTimer;
  bool enableInstructions = false;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  @override
  void dispose() {
    _findDevicesTimer?.cancel();
    _didNotMakeItTimer?.cancel();
    super.dispose();
  }

  Future<void> _scanDevices() async {
    setState(() {
      isScanning = true;
    });

    // Check if Bluetooth is enabled on Android
    if (Platform.isAndroid) {
      try {
        if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
          await FlutterBluePlus.turnOn();
        }
      } catch (e) {
        if (e is FlutterBluePlusException && e.code == 11) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (c) => getDialog(
                context,
                () {
                  Navigator.of(context).pop();
                },
                () {},
                'Enable Bluetooth',
                'Altio needs bluetooth to connect with your wearable. Please enable bluetooth and try again.',
                singleButton: true,
              ),
            );
          }
        } else {
          debugPrint('Unexpected error while enabling Bluetooth: $e');
        }
      }
    }

    // Set a timeout to show instructions if no devices are found
    _didNotMakeItTimer = Timer(const Duration(seconds: 10),
        () => setState(() => enableInstructions = true));

    Map<String, BTDeviceStruct> foundDevicesMap = {};

    // Start scanning periodically for devices
    _findDevicesTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        List<BTDeviceStruct> foundDevices = await bleFindDevices();

        // Update foundDevicesMap with new devices and remove the ones not found anymore
        Map<String, BTDeviceStruct> updatedDevicesMap = {
          for (final device in foundDevices) device.id: device
        };

        // Remove devices that are no longer found
        foundDevicesMap.keys
            .where((id) => !updatedDevicesMap.containsKey(id))
            .toList()
            .forEach(foundDevicesMap.remove);

        // Merge new devices into the current map
        foundDevicesMap.addAll(updatedDevicesMap);

        // Convert the values of the map back to a list
        List<BTDeviceStruct> orderedDevices = foundDevicesMap.values.toList();

        if (orderedDevices.isNotEmpty) {
          setState(() {
            deviceList = orderedDevices;
            isScanning = false;
          });
          _didNotMakeItTimer?.cancel();
        }
      } catch (e) {
        debugPrint('Error during BLE device scanning: $e');
      }
    });

    // Stop scanning after a timeout
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && isScanning) {
        _findDevicesTimer?.cancel();
        setState(() {
          isScanning = false;
          enableInstructions = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: SharedPreferencesUtil().onboardingCompleted ? true : false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.appLogo,
            height: 30.h,
          ),

          /// Bluetooth Animation or Loading Indicator
          if (isScanning)
            BleAnimation(
              minRadius: 40.h,
              ripplesCount: 6,
              duration: const Duration(milliseconds: 3000),
              repeat: true,
              child: Icon(
                Icons.bluetooth_searching,
                color: AppColors.white,
                size: 30.h,
              ),
            )
          else if (deviceList.isEmpty && enableInstructions)
            const Text(
              'No devices found. Please try again or contact support.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

          // Display Found Devices
          FoundDevices(deviceList: deviceList, goNext: widget.goNext),

          // Contact Support Button
          if (deviceList.isEmpty && enableInstructions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: ElevatedButton(
                onPressed: () =>
                    launchUrl(Uri.parse('mailto:craftechapps@gmail.com')),
                child: Container(
                  width: double.infinity,
                  height: 45,
                  alignment: Alignment.center,
                  child: const Text(
                    'Contact Support ?',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
