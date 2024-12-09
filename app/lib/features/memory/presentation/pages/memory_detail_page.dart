import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/features/memory/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/action_tab.dart';
import 'package:friend_private/features/memory/presentation/widgets/custom_tag.dart';
import 'package:friend_private/features/memory/presentation/widgets/event_tab.dart';
import 'package:friend_private/features/memory/presentation/widgets/summary_tab.dart';
import 'package:friend_private/features/memory/presentation/widgets/transcript_tab.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/memory_detail/enable_title.dart';
import 'package:friend_private/pages/memory_detail/share.dart';
import 'package:friend_private/pages/memory_detail/widgets.dart';
import 'package:friend_private/utils/memories/reprocess.dart';
import 'package:friend_private/utils/other/temp.dart';

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
        length: 4,
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
          ),
          body: BlocBuilder<MemoryBloc, MemoryState>(
            bloc: widget.memoryBloc,
            builder: (context, state) {
              final selectedMemory = state.memories[state.memoryIndex];

              final structured = selectedMemory.structured.target!;
              final time = selectedMemory.startedAt == null
                  ? dateTimeFormat('h:mm a', selectedMemory.createdAt)
                  : '${dateTimeFormat('h:mm a', selectedMemory.startedAt)} to ${dateTimeFormat('h:mm a', selectedMemory.finishedAt)}';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${dateTimeFormat('MMM d,  yyyy', selectedMemory.createdAt)} '
                      '${selectedMemory.startedAt == null ? 'at' : 'from'} $time',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  selectedMemory.discarded
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Discarded Memory',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: EditableTitle(
                            initialText: structured.title,
                            onTextChanged: (String newTitle) {
                              structured.title = newTitle;
                              widget.memoryBloc
                                  .add(UpdatedMemory(structured: structured));
                            },
                            discarded: selectedMemory.discarded,
                            style: Theme.of(context).textTheme.titleLarge!,
                          ),
                        ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children:
                          List.generate(structured.category.length, (index) {
                        return CustomTag(
                          tagName: structured.category[index],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color.fromARGB(255, 29, 29, 29),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    // color: const Color.fromARGB(75, 242, 242, 242),

                    child: SizedBox(
                      height: 40,
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            6,
                          ),
                          color: const Color.fromARGB(125, 158, 158, 158),
                        ),
                        indicatorWeight: 0,
                        labelPadding: EdgeInsets.zero,
                        tabs: const [
                          Tab(text: 'Action'),
                          Tab(text: 'Summary'),
                          Tab(text: 'Events'),
                          Tab(text: 'Transcript'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ActionTab(
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
                        EventTab(
                          pageController: pageController,
                          memoryAtIndex: state.memoryIndex,
                          memoryBloc: widget.memoryBloc,
                        ),
                        TranscriptTab(
                          pageController: pageController,
                          memoryAtIndex: state.memoryIndex,
                          memoryBloc: widget.memoryBloc,
                        ),
                      ],
                    ),
                  )
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
