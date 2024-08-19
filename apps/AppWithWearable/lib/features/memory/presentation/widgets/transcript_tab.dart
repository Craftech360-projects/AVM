import 'package:flutter/material.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/widgets/transcript.dart';

class TranscriptTab extends StatelessWidget {
  const TranscriptTab({
    super.key,
    required this.memoryAtIndex,
    required MemoryBloc memoryBloc,
  }) : _memoryBloc = memoryBloc;
  final MemoryBloc _memoryBloc;
  final int memoryAtIndex;
  @override
  Widget build(BuildContext context) {
    return TranscriptWidget(
      segments:
          _memoryBloc.state.memories?[memoryAtIndex].transcriptSegments ?? [],
    );
  }
}
