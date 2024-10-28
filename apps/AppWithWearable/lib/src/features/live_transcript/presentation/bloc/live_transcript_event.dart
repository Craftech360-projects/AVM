// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_transcript_bloc.dart';

abstract class LiveTranscriptEvent extends Equatable {
  const LiveTranscriptEvent();

  @override
  List<Object> get props => [];
}

class ScannedDevices extends LiveTranscriptEvent {}

class SelectedDevice extends LiveTranscriptEvent {
  final String deviceId;
  final bool autoConnect;
  const SelectedDevice({
    required this.deviceId,
    this.autoConnect = true,
  });
  @override
  List<Object> get props => [
        deviceId,
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
