import 'dart:async';

import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/utils/ble/errors.dart';
import 'package:avm/utils/ble/gatt_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

StreamSubscription<BluetoothConnectionState>? getConnectionStateListener({
  required String deviceId,
  required void Function(BluetoothConnectionState state, BTDeviceStruct? device)
      onStateChanged,
}) {
  try {
    final device = FlutterBluePlus.connectedDevices
        .firstWhere((d) => d.remoteId.str == deviceId);

    return device.connectionState.listen((BluetoothConnectionState state) {
      print('Connection state changed: $state');
      if (state == BluetoothConnectionState.connected) {
        onStateChanged(
            state,
            BTDeviceStruct(
              id: device.remoteId.str,
              name: device.platformName,
            ));
      } else {
        onStateChanged(state, null);
      }
    });
  } catch (e) {
    debugPrint('Device not found in connected devices: $deviceId');
    onStateChanged(BluetoothConnectionState.disconnected, null);
    return null;
  }
}

Future<StreamSubscription<List<int>>?> getBleBatteryLevelListener(
  String deviceId, {
  void Function(int)? onBatteryLevelChange,
}) async {
  final batteryService = await getServiceByUuid(deviceId, batteryServiceUuid);
  if (batteryService == null) {
    logServiceNotFoundError('Battery', deviceId);
    return null;
  }

  var batteryLevelCharacteristic =
      getCharacteristicByUuid(batteryService, batteryLevelCharacteristicUuid);
  if (batteryLevelCharacteristic == null) {
    logCharacteristicNotFoundError('Battery level', deviceId);
    return null;
  }

  var currValue = await batteryLevelCharacteristic.read();
  if (currValue.isNotEmpty) {
    debugPrint('Battery level: ${currValue[0]}');
    onBatteryLevelChange!(currValue[0]);
  }

  try {
    await batteryLevelCharacteristic.setNotifyValue(true);
  } catch (e, stackTrace) {
    logSubscribeError('Battery level', deviceId, e, stackTrace);
    return null;
  }

  var listener = batteryLevelCharacteristic.lastValueStream.listen((value) {
    // debugdebugPrint('Battery level listener: $value');
    if (value.isNotEmpty) {
      onBatteryLevelChange!(value[0]);
    }
  });

  final device = BluetoothDevice.fromId(deviceId);
  device.cancelWhenDisconnected(listener);

  return listener;
}
