import 'package:flutter/material.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';
import 'package:friend_private/utils/ble/connect.dart';
import 'package:friend_private/widgets/device_widget.dart';

class ConnectedDevice extends StatefulWidget {
  final BTDeviceStruct? device;
  final int batteryLevel;
  const ConnectedDevice(
      {super.key, required this.device, required this.batteryLevel});

  @override
  State<ConnectedDevice> createState() => _ConnectedDeviceState();
}

class _ConnectedDeviceState extends State<ConnectedDevice> {
  @override
  Widget build(BuildContext context) {
    var deviceId = SharedPreferencesUtil().deviceId;
    var deviceName = SharedPreferencesUtil().deviceName;
    var deviceConnected = widget.device != null;

    return CustomScaffold(
        appBar: AppBar(
          title: Text(deviceConnected ? 'Connected Device' : 'Paired Device'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: const Color(0xFFE6F5FA),
        body: Column(
          children: [
            const SizedBox(height: 32),
            const DeviceAnimationWidget(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, deviceId.replaceAll(':', '').split('-').last.length > 6 ? 6 : deviceId.replaceAll(':', '').split('-').last.length)})',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Column(
                  children: [
                    Text(
                      '',
                      // '${state.connectedDevice?.name}, firmware ${state.codec ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Craftech 360",
                      // 'by ${state.connectedDevice?.manufacturerName ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                  ],
                ),
                widget.device != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.greyLavender,
                // border: Border.all(color: AppColors.purpleBright),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () {
                  if (widget.device != null) {
                    bleDisconnectDevice(widget.device!);
                  }
                  Navigator.of(context).pop();
                  SharedPreferencesUtil().deviceId = '';
                  SharedPreferencesUtil().deviceName = '';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Your AVM is ${widget.device == null ? "unpaired" : "disconnected"}'),
                  ));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindDevicesPage(
                        goNext: () {},
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.device == null ? "Unpair" : "Disconnect",
                  style: const TextStyle(color: AppColors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ));
  }
}
