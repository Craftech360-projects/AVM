import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/features/memory/presentation/widgets/action_tab.dart';
import 'package:avm/features/memory/presentation/widgets/custom_tag.dart';
import 'package:avm/features/memory/presentation/widgets/event_tab.dart';
import 'package:avm/features/memory/presentation/widgets/summary_tab.dart';
import 'package:avm/features/memory/presentation/widgets/transcript_tab.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/memory_detail/enable_title.dart';
import 'package:avm/pages/memory_detail/share.dart';
import 'package:avm/pages/memory_detail/widgets.dart';
import 'package:avm/utils/memories/reprocess.dart';
import 'package:avm/utils/other/temp.dart';

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
    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: CustomScaffold(
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
                h15,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${dateTimeFormat('MMM d,  yyyy', selectedMemory.createdAt)} '
                    '${selectedMemory.startedAt == null ? 'at' : 'from'} $time',
                    style: const TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                ),
               h15,
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
                h10,
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
                h5,
                Container(
                  decoration: BoxDecoration(
                    borderRadius: br5,
                    color: AppColors.black
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
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.grey,
                      indicator: BoxDecoration(
                        borderRadius: br5,
                        color: AppColors.greyLight,
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
    );
  }

  _reProcessMemory(BuildContext context, StateSetter setModalState,
      Memory memory, Function changeLoadingState) async {
    Memory? newMemory = await reProcessMemory(
      context,
      memory,
      () => avmSnackBar(context, 'Memory processing failed! Please try again.'),
      changeLoadingState,
    );

    pluginResponseExpanded = List.filled(memory.pluginsResponse.length, false);
    overviewController.text = newMemory!.structured.target!.overview;
    titleController.text = newMemory.structured.target!.title;

    avmSnackBar(context, "Memory reprocessed successfully!");
    Navigator.pop(context, true);
  }
}
