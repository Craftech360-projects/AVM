import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/features/chat/presentation/pages/chat_page.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/pages/settings/profile.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/chats/presentation/pages/chats_page.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/add_ons.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/language_dropdown.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';
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
        // backgroundColor: const Color(0xFFE6F5FA),
        backgroundColor: const Color(0xFFE6F5FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pushNamed(ChatsPage.name); // Go back to the previous screen
          },
        ),
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
            title: Text(
              'Device Battery - 66%',
              style: textTheme.bodyLarge,
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
          AddOns(
            title: 'Profile',
            onPressed: () {
              context.goNamed(ProfilePage.name);
            },
          ),
          AddOns(
            title: 'Calender Integration',
            onPressed: () {
              context.pushNamed(CalendarPage.name);
            },
          ),
          AddOns(
            title: 'Developer Option',
            onPressed: () {},
          ),
          const FloatingActionButton(
            onPressed: scanBleDevice,
            child: Text('Scan Device'),
          ),
          FloatingActionButton(
            onPressed: () => selectBleDevice(remoteId: 'C4:E8:E3:9F:D2:AE'),
            child: const Text('Select Device'),
          ),
          FloatingActionButton(
            onPressed: () => disconnectBleDevice(remoteId: 'C4:E8:E3:9F:D2:AE'),
            child: const Text('Disconnect Device'),
          ),
        ],
      ),
    );
  }
}

void scanBleDevice() async {
  // Variable to prevent repeated scans or stopping already stopped scans
  bool isScanning = false;
  final List<String> detectedDevices =
      []; // Track detected devices by their IDs

  // Listen for Bluetooth state changes
  StreamSubscription<BluetoothAdapterState> subscription =
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
    print('Bluetooth Adapter State: $state');

    if (state == BluetoothAdapterState.on && !isScanning) {
      print('Starting continuous BLE scan...');
      isScanning = true;

      // Start scanning without timeout for continuous scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [Guid("19b10000-e8f2-537e-4f6c-d104768a1214")],
      );

      // Listen for scan results continuously
      FlutterBluePlus.scanResults.listen((List<ScanResult> results) async {
        for (ScanResult result in results) {
          String deviceId = result.device.remoteId.toString();

          // Check if the device has already been detected to avoid duplicate logs
          if (!detectedDevices.contains(deviceId)) {
            detectedDevices.add(deviceId);
            print(
                '${result.device.remoteId}: "${result.advertisementData.advName}" found!');
          }
        }
      }, onError: (error) {
        print("Scan error: $error");
        if (isScanning) {
          FlutterBluePlus.stopScan();
          isScanning = false;
        }
      });
    } else if (state == BluetoothAdapterState.off) {
      if (Platform.isAndroid) {
        print("Bluetooth is off. Requesting to turn on Bluetooth...");
        FlutterBluePlus.turnOn(); // Requests Bluetooth to be enabled on Android
      } else {
        print("Please enable Bluetooth.");
      }
    }
  });

  // Optional: Cancel the subscription when done (e.g., on page close)
  // subscription.cancel();
}

void selectBleDevice({required String remoteId}) async {
  final device = BluetoothDevice.fromId(remoteId);

  await device.connect(mtu: null, autoConnect: true);

  device.connectionState.listen((BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.connected) {
      print('Connected to the device!');

      ///! BATTERY LISTENER
      // Discover services
      final batteryService =
          await getServiceByUuid(remoteId, batteryServiceUuid);

      if (batteryService == null) {
        print("Battery service not found!");
        return;
      }

      // Get the characteristic
      BluetoothCharacteristic? batteryLevelCharacteristic =
          getCharacteristicByUuid(
              batteryService, batteryLevelCharacteristicUuid);

      if (batteryLevelCharacteristic == null) {
        print("Battery level characteristic not found!");
        return;
      }

      // Enable notifications on the characteristic
      await batteryLevelCharacteristic.setNotifyValue(true);

      // Listen for characteristic value changes
      final batteryLevelListener =
          batteryLevelCharacteristic.lastValueStream.listen((value) {
        print('Battery Level: ${value[0]}%');
        if (value.isNotEmpty) {}
      });

      // Dispose of the listener if disconnected
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          print('Disconnected from the device!');
          batteryLevelListener.cancel();
        }
      });
      //! GET AUDIO CODEC
      // Default codec is PCM8
      late int codecId;
      BleAudioCodec codec;
      final getAudioCodec = await getServiceByUuid(remoteId, friendServiceUuid);
      if (getAudioCodec == null) {
        codec = BleAudioCodec.unknown;
        return;
      }

      var audioCodecCharacteristic =
          getCharacteristicByUuid(getAudioCodec, audioCodecCharacteristicUuid);
      if (audioCodecCharacteristic == null) {
        codec = BleAudioCodec.unknown;
        return;
      }

      List<int> codecValue = await audioCodecCharacteristic.read();

      if (codecValue.isNotEmpty) {
        codecId = codecValue.first;
      }

      switch (codecId) {
        case 0:
          codec = BleAudioCodec.pcm16;
        case 1:
          codec = BleAudioCodec.pcm8;
        case 20:
          codec = BleAudioCodec.opus;
        default:
          codec = BleAudioCodec.unknown;
      }

      print('Codec details:$codecId code: $codec');

      //! AUDIO LISTENER
      // Get the "Friend" service by UUID
      final friendService = await getServiceByUuid(remoteId, friendServiceUuid);
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

      // Listen to the audio data stream characteristic
      final StreamSubscription<List<int>> listener =
          audioDataStreamCharacteristic.lastValueStream.listen((value) {
        print('raw audio received $value');
        if (value.isNotEmpty) {
          // Process received audio bytes
        }
      });

      // Automatically cancel the listener on device disconnection
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('Device disconnected, canceling audio listener.');
          listener.cancel();
        }
      });

      // For Android, request a higher MTU to accommodate larger audio packets
      if (Platform.isAndroid) {
        await device.requestMtu(512);
      }
    }
  });
}

void disconnectBleDevice({required String remoteId}) async {
  final device = BluetoothDevice.fromId(remoteId);
  await device.disconnect();
}

enum BleAudioCodec { pcm16, pcm8, mulaw16, mulaw8, opus, unknown }
