import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/developer_page.dart';
import 'package:friend_private/pages/settings/profile.dart';
import 'package:friend_private/pages/settings/widgets.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/live_transcript/live_transcript_bloc.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/add_ons.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/language_dropdown.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
  });
  static const String name = 'settingPage';
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
              context.pushNamed(BleConnectionPage.name);
            },
            title: BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
              bloc: context.read<LiveTranscriptBloc>(),
              builder: (context, state) {
                return Text(
                  'Battery Level: ${state.bleBatteryLevel}%',
                  style: textTheme.bodyLarge,
                );
              },
            ),
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
              child: const Text(
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
      print('setting page audio byte ${remoteId}:$friendServiceUuid');
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
