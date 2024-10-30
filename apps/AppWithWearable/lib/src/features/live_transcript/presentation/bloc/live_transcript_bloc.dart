import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';

part 'live_transcript_event.dart';
part 'live_transcript_state.dart';

class LiveTranscriptBloc
    extends Bloc<LiveTranscriptEvent, LiveTranscriptState> {
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<List<int>>? batteryLevelListener;
  LiveTranscriptBloc() : super(LiveTranscriptState.initial()) {
    on<ScannedDevices>(
      (event, emit) async {
        List<BTDeviceStruct> devices = [];
        emit(state.copyWith(bleConnectionStatus: BleConnectionStatus.loading));
        // try {
        if ((await FlutterBluePlus.isSupported) == false) {
          LiveTranscriptState.initial();
        }

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
            print('bleFindDevices error: $e');
            emit(
              state.copyWith(
                errorMessage: e.toString(),
                bleConnectionStatus: BleConnectionStatus.failure,
              ),
            );
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
        // }
        // finally {
        //   // Cancel subscription to avoid memory leaks
        //   // await scanSubscription?.cancel();
        // }

        emit(
          state.copyWith(
            bleConnectionStatus: BleConnectionStatus.scanning,
            visibleDevices: devices,
          ),
        );
      },
    );
    on<SelectedDevice>(
      (event, emit) async {
        final String deviceId = event.deviceId;
        final bool autoConnect = event.autoConnect;
        final device = BluetoothDevice.fromId(deviceId);
        try {
          emit(
              state.copyWith(bleConnectionStatus: BleConnectionStatus.loading));
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
          print('ble devices list');
          final batteryService =
              await getServiceByUuid(deviceId, batteryServiceUuid);
          if (batteryService == null) {
            // logServiceNotFoundError('Battery', deviceId);
            return;
          }

          BluetoothCharacteristic? batteryLevelCharacteristic =
              getCharacteristicByUuid(
                  batteryService, batteryLevelCharacteristicUuid);

          try {
            await batteryLevelCharacteristic?.setNotifyValue(true);
          } catch (e, stackTrace) {
            // logSubscribeError('Battery level', deviceId, e, stackTrace);
            return;
          }

          batteryLevelListener =
              batteryLevelCharacteristic?.lastValueStream.listen((value) {
            if (value.isNotEmpty) {
              state.copyWith(
                bleConnectionStatus: BleConnectionStatus.connected,
                bleBatteryLevel: value[0],
              );
              // onBatteryLevelChange?.call(value[0]);
            }
          });

          // return listener;
          emit(
            state.copyWith(
                bleConnectionStatus: BleConnectionStatus.connected,
                connectedDevice: BTDeviceStruct(
                  id: event.deviceId,
                  name: 'Friend',
                )),
          );
        } catch (e) {
          emit(
            state.copyWith(
              bleConnectionStatus: BleConnectionStatus.failure,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );
    on<DisconnectDevice>(
      (event, emit) async {
        final device = BluetoothDevice.fromId(event.btDeviceStruct.id);
        try {
          await device.disconnect();
          LiveTranscriptState.initial();
        } catch (e) {
          debugPrint('bleDisconnectDevice failed: $e');
          emit(
            state.copyWith(
              bleConnectionStatus: BleConnectionStatus.failure,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );
  }
  @override
  Future<void> close() async {
    await scanSubscription?.cancel();
    return super.close();
  }
}
