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
 final List<int> rawAudio;
  final int bleBatteryLevel;
  final String? errorMessage;
  const LiveTranscriptState({
    required this.bluetoothDeviceStatus,
    this.visibleDevices = const [],
    this.bleBatteryLevel = 0,
    this.errorMessage = '',
    this.connectedDevice,
    this.rawAudio=const [],
    this.codec=BleAudioCodec.unknown,
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
    List<int>? rawAudio,
  }) {
    return LiveTranscriptState(
      bluetoothDeviceStatus: bleConnectionStatus ?? bluetoothDeviceStatus,
      visibleDevices: visibleDevices ?? this.visibleDevices,
      bleBatteryLevel: bleBatteryLevel ?? this.bleBatteryLevel,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      errorMessage: errorMessage ?? this.errorMessage,
      codec:codec??this.codec,
      rawAudio:rawAudio??this.rawAudio,
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
        rawAudio,
      ];

  @override
  bool get stringify => true;
}
