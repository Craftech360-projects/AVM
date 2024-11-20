// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_transcript_bloc.dart';

abstract class LiveTranscriptEvent extends Equatable {
  const LiveTranscriptEvent();

  @override
  List<Object> get props => [];
}

class ScannedDevices extends LiveTranscriptEvent {}

class SelectedDevice extends LiveTranscriptEvent {
  final bool autoConnect;
  final BTDeviceStruct connectedDevice;
  const SelectedDevice({
    required this.connectedDevice,
    this.autoConnect = true,
  });
  @override
  List<Object> get props => [
        connectedDevice,
        autoConnect,
      ];
}

class DisconnectDevice extends LiveTranscriptEvent {
  final BTDeviceStruct btDeviceStruct;
  const DisconnectDevice({
    required this.btDeviceStruct,
  });
  @override
  List<Object> get props => [btDeviceStruct];
}

class _AudioListener extends LiveTranscriptEvent {
  final List<int> rawAudio;
  const _AudioListener({
    required this.rawAudio,
  });
  @override
  List<Object> get props => [rawAudio];
}

class _AdapterListener extends LiveTranscriptEvent {
  final BluetoothAdapterState bleAdapterState;
  const _AdapterListener({
    required this.bleAdapterState,
  });
  @override
  List<Object> get props => [bleAdapterState];
}

class _ScanListener extends LiveTranscriptEvent {
  final List<ScanResult> devices;
  const _ScanListener({
    required this.devices,
  });
  @override
  List<Object> get props => [devices];
}

class _BleConnectionListener extends LiveTranscriptEvent {
  final BluetoothConnectionState bleListener;
  const _BleConnectionListener({
    required this.bleListener,
  });
  @override
  List<Object> get props => [bleListener];
}

class _BatteryListener extends LiveTranscriptEvent {
  final List<int> value;
  const _BatteryListener({
    required this.value,
  });
  @override
  List<Object> get props => [value];
}
