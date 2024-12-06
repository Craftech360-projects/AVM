// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'capture_bloc.dart';

class CaptureState extends Equatable {
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final bool? memoryCreating;
  final List<TranscriptSegment> segments;
  final RecordingState recordingState;
  const CaptureState({
    this.hasTranscripts = false,
    this.device,
    this.wsConnectionState = WebsocketConnectionStatus.notConnected,
    this.internetStatus,
    this.memoryCreating = false,
    this.segments = const [],
    this.recordingState = RecordingState.stop,
  });
  @override
  List<Object?> get props {
    return [
      hasTranscripts,
      device,
      wsConnectionState,
      internetStatus,
      memoryCreating,
      segments,
      recordingState,
    ];
  }

  CaptureState copyWith({
    bool? hasTranscripts,
    BTDeviceStruct? device,
    WebsocketConnectionStatus? wsConnectionState,
    InternetStatus? internetStatus,
    bool? memoryCreating,
    List<TranscriptSegment>? segments,
    RecordingState? recordingState,
  }) {
    return CaptureState(
      hasTranscripts: hasTranscripts ?? this.hasTranscripts,
      device: device ?? this.device,
      wsConnectionState: wsConnectionState ?? this.wsConnectionState,
      internetStatus: internetStatus ?? this.internetStatus,
      memoryCreating: memoryCreating ?? this.memoryCreating,
      segments: segments ?? this.segments,
      recordingState: recordingState ?? this.recordingState,
    );
  }
}
