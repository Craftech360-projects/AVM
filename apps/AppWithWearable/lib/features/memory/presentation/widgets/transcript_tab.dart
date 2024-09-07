import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/widgets/transcript.dart';

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

  // void _onPageChanged() {
  //   final currentPage = widget.pageController.page?.round();
  //   if (currentPage != null) {
  //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: currentPage));
  //   }
  // }

  // @override
  // void dispose() {
  //   widget.pageController.removeListener(_onPageChanged);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: widget.memoryBloc,
      builder: (context, state) {
        // return PageView.builder(
        //   scrollDirection: Axis.vertical,
        //   controller: _pageController,
        //   itemCount: state.memories.length,
        //   onPageChanged: (index) {
        //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: index));
        //   },
        //   itemBuilder: (BuildContext context, int index) {
            return SingleChildScrollView(
              child: TranscriptWidget(
                segments: state.memories[widget.memoryAtIndex].transcriptSegments,
                // segments: state.memories[index].transcriptSegments,
              ),
            );
          },
        );
      // },
    // );
  }
}
