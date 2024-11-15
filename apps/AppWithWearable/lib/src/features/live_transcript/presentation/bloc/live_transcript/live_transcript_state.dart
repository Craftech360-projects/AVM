// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_transcript_bloc.dart';

enum BluetoothDeviceStatus {
  initial,
  searching,
  connected,
  disconnected,
  processing,
}

class LiveTranscriptState extends Equatable {
  final BluetoothDeviceStatus bluetoothDeviceStatus;
  final List<BTDeviceStruct> visibleDevices;
  final BTDeviceStruct? connectedDevice;
  final BleAudioCodec? codec;
  final int bleBatteryLevel;
  final String? errorMessage;
  const LiveTranscriptState({
    required this.bluetoothDeviceStatus,
    this.visibleDevices = const [],
    this.bleBatteryLevel = 0,
    this.errorMessage = '',
    this.connectedDevice,
    this.codec = BleAudioCodec.unknown,
  });

  factory LiveTranscriptState.initial() => const LiveTranscriptState(
        bluetoothDeviceStatus: BluetoothDeviceStatus.initial,
      );

  LiveTranscriptState copyWith({
    BluetoothDeviceStatus? bleConnectionStatus,
    List<BTDeviceStruct>? visibleDevices,
    int? bleBatteryLevel,
    BTDeviceStruct? connectedDevice,
    String? errorMessage,
    BleAudioCodec? codec,
  }) {
    return LiveTranscriptState(
      bluetoothDeviceStatus: bleConnectionStatus ?? bluetoothDeviceStatus,
      visibleDevices: visibleDevices ?? this.visibleDevices,
      bleBatteryLevel: bleBatteryLevel ?? this.bleBatteryLevel,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      errorMessage: errorMessage ?? this.errorMessage,
      codec: codec ?? this.codec,
    );
  }

  @override
  List<Object?> get props => [
        bluetoothDeviceStatus,
        visibleDevices,
        bleBatteryLevel,
        connectedDevice,
        errorMessage,
        codec,
      ];

  @override
  bool get stringify => true;
}
