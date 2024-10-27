import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/utils/ble/errors.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';

enum BleAudioCodec { pcm16, pcm8, mulaw16, mulaw8, opus, unknown }

class BleConnectionDatasource {
  Future<List<BTDeviceStruct>> bleFindDevices() async {
    List<BTDeviceStruct> devices = [];
    StreamSubscription<List<ScanResult>>? scanSubscription;

    try {
      if ((await FlutterBluePlus.isSupported) == false) return [];

      // Listen to scan results
      scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          List<ScanResult> scannedDevices =
              results.where((r) => r.device.platformName.isNotEmpty).toList();
          scannedDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

          devices = scannedDevices.map((deviceResult) {
            return BTDeviceStruct(
              name: deviceResult.device.platformName,
              id: deviceResult.device.remoteId.str,
              rssi: deviceResult.rssi,
            );
          }).toList();
        },
        onError: (e) {
          debugPrint('bleFindDevices error: $e');
        },
      );

      // Start scanning if not already scanning
      // Only look for devices that implement Friend main service
      if (!FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5),
          withServices: [Guid("19b10000-e8f2-537e-4f6c-d104768a1214")],
        );
      }
    } finally {
      // Cancel subscription to avoid memory leaks
      await scanSubscription?.cancel();
    }

    return devices;
  }

  Future<void> bleConnectDevice(String deviceId,
      {bool autoConnect = true}) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      // TODO: for android seems like the reconnect or resetState is not working
      if (!autoConnect)
        return await device.connect(autoConnect: false, mtu: null);

      // Step 1: Connect with autoConnect
      await device.connect(autoConnect: true, mtu: null);
      // Step 2: Listen to the connection state to ensure the device is connected
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first;

      // Step 3: Request the desired MTU size if the platform is Android
      if (Platform.isAndroid) await device.requestMtu(512);
    } catch (e) {
      debugPrint('bleConnectDevice failed: $e');
    }
  }

  Future<int> retrieveBatteryLevel(String deviceId) async {
    final batteryService = await getServiceByUuid(deviceId, batteryServiceUuid);
    if (batteryService == null) {
      logServiceNotFoundError('Battery', deviceId);
      return -1;
    }

    var batteryLevelCharacteristic =
        getCharacteristicByUuid(batteryService, batteryLevelCharacteristicUuid);
    if (batteryLevelCharacteristic == null) {
      logCharacteristicNotFoundError('Battery level', deviceId);
      return -1;
    }

    var currValue = await batteryLevelCharacteristic.read();
    if (currValue.isNotEmpty) {
      return currValue[0];
    }

    return -1;
  }

  Future<BTDeviceStruct?> scanAndConnectDevice(
      {bool autoConnect = true, bool timeout = false}) async {
    debugPrint('scanAndConnectDevice');
    var deviceId = SharedPreferencesUtil().deviceId;
    debugPrint('scanAndConnectDevice $deviceId');
    for (var device in FlutterBluePlus.connectedDevices) {
      if (device.remoteId.str == deviceId) {
        return BTDeviceStruct(
          id: device.remoteId.str,
          name: device.platformName,
          rssi: await device.readRssi(),
        );
      }
    }
    int timeoutCounter = 0;
    while (true) {
      if (timeout && timeoutCounter >= 10) return null;
      List<BTDeviceStruct> foundDevices = await bleFindDevices();
      for (BTDeviceStruct device in foundDevices) {
        // Remember the first connected device.
        // Technically, there should be only one
        if (deviceId == '') {
          deviceId = device.id;
          SharedPreferencesUtil().deviceId = device.id;
          SharedPreferencesUtil().deviceName = device.name;
        }

        if (device.id == deviceId) {
          try {
            await bleConnectDevice(device.id, autoConnect: autoConnect);
            return device;
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
      // If the device is not found, wait for a bit before retrying.
      await Future.delayed(const Duration(seconds: 2));
      timeoutCounter += 2;
    }
  }

  Future<BleAudioCodec> getAudioCodec(String deviceId) async {
    final friendService = await getServiceByUuid(deviceId, friendServiceUuid);
    if (friendService == null) {
      logServiceNotFoundError('Friend', deviceId);
      return BleAudioCodec.pcm8;
    }

    var audioCodecCharacteristic =
        getCharacteristicByUuid(friendService, audioCodecCharacteristicUuid);
    if (audioCodecCharacteristic == null) {
      logCharacteristicNotFoundError('Audio codec', deviceId);
      return BleAudioCodec.pcm8;
    }

    // Default codec is PCM8
    int codecId = 1;
    BleAudioCodec codec;

    List<int> codecValue = await audioCodecCharacteristic.read();

    if (codecValue.isNotEmpty) {
      codecId = codecValue.first;
    }

    switch (codecId) {
      // case 0:
      //   codec = BleAudioCodec.pcm16;
      case 1:
        codec = BleAudioCodec.pcm8;
      // case 10:
      //   codec = BleAudioCodec.mulaw16;
      // case 11:
      //   codec = BleAudioCodec.mulaw8;
      case 20:
        codec = BleAudioCodec.opus;
      default:
        codec = BleAudioCodec.pcm8;
    }

    debugPrint('Codec is $codecId');
    return codec;
  }

  ///!second time
  StreamSubscription<OnConnectionStateChangedEvent>?
      getConnectionStateListener({
    required String deviceId,
    required Function onDisconnected,
    required Function(BTDeviceStruct) onConnected,
  }) {
    return FlutterBluePlus.events.onConnectionStateChanged
        .listen((event) async {
      debugPrint(
          'onConnectionStateChanged: ${event.device.remoteId.str} ${event.connectionState}');
      if (event.device.remoteId.str == deviceId) {
        if (event.connectionState == BluetoothConnectionState.disconnected) {
          onDisconnected();
        } else if (event.connectionState ==
            BluetoothConnectionState.connected) {
          print('Connected to ${event.device.platformName}');
          onConnected(
            BTDeviceStruct(
              id: event.device.remoteId.str,
              name: event.device.platformName,
              rssi: await event.device.readRssi(),
            ),
          );
        }
      }
    });
  }

  Future<BTDeviceStruct?> getConnectedDevice() async {
    var deviceId = SharedPreferencesUtil().deviceId;
    for (var device in FlutterBluePlus.connectedDevices) {
      if (device.remoteId.str == deviceId) {
        return BTDeviceStruct(
          id: device.remoteId.str,
          name: device.platformName,
          rssi: await device.readRssi(),
        );
      }
    }
    debugPrint('getConnectedDevice: device not found');
    return null;
  }

  Future<StreamSubscription<List<int>>?> getBleBatteryLevelListener(
    String deviceId, {
    void Function(int)? onBatteryLevelChange,
  }) async {
    print('ble devices list');
    final batteryService = await getServiceByUuid(deviceId, batteryServiceUuid);
    if (batteryService == null) {
      logServiceNotFoundError('Battery', deviceId);
      return null;
    }

    BluetoothCharacteristic? batteryLevelCharacteristic =
        getCharacteristicByUuid(batteryService, batteryLevelCharacteristicUuid);

    try {
      await batteryLevelCharacteristic?.setNotifyValue(true);
    } catch (e, stackTrace) {
      logSubscribeError('Battery level', deviceId, e, stackTrace);
      return null;
    }

    var listener = batteryLevelCharacteristic?.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        onBatteryLevelChange?.call(value[0]);
      }
    });

    return listener;
  }

  ///! not sure but this will be continiously listening the audio device
  Future<StreamSubscription?> getBleAudioBytesListener(
    String deviceId, {
    required void Function(List<int>) onAudioBytesReceived,
  }) async {
    final friendService = await getServiceByUuid(deviceId, friendServiceUuid);
    if (friendService == null) {
      logServiceNotFoundError('Friend', deviceId);
      return null;
    }

    var audioDataStreamCharacteristic = getCharacteristicByUuid(
        friendService, audioDataStreamCharacteristicUuid);
    if (audioDataStreamCharacteristic == null) {
      logCharacteristicNotFoundError('Audio data stream', deviceId);
      return null;
    }

    try {
      await audioDataStreamCharacteristic
          .setNotifyValue(true); // device could be disconnected here.
    } catch (e, stackTrace) {
      logSubscribeError('Audio data stream', deviceId, e, stackTrace);
      return null;
    }

    debugPrint('Subscribed to audioBytes stream from AVM Device');
    var listener =
        audioDataStreamCharacteristic.lastValueStream.listen((value) {
      if (value.isNotEmpty) onAudioBytesReceived(value);
    });

    final device = BluetoothDevice.fromId(deviceId);
    device.cancelWhenDisconnected(listener);

    // This will cause a crash in OpenGlass devices
    // due to a race with discoverServices() that triggers
    // a bug in the device firmware.
    if (Platform.isAndroid) await device.requestMtu(512);

    return listener;
  }

  Future bleDisconnectDevice(BTDeviceStruct btDevice) async {
    final device = BluetoothDevice.fromId(btDevice.id);
    try {
      await device.disconnect();
    } catch (e) {
      debugPrint('bleDisconnectDevice failed: $e');
    }
  }
}
