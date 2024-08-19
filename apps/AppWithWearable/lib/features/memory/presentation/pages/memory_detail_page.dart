import 'package:flutter/material.dart';
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
    required MemoryBloc memoryBloc,
    required this.memoryAtIndex,
  }) : _memoryBloc = memoryBloc;
  final int memoryAtIndex;
  final MemoryBloc _memoryBloc;

  @override
  State<CustomMemoryDetailPage> createState() => _CustomMemoryDetailPageState();
}

class _CustomMemoryDetailPageState extends State<CustomMemoryDetailPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController overviewController = TextEditingController();

  List<bool> pluginResponseExpanded = [];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                  widget._memoryBloc.state.memories![widget.memoryAtIndex],
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
                  widget._memoryBloc.state.memories![widget.memoryAtIndex],
                  _reProcessMemory,
                );
              },
              icon: const Icon(Icons.more_horiz),
            ),
          ],
          elevation: 0,
          title: Text(
              "${widget._memoryBloc.state.memories![widget.memoryAtIndex].structured.target!.getEmoji()}"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Transcript'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TranscriptTab(
              memoryAtIndex: widget.memoryAtIndex,
              memoryBloc: widget._memoryBloc,
            ),
            SummaryTab(
              memoryBloc: widget._memoryBloc,
              memoryAtIndex: widget.memoryAtIndex,
            ),
          ],
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
