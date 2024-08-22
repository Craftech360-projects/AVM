import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/summary_tab.dart';
import 'package:friend_private/features/memory/presentation/widgets/transcript_tab.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/memory_detail/share.dart';
import 'package:friend_private/pages/memory_detail/widgets.dart';
import 'package:friend_private/utils/memories/reprocess.dart';

class CustomMemoryDetailPage extends StatefulWidget {
  const CustomMemoryDetailPage({
    super.key,
    required this.memoryBloc,
    required this.memoryAtIndex,
  });
  final int memoryAtIndex;
  final MemoryBloc memoryBloc;

  @override
  State<CustomMemoryDetailPage> createState() => _CustomMemoryDetailPageState();
}

class _CustomMemoryDetailPageState extends State<CustomMemoryDetailPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController overviewController = TextEditingController();
  PageController pageController = PageController();

  List<bool> pluginResponseExpanded = [];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        widget.memoryBloc.add(
          const DisplayedMemory(isNonDiscarded: true),
        );
      },
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: CustomScaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  showShareBottomSheet(
                    context,
                    widget.memoryBloc.state.memories[widget.memoryAtIndex],
                    setState,
                  );
                },
                icon: const Icon(Icons.ios_share, size: 20),
              ),
              IconButton(
                onPressed: () {
                  showOptionsBottomSheet(
                    context,
                    setState,
                    widget.memoryBloc.state.memories[widget.memoryAtIndex],
                    _reProcessMemory,
                  );
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
            elevation: 0,
            title: Text(
                "${widget.memoryBloc.state.memories[widget.memoryAtIndex].structured.target!.getEmoji()}"),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Transcript'),
                Tab(text: 'Summary'),
              ],
            ),
          ),
          body: BlocBuilder<MemoryBloc, MemoryState>(
            bloc: widget.memoryBloc,
            builder: (context, state) {
              return TabBarView(
                children: [
                  TranscriptTab(
                    pageController: pageController,
                    memoryAtIndex: state.memoryIndex,
                    memoryBloc: widget.memoryBloc,
                  ),
                  // SummaryTab(
                  //   memoryBloc: widget.memoryBloc,
                  //   memoryAtIndex: state.memoryIndex,
                  // ),
                  SummaryTab(
                    pageController: pageController,
                    memoryAtIndex: state.memoryIndex,
                    memoryBloc: widget.memoryBloc,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _reProcessMemory(BuildContext context, StateSetter setModalState,
      Memory memory, Function changeLoadingState) async {
    Memory? newMemory = await reProcessMemory(
      context,
      memory,
      () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error while processing memory. Please try again later.'))),
      changeLoadingState,
    );

    pluginResponseExpanded = List.filled(memory.pluginsResponse.length, false);
    overviewController.text = newMemory!.structured.target!.overview;
    titleController.text = newMemory.structured.target!.title;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Memory processed! 🚀',
              style: TextStyle(color: Colors.white))),
    );
    Navigator.pop(context, true);
  }
}
