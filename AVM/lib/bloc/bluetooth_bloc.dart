import 'dart:async';

import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/utils/ble/connected.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Define events
abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
}

class BluetoothDeviceConnected extends BluetoothEvent {
  final BTDeviceStruct device;

  const BluetoothDeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

class BluetoothDeviceDisconnected extends BluetoothEvent {
  @override
  List<Object> get props => [];
}

class BluetoothBatteryLevelUpdated extends BluetoothEvent {
  final int batteryLevel;

  const BluetoothBatteryLevelUpdated(this.batteryLevel);

  @override
  List<Object> get props => [batteryLevel];
}

// Define states
abstract class BluetoothState extends Equatable {
  const BluetoothState();
}

class BluetoothInitial extends BluetoothState {
  @override
  List<Object> get props => [];
}

class BluetoothConnected extends BluetoothState {
  final BTDeviceStruct device;
  final int batteryLevel;

  const BluetoothConnected(this.device, {this.batteryLevel = -1});

  @override
  List<Object> get props => [device, batteryLevel];
}

class BluetoothDisconnected extends BluetoothState {
  @override
  List<Object> get props => [];
}

// Define Bloc
class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(BluetoothInitial()) {
    on<BluetoothDeviceConnected>((event, emit) async {
      emit(BluetoothConnected(event.device));
      await _initiateBleBatteryListener(event.device.id, emit);
    });

    on<BluetoothDeviceDisconnected>((event, emit) {
      emit(BluetoothDisconnected());
      _resetBatteryLevel(emit);
    });

    on<BluetoothBatteryLevelUpdated>((event, emit) {
      if (state is BluetoothConnected) {
        final connectedState = state as BluetoothConnected;
        emit(BluetoothConnected(connectedState.device,
            batteryLevel: event.batteryLevel));
      }
    });
  }

  StreamSubscription<OnConnectionStateChangedEvent>? connectionSubscription;
  StreamSubscription<List<int>>? batteryLevelListener;
  int retryCount = 0;
  final int maxRetries = 3;

  void startListening(String deviceId) {
    connectionSubscription = getConnectionStateListener(
      deviceId: deviceId,
      onStateChanged: (state, device) {
        if (state == BluetoothConnectionState.disconnected) {
          add(BluetoothDeviceDisconnected());
          if (retryCount < maxRetries) {
            retryCount++;
            startListening(deviceId);
          } else {
            add(BluetoothDeviceDisconnected());
          }
        } else if (state == BluetoothConnectionState.connected &&
            device != null) {
          retryCount = 0;
          add(BluetoothDeviceConnected(device));
        }
      },
    );
  }

  Future<void> _initiateBleBatteryListener(
      String deviceId, Emitter<BluetoothState> emit) async {
    batteryLevelListener?.cancel();
    batteryLevelListener = await getBleBatteryLevelListener(
      deviceId,
      onBatteryLevelChange: (int value) {
        add(BluetoothBatteryLevelUpdated(value));
      },
    );
  }

  void _resetBatteryLevel(Emitter<BluetoothState> emit) {
    // Only reset the battery level to -1 without emitting a new state
    if (state is BluetoothConnected) {
      final connectedState = state as BluetoothConnected;
      emit(BluetoothConnected(connectedState.device, batteryLevel: -1));
    }
  }

  @override
  Future<void> close() {
    connectionSubscription?.cancel();
    batteryLevelListener?.cancel();
    return super.close();
  }
}
