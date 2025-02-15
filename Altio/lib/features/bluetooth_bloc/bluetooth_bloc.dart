import 'dart:async';

import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/utils/ble/connected.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Define events
abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

class BluetoothConnectedEvent extends BluetoothEvent {
  final BTDeviceStruct device;
  final int batteryLevel;
  const BluetoothConnectedEvent(
      {required this.device, required this.batteryLevel});

  @override
  List<Object?> get props => [device, batteryLevel];
}

class BluetoothDisconnectedEvent extends BluetoothEvent {
  const BluetoothDisconnectedEvent();
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
  @override
  List<Object?> get props => [];
}

class BluetoothInitial extends BluetoothState {}

class BluetoothConnected extends BluetoothState {
  final BTDeviceStruct device;
  final int batteryLevel;
  const BluetoothConnected({required this.device, required this.batteryLevel});

  @override
  List<Object?> get props => [device, batteryLevel];
}

class BluetoothDisconnected extends BluetoothState {}

// Define Bloc
class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(BluetoothInitial()) {
    on<BluetoothConnectedEvent>((event, emit) async {
      emit(BluetoothConnected(
          device: event.device, batteryLevel: event.batteryLevel));
      await _initiateBleBatteryListener(event.device.id, emit);
    });

    on<BluetoothDisconnectedEvent>((event, emit) {
      emit(BluetoothDisconnected());
      _resetBatteryLevel(emit);
    });

    on<BluetoothBatteryLevelUpdated>((event, emit) {
      if (state is BluetoothConnected) {
        final connectedState = state as BluetoothConnected;
        emit(BluetoothConnected(
            device: connectedState.device, batteryLevel: event.batteryLevel));
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
          add(const BluetoothDisconnectedEvent());
          if (retryCount < maxRetries) {
            retryCount++;
            startListening(deviceId);
          } else {
            add(const BluetoothDisconnectedEvent());
          }
        } else if (state == BluetoothConnectionState.connected &&
            device != null) {
          retryCount = 0;
          add(BluetoothConnectedEvent(
              device: BTDeviceStruct(id: device.id, name: device.name),
              batteryLevel: -1));
        }
      },
    );
  }

  Future<void> _initiateBleBatteryListener(
      String deviceId, Emitter<BluetoothState> emit) async {
    await batteryLevelListener?.cancel();
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
      emit(BluetoothConnected(device: connectedState.device, batteryLevel: -1));
    }
  }

  @override
  Future<void> close() {
    connectionSubscription?.cancel();
    batteryLevelListener?.cancel();
    return super.close();
  }
}
