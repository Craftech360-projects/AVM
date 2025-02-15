import 'dart:async';
import 'dart:developer';

import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/utils/ble/errors.dart';
import 'package:altio/utils/ble/gatt_utils.dart';
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
  return null;
}

StreamSubscription<OnConnectionStateChangedEvent> getConnectionStateListener({
  required String deviceId,
  required Function(BluetoothConnectionState, BTDeviceStruct?) onStateChanged,
}) {
  return FlutterBluePlus.events.onConnectionStateChanged.listen((event) async {
    if (event.device.remoteId.str == deviceId) {
      if (event.connectionState == BluetoothConnectionState.disconnected) {
        onStateChanged(BluetoothConnectionState.disconnected, null);
      } else if (event.connectionState == BluetoothConnectionState.connected) {
        try {
          var deviceInfo = BTDeviceStruct(
            id: event.device.remoteId.str,
            name: event.device.platformName,
            rssi: await event.device.readRssi(),
            // add firmware version
          );
          onStateChanged(BluetoothConnectionState.connected, deviceInfo);
        } on Exception catch (e) {
          log(e.toString());
          onStateChanged(BluetoothConnectionState.disconnected, null);
        }
      }
    }
  });
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
    onBatteryLevelChange!(currValue[0]);
  }

  try {
    await batteryLevelCharacteristic.setNotifyValue(true);
  } on Exception catch (e, stackTrace) {
    logSubscribeError('Battery level', deviceId, e, stackTrace);
    return null;
  }

  var listener = batteryLevelCharacteristic.lastValueStream.listen((value) {
    if (value.isNotEmpty) {
      onBatteryLevelChange!(value[0]);
    }
  });

  final device = BluetoothDevice.fromId(deviceId);
  device.cancelWhenDisconnected(listener);

  return listener;
}
