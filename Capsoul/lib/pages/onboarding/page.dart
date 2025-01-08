import 'dart:async';
import 'dart:io';

import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/core/assets/app_images.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/features/wizard/widgets/ble_animation.dart';
import 'package:capsoul/pages/home/custom_scaffold.dart';
import 'package:capsoul/utils/ble/find.dart';
import 'package:capsoul/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late Timer _didNotMakeItTimer;
  late Timer _findDevicesTimer;
  bool enableInstructions = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scanDevices();
    });
  }

  @override
  void dispose() {
    _findDevicesTimer.cancel();
    _didNotMakeItTimer.cancel();
    super.dispose();
  }

  Future<void> _scanDevices() async {
    // check if bluetooth is enabled on Android
    if (Platform.isAndroid) {
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (e) {
          if (e is FlutterBluePlusException) {
            if (e.code == 11) {
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
                    'Friend needs Bluetooth to connect to your wearable. Please enable Bluetooth and try again.',
                    singleButton: true,
                  ),
                );
              }
            }
          }
        }
      }
    }

    _didNotMakeItTimer = Timer(const Duration(seconds: 10),
        () => setState(() => enableInstructions = true));
    // Update foundDevicesMap with new devices and remove the ones not found anymore
    Map<String, BTDeviceStruct> foundDevicesMap = {};

    _findDevicesTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      List<BTDeviceStruct> foundDevices = await bleFindDevices();

      // Update foundDevicesMap with new devices and remove the ones not found anymore
      Map<String, BTDeviceStruct> updatedDevicesMap = {};
      for (final device in foundDevices) {
        // If it's a new device, add it to the map. If it already exists, this will just update the entry.
        updatedDevicesMap[device.id] = device;
      }
      // Remove devices that are no longer found
      foundDevicesMap.keys
          .where((id) => !updatedDevicesMap.containsKey(id))
          .toList()
          .forEach(foundDevicesMap.remove);

      // Merge the new devices into the current map to maintain order
      foundDevicesMap.addAll(updatedDevicesMap);

      // Convert the values of the map back to a list
      List<BTDeviceStruct> orderedDevices = foundDevicesMap.values.toList();

      if (orderedDevices.isNotEmpty) {
        setState(() {
          deviceList = orderedDevices;
        });
        _didNotMakeItTimer.cancel();
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
          // SizedBox(height: 150.h),

          /// Bluetooth Animation
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
          ),
          // SizedBox(height: 140.h),

          FoundDevices(deviceList: deviceList, goNext: widget.goNext),
          // if (deviceList.isEmpty && enableInstructions)
          //   const SizedBox(height: 48),
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
                      color: AppColors.black,
                      decoration: TextDecoration.underline,
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
