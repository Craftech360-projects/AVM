import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/home/device.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/developer_page.dart';
import 'package:friend_private/pages/settings/profile.dart';
import 'package:friend_private/pages/settings/widgets.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/language_dropdown.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';
import 'package:friend_private/utils/other/temp.dart';

class SettingPage extends StatefulWidget {
  final BTDeviceStruct? device;
  final int batteryLevel;

  const SettingPage({
    this.device,
    this.batteryLevel = -1,
    super.key,
  });

  static const String name = 'settingPage';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();

    // Print the incoming battery level
    print('Incoming battery level: ${widget.batteryLevel}');

    // Print the connected device details if available
    if (widget.device != null) {
      print(
          'Connected device: ${widget.device!.name} (ID: ${widget.device!.id})');
    } else {
      print('No connected device provided.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F5FA),
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        children: [
          CustomListTile(
            onTap: () {
              if (widget.device != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnectedDevice(
                      device: widget.device,
                      batteryLevel: widget.batteryLevel,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindDevicesPage(
                      goNext: () {},
                    ),
                  ),
                );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BleConnectionPage(),
                //   ),
                // );
              }
            },
            title: Text(
              widget.batteryLevel > 0
                  ? 'Battery Level: ${widget.batteryLevel}%'
                  : 'Device not connected',
            ),

            // title: BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
            //   builder: (context, state) {
            //     if (state.bleBatteryLevel != null) {
            //       return Text('Battery Level: ${widget.batteryLevel}%',
            //           style: TextStyle(fontSize: 16));
            //     } else {
            //       return Text('Battery Level: Unknown',
            //           style: TextStyle(fontSize: 16));
            //     }
            //   },
            // ),
            trailing: const CircleAvatar(
              backgroundColor: CustomColors.greyLavender,
              child: Icon(Icons.bluetooth_searching),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Recording Setting',
            style: textTheme.titleMedium?.copyWith(fontSize: 20.h),
          ),
          SizedBox(height: 16.h),
          const LanguageDropdown(),
          SizedBox(height: 16.h),
          Text(
            'Add Ons',
            style: textTheme.titleMedium?.copyWith(fontSize: 20.h),
          ),
          SizedBox(height: 16.h),
          // AddOns(
          //   title: 'Profile',
          //   onPressed: () {},
          // ),
          // AddOns(
          //   title: 'Calender Integration',
          //   onPressed: () {},
          // ),
          // AddOns(
          //   title: 'Developer Option',
          //   onPressed: () {},
          // ),

          getItemAddOn('Profile', () {
            routeToPage(context, const ProfilePage());
          }, icon: Icons.person),
          getItemAddOn('Calendar Integration', () {
            routeToPage(context, const CalendarPage());
          }, icon: Icons.calendar_month),
          getItemAddOn('Developers Option', () {
            routeToPage(context, const DeveloperPage());
          }, icon: Icons.settings_suggest),
          // const FloatingActionButton(
          //   onPressed: scanBleDevice,
          //   child: Text('Scan Device'),
          // ),
          // FloatingActionButton(
          //   onPressed: () => selectBleDevice(remoteId: 'C4:E8:E3:9F:D2:AE'),
          //   child: const Text('Select Device'),
          // ),
          // FloatingActionButton(
          //   onPressed: () => disconnectBleDevice(remoteId: 'C4:E8:E3:9F:D2:AE'),
          //   child: const Text('Disconnect Device'),
          // ),
          const SizedBox(height: 80),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Version:', //  $version+$buildVersion',
                style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void selectBleDevice({required String remoteId}) async {
  final device = BluetoothDevice.fromId(remoteId);

  await device.connect(mtu: null, autoConnect: true);

  device.connectionState.listen((BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.connected) {
      print('Connected to the device!');

      // print('Codec details:$codecId code: $codec');

      //! AUDIO LISTENER
      // Get the "Friend" service by UUID
      final friendService = await getServiceByUuid(remoteId, friendServiceUuid);
      print('setting page audio byte $remoteId:$friendServiceUuid');
      if (friendService == null) {
        return;
      }

      // Get the audio data stream characteristic by UUID
      var audioDataStreamCharacteristic = getCharacteristicByUuid(
          friendService, audioDataStreamCharacteristicUuid);
      if (audioDataStreamCharacteristic == null) {
        return;
      }

      // Enable notifications for the audio data characteristic

      await audioDataStreamCharacteristic.setNotifyValue(true);

      debugPrint('Subscribed to audioBytes stream from AVM Device');
      if (Platform.isAndroid) {
        await device.requestMtu(512);
      }
      // Listen to the audio data stream characteristic
      final StreamSubscription<List<int>> listener =
          audioDataStreamCharacteristic.lastValueStream.listen((value) {
        print('raw audio received $value');
        if (value.isNotEmpty) {
          // Process received audio bytes
        }
      });
    }
  });
}

void disconnectBleDevice({required String remoteId}) async {
  final device = BluetoothDevice.fromId(remoteId);
  await device.disconnect();
}

enum BleAudioCodec { pcm16, pcm8, mulaw16, mulaw8, opus, unknown }
