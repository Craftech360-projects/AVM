// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_transcript_bloc.dart';

enum BleConnectionStatus {
  initial,
  scanning,
  loading,
  connected,
  failure,
}

class LiveTranscriptState extends Equatable {
  final BleConnectionStatus bleConnectionStatus;
  final List<BTDeviceStruct> visibleDevices;
  final BTDeviceStruct? connectedDevice;
  final int bleBatteryLevel;
  final String? errorMessage;
  const LiveTranscriptState({
    required this.bleConnectionStatus,
    this.visibleDevices = const [],
    this.bleBatteryLevel = 0,
    this.errorMessage = '',
    this.connectedDevice,
  });

  factory LiveTranscriptState.initial() => const LiveTranscriptState(
        bleConnectionStatus: BleConnectionStatus.initial,
      );

  LiveTranscriptState copyWith({
    BleConnectionStatus? bleConnectionStatus,
    List<BTDeviceStruct>? visibleDevices,
    int? bleBatteryLevel,
    BTDeviceStruct? connectedDevice,
    String? errorMessage,
  }) {
    return LiveTranscriptState(
      bleConnectionStatus: bleConnectionStatus ?? this.bleConnectionStatus,
      visibleDevices: visibleDevices ?? this.visibleDevices,
      bleBatteryLevel: bleBatteryLevel ?? this.bleBatteryLevel,
      connectedDevice: connectedDevice?? this.connectedDevice,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        bleConnectionStatus,
        visibleDevices,
        bleBatteryLevel,
        connectedDevice,
        errorMessage,
      ];

  @override
  bool get stringify => true;
}
