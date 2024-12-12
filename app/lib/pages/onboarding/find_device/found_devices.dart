import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/wizard/pages/finalize_page.dart';
import 'package:friend_private/pages/home/page.dart';
import 'package:friend_private/src/common_widget/elevated_button.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:friend_private/utils/ble/connect.dart';
import 'package:friend_private/utils/other/temp.dart';

class FoundDevices extends StatefulWidget {
  final List<BTDeviceStruct> deviceList;
  final VoidCallback goNext;

  const FoundDevices({
    super.key,
    required this.deviceList,
    required this.goNext,
  });

  @override
  FoundDevicesState createState() => FoundDevicesState();
}

class FoundDevicesState extends State<FoundDevices>
    with TickerProviderStateMixin {
  bool _isClicked = false;
  bool _isConnected = false;
  int batteryPercentage = -1;
  String deviceName = '';
  String deviceId = '';
  String? _connectingToDeviceId;

  Future<void> setBatteryPercentage(BTDeviceStruct btDevice) async {
    try {
      var battery = await retrieveBatteryLevel(btDevice.id);
      setState(() {
        batteryPercentage = battery;
        _isConnected = true;
        _isClicked = false;
        _connectingToDeviceId = null;
      });
      await Future.delayed(const Duration(seconds: 2));
      SharedPreferencesUtil().deviceId = btDevice.id;
      SharedPreferencesUtil().deviceName = btDevice.name;
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        if (SharedPreferencesUtil().onboardingCompleted) {
          // previous users
          routeToPage(context, const HomePageWrapper(), replace: true);
        } else {
          SharedPreferencesUtil().onboardingCompleted = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => FinalizePage(
                goNext: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      log("Error fetching battery level: $e");
      setState(() {
        _isClicked = false;
        _connectingToDeviceId = null;
      });
    }
  }

  Future<void> handleTap(BTDeviceStruct device) async {
    if (_isClicked) return;
    setState(() {
      _isClicked = true;
      _connectingToDeviceId = device.id;
    });
    await bleConnectDevice(device.id);
    deviceId = device.id;
    deviceName = device.name;
    setBatteryPercentage(device);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !_isConnected
              ? Text(
                  widget.deviceList.isEmpty
                      ? 'Searching for devices...'
                      : '${widget.deviceList.length} ${widget.deviceList.length == 1 ? "DEVICE" : "DEVICES"} FOUND',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.black),
                )
              : const Text(
                  'PAIRING SUCCESSFUL',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.black),
                ),
          if (widget.deviceList.isNotEmpty) const SizedBox(height: 16),
          if (!_isConnected) ..._devicesList(),
          if (_isConnected)
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black),
                  borderRadius: br30),
              height: 55.h,
              width: double.maxFinite,
              child: CustomElevatedButton(
                backgroundColor: AppColors.white,
                onPressed: () async {
                  if (SharedPreferencesUtil().onboardingCompleted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePageWrapper(),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, 6)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      '🔋 ${batteryPercentage.toString()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: batteryPercentage <= 25
                            ? Colors.red
                            : batteryPercentage > 25 && batteryPercentage <= 50
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          //   child: CustomElevatedButton(
          //     backgroundColor: AppColors.white,
          //     onPressed: () {
          //       // if (widget.device != null) {
          //       //   BleConnectionDatasource().bleDisconnectDevice(widget.device!);
          //       // }
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, 6)})',
          //           style: const TextStyle(
          //             fontWeight: FontWeight.w500,
          //             fontSize: 18,
          //             color: AppColors.black,
          //           ),
          //         ),
          //         Text(
          //           '🔋 ${batteryPercentage.toString()}%',
          //           style: TextStyle(
          //             fontWeight: FontWeight.w500,
          //             fontSize: 18,
          //             color: batteryPercentage <= 25
          //                 ? Colors.red
          //                 : batteryPercentage > 25 && batteryPercentage <= 50
          //                     ? Colors.orange
          //                     : Colors.green,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<Widget> _devicesList() {
    return widget.deviceList
        .map((device) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0), // Add space here
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black),
                  borderRadius: br30,
                ),
                height: 55.h,
                width: double.maxFinite,
                child: CustomElevatedButton(
                  onPressed: !_isClicked ? () => handleTap(device) : () {},
                  backgroundColor: AppColors.white,
                  child: ListTile(
                    visualDensity: const VisualDensity(vertical: -3),
                    title: Text(
                      '${device.name} (${device.id.replaceAll(':', '').split('-').last.substring(0, 6)})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    trailing: _connectingToDeviceId == device.id
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ))
        .toList();
  }
}
