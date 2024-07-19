import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:AVMe/backend/schema/bt_device.dart';

const String batteryServiceUuid = '0000180f-0000-1000-8000-00805f9b34fb';
const String audioBytesServiceUuid = '19b10000-e8f2-537e-4f6c-d104768a1214';

// Future<String?> bleReceiveData(BTDeviceStruct btDevice) async {
//   final device = BluetoothDevice.fromId(btDevice.id);
//   final services = await device.discoverServices();
//   for (BluetoothService service in services) {
//     for (BluetoothCharacteristic characteristic in service.characteristics) {
//       final isRead = characteristic.properties.read;
//       final isNotify = characteristic.properties.notify;
//       if (isRead && isNotify) {
//         final value = await characteristic.read();
//         return String.fromCharCodes(value);
//       }
//     }
//   }
//   return null;
// }
//
// Future bleSendData(BTDeviceStruct btDevice, String data) async {
//   final device = BluetoothDevice.fromId(btDevice.id);
//   final services = await device.discoverServices();
//   for (BluetoothService service in services) {
//     for (BluetoothCharacteristic characteristic in service.characteristics) {
//       final isWrite = characteristic.properties.write;
//       if (isWrite) {
//         await characteristic.write(data.codeUnits);
//       }
//     }
//   }
// }

Future<int> retrieveBatteryLevel(BTDeviceStruct btDevice) async {
  final device = BluetoothDevice.fromId(btDevice.id);
  final services = await device.discoverServices();
  final batteryService = services.firstWhereOrNull((service) =>
      service.uuid.str128.toLowerCase() ==
      '0000180f-0000-1000-8000-00805f9b34fb');
  if (batteryService != null) {
    var canRead = batteryService.characteristics
        .firstWhereOrNull((characteristic) => characteristic.properties.read);
    var currValue = await canRead?.read();
    if (currValue != null && currValue.isNotEmpty) {
      debugPrint('Battery level: ${currValue[0]}');
      return currValue[0];
    }
  }
  return -1;
}

Future<StreamSubscription<List<int>>?> getBleBatteryLevelListener(
  BTDeviceStruct btDevice, {
  void Function(int)? onBatteryLevelChange,
}) async {
  final device = BluetoothDevice.fromId(btDevice.id);
  final services = await device.discoverServices();
  final batteryService = services.firstWhereOrNull((service) =>
      service.uuid.str128.toLowerCase() ==
      '0000180f-0000-1000-8000-00805f9b34fb');
  if (batteryService != null) {
    var canRead = batteryService.characteristics
        .firstWhereOrNull((characteristic) => characteristic.properties.read);
    var currValue = await canRead?.read();
    if (currValue != null && currValue.isNotEmpty) {
      debugPrint('Battery level: ${currValue[0]}');
      onBatteryLevelChange!(currValue[0]);
    }
    var canNotify = batteryService.characteristics
        .firstWhereOrNull((characteristic) => characteristic.properties.notify);
    if (canRead != null && canNotify != null) {
      await canNotify.setNotifyValue(true);
      return canNotify.lastValueStream.listen((value) {
        // debugPrint('Battery level listener: $value');
        if (value.isNotEmpty) {
          onBatteryLevelChange!(value[0]);
        }
      });
    }
  }
  return null;
}

// Future<StreamSubscription?> getBleAudioBytesListener(
//   String deviceId, {
//   required void Function(List<int>) onAudioBytesReceived,
// }) async {
//   final device = BluetoothDevice.fromId(deviceId);
//   // await device.connect();
//   final services = await device.discoverServices();
//   final bytesService = services.firstWhereOrNull((service) =>
//       service.uuid.str128.toLowerCase() ==
//       '19b10000-e8f2-537e-4f6c-d104768a1214');

//   if (bytesService != null) {
//     var canNotify = bytesService.characteristics.firstWhereOrNull(
//         (characteristic) =>
//             characteristic.uuid.str128.toLowerCase() ==
//                 '19b10001-e8f2-537e-4f6c-d104768a1214' ||
//             characteristic.uuid.str128.toLowerCase() ==
//                 '19b10002-e8f2-537e-4f6c-d104768a1214');
//     if (canNotify != null) {
//       await canNotify.setNotifyValue(true);
//       debugPrint('Subscribed to characteristic: ${canNotify.uuid.str128}');
//       var listener = canNotify.lastValueStream.listen((value) {
//         if (value.isNotEmpty) onAudioBytesReceived(value);
//       });
//       device.cancelWhenDisconnected(listener);
//       return listener;
//     }
//   }
//   debugPrint('Desired audio characteristic not found');
//   return null;
// }

Future<List<BluetoothService>> getBleServices(String deviceId) async {
  final device = BluetoothDevice.fromId(deviceId);
  try {
    return await device.discoverServices();
  } catch (e, stackTrace) {
    print(e);
    // CrashReporting.reportHandledCrash(
    //   e,
    //   stackTrace,
    //   level: NonFatalExceptionLevel.error,
    //   userAttributes: {'deviceId': deviceId},
    // );
    return [];
  }
}

Future<BluetoothService?> getServiceByUuid(String deviceId, String uuid) async {
  final services = await getBleServices(deviceId);
  return services
      .firstWhereOrNull((service) => service.uuid.str128.toLowerCase() == uuid);
}

BluetoothCharacteristic? getCharacteristicByUuid(
    BluetoothService service, String uuid) {
  return service.characteristics.firstWhereOrNull(
    (characteristic) =>
        characteristic.uuid.str128.toLowerCase() == uuid.toLowerCase(),
  );
}

Future<StreamSubscription?> getBleAudioBytesListener(
  String deviceId, {
  required void Function(List<int>) onAudioBytesReceived,
}) async {
  final device = BluetoothDevice.fromId(deviceId);
  final bytesService = await getServiceByUuid(deviceId, audioBytesServiceUuid);

  if (bytesService == null) return null;
  var streamCharacteristic = getCharacteristicByUuid(
      bytesService, '19b10001-e8f2-537e-4f6c-d104768a1214');
  var codecCharacteristic = getCharacteristicByUuid(
      bytesService, '19b10002-e8f2-537e-4f6c-d104768a1214');

  if (streamCharacteristic != null && codecCharacteristic != null) {
    try {
      await streamCharacteristic
          .setNotifyValue(true); // device could be disconnected here.
    } catch (e, stackTrace) {
      debugPrint('Error setting notify value: $e');
      // CrashReporting.reportHandledCrash(
      //   e,
      //   stackTrace,
      //   level: NonFatalExceptionLevel.error,
      //   userAttributes: {'deviceId': deviceId},
      // );
      return null;
    }
    if (Platform.isAndroid)
      await device.requestMtu(512); // FORCING REQUEST AGAIN OF MTU

    debugPrint('Subscribed to audioBytes stream from AVM Device');
    var listener = streamCharacteristic.lastValueStream.listen((value) {
      if (value.isNotEmpty) onAudioBytesReceived(value);
    });
    device.cancelWhenDisconnected(listener);
    return listener;
  }
  debugPrint('Desired audio characteristic not found');
  return null;
}
