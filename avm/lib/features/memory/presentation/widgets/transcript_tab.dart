import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/features/memory/presentation/widgets/chat_box.dart';

class TranscriptTab extends StatefulWidget {
  const TranscriptTab({
    super.key,
    required this.memoryAtIndex,
    required this.memoryBloc,
    required this.pageController,
  });

  final MemoryBloc memoryBloc;
  final int memoryAtIndex;
  final PageController pageController;

  @override
  State<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends State<TranscriptTab> {
  // late PageController _pageController;
  @override
  void initState() {
    super.initState();

    // _pageController = PageController(initialPage: widget.memoryAtIndex);
    // widget.pageController.addListener(_onPageChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: widget.memoryBloc,
      builder: (context, state) {
        // log('memory at transcript tab- ${state.memories[widget.memoryAtIndex].transcriptSegments}');

        final transcriptSegments =
            state.memories[widget.memoryAtIndex].transcriptSegments;

        return ListView.builder(
          itemCount: transcriptSegments.length,
          itemBuilder: (context, index) {
            final segment = transcriptSegments[index];
            return ChatBoxWidget(segment: segment);
          },
        );
      },
    );
  }
}
