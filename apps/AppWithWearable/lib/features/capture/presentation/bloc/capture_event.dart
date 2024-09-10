// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'capture_bloc.dart';

abstract class CaptureEvent extends Equatable {
  const CaptureEvent();

  @override
  List<Object?> get props => [];
}

class InitiateWebSocket extends CaptureEvent {
  final BleAudioCodec? audioCodec;
  final int? sampleRate;
  final BTDeviceStruct? btDevice;
  const InitiateWebSocket({
    this.audioCodec,
    this.sampleRate,
    this.btDevice,
  });

  @override
  List<Object?> get props => [audioCodec, sampleRate, btDevice];
}
