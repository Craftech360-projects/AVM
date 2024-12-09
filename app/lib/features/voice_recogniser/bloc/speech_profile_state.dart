part of 'speech_profile_bloc.dart';

enum SpeechProfileStatus {
  initial,
  startedRecording,
  uploadingProfile,
  profileCompleted,
  failed
}

class SpeechProfileState extends Equatable {
  final SpeechProfileStatus status;
  final bool? permissionEnabled;
  // bool loading = false;
  final BTDeviceStruct? device;

  final targetWordsCount = 70;
  final maxDuration = 90;
  final StreamSubscription<OnConnectionStateChangedEvent>?
      connectionStateListener;
  final List<TranscriptSegment>? segments;
  final double? streamStartedAtSecond;
  WavBytesUtil? audioStorage = WavBytesUtil(codec: BleAudioCodec.opus);
  final StreamSubscription? bleBytesStream;

  // bool startedRecording = false;
  final int? percentageCompleted;
  // bool uploadingProfile = false;
  // bool profileCompleted = false;
  final Timer? forceCompletionTimer;

  // bool isInitialising = false;
  // bool isInitialised = false;

  final String? text;
  final String? message;

  /// only used during onboarding /////
  // String loadingText = 'Uploading your voice profile....';
  final Memory? memory;
  SpeechProfileState({
    required this.status,
    this.permissionEnabled,
    // required this.loading,
    this.device,
    this.connectionStateListener,
    this.segments = const [],
    this.streamStartedAtSecond,
    this.bleBytesStream,
    this.percentageCompleted = 0,
    this.forceCompletionTimer,
    this.text = '',
    this.audioStorage,
    this.message = '',
    //  this.loadingText,
    this.memory,
  });

  @override
  List<Object?> get props {
    return [
      permissionEnabled,
      // loading,
      device,
      connectionStateListener,
      segments,
      streamStartedAtSecond,
      bleBytesStream,
      percentageCompleted,
      forceCompletionTimer,
      text,
      audioStorage,
      message,
      // loadingText,
      memory,
    ];
  }

  factory SpeechProfileState.initial() =>
      SpeechProfileState(status: SpeechProfileStatus.initial);

  SpeechProfileState copyWith({
    SpeechProfileStatus? status,
    bool? permissionEnabled,
    BTDeviceStruct? device,
    StreamSubscription<OnConnectionStateChangedEvent>? connectionStateListener,
    List<TranscriptSegment>? segments,
    double? streamStartedAtSecond,
    StreamSubscription? bleBytesStream,
    int? percentageCompleted,
    Timer? forceCompletionTimer,
    String? text,
    String? message,
    Memory? memory,
  }) {
    return SpeechProfileState(
      status: status ?? this.status,
      permissionEnabled: permissionEnabled ?? this.permissionEnabled,
      device: device ?? this.device,
      connectionStateListener:
          connectionStateListener ?? this.connectionStateListener,
      segments: segments ?? this.segments,
      streamStartedAtSecond:
          streamStartedAtSecond ?? this.streamStartedAtSecond,
      bleBytesStream: bleBytesStream ?? this.bleBytesStream,
      percentageCompleted: percentageCompleted ?? this.percentageCompleted,
      forceCompletionTimer: forceCompletionTimer ?? this.forceCompletionTimer,
      text: text ?? this.text,
      message: message ?? this.message,
      memory: memory ?? this.memory,
    );
  }
}
