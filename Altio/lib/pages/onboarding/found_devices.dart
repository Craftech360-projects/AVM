import 'dart:async';
import 'dart:developer';

import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/elevated_button.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/features/wizard/pages/finalize_page.dart';
import 'package:altio/pages/home/page.dart';
import 'package:altio/utils/ble/communication.dart';
import 'package:altio/utils/ble/connect.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final user = FirebaseAuth.instance.currentUser;

  Future<void> setBatteryPercentage(BTDeviceStruct btDevice) async {
    try {
      var battery = await retrieveBatteryLevel(btDevice.id);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await DeviceFlagService()
            .updateDeviceFlag(uid: user.uid, hasDevice: true);
      }
      setState(() {
        batteryPercentage = battery;
        _isConnected = true;
        _isClicked = false;
        _connectingToDeviceId = null;
      });

      if (!mounted) return;
      context.read<BluetoothBloc>().add(
          BluetoothConnectedEvent(device: btDevice, batteryLevel: battery));

      // Persist device info if needed.
      SharedPreferencesUtil().deviceId = btDevice.id;
      SharedPreferencesUtil().deviceName = btDevice.name;

      // Add a delay for smoother UX.
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Use the provided callback for navigation.
        if (SharedPreferencesUtil().onboardingCompleted) {
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePageWrapper(tabIndex: 0),
              ));
        } else {
          SharedPreferencesUtil().onboardingCompleted = true;
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FinalizePage(goNext: widget.goNext),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var zoomOutAnimation = Tween(begin: 1.0, end: 0.9).animate(
                  CurvedAnimation(
                      parent: secondaryAnimation, curve: Curves.easeOut),
                );
                return ScaleTransition(scale: zoomOutAnimation, child: child);
              },
            ),
          );
        }
      }
    } on Exception catch (e) {
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
    await setBatteryPercentage(device);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    color: AppColors.black,
                  ),
                )
              : const Text(
                  'PAIRING SUCCESSFUL',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
          if (widget.deviceList.isNotEmpty) const SizedBox(height: 16),
          if (!_isConnected) ..._devicesList(),
          if (_isConnected)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              height: 50,
              width: double.infinity,
              child: CustomElevatedButton(
                backgroundColor: AppColors.white,
                onPressed: () async {
                  if (SharedPreferencesUtil().onboardingCompleted) {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePageWrapper()),
                    );
                  }
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, 6)})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Text(
                        '🔋 ${batteryPercentage.toString()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: batteryPercentage <= 25
                              ? Colors.red
                              : batteryPercentage <= 50
                                  ? Colors.orange
                                  : Colors.green,
                        ),
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

  List<Widget> _devicesList() {
    return widget.deviceList.map((device) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 55,
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: !_isClicked ? () => handleTap(device) : () {},
          backgroundColor: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${device.name} (${device.id.replaceAll(':', '').split('-').last.substring(0, 6)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              w4,
              _connectingToDeviceId == device.id
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.black),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      );
    }).toList();
  }
}
