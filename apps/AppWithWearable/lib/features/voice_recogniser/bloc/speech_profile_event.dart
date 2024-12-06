
part of 'speech_profile_bloc.dart';

@immutable
sealed class SpeechProfileEvent extends Equatable {}

class SampleAudioRecorded extends SpeechProfileEvent {
final List<TranscriptSegment> segments;
  SampleAudioRecorded({
    required this.segments,
  });

  @override

  List<Object?> get props => [segments];


}
