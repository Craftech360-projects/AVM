import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/plugin.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/pages/memory_detail/enable_title.dart';
import 'package:avm/utils/other/temp.dart';

class SummaryTab extends StatefulWidget {
  const SummaryTab({
    super.key,
    required this.memoryAtIndex,
    required this.memoryBloc,
    required this.pageController,
  });

  final int memoryAtIndex;
  final MemoryBloc memoryBloc;
  final PageController pageController;

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  // late PageController _pageController;
  // final ScrollController _scrollController = ScrollController();
  List<Plugin> pluginsList = SharedPreferencesUtil().pluginsList;
  List<bool> pluginResponseExpanded = [];

  @override
  void initState() {
    super.initState();
    // _pageController = PageController(initialPage: widget.memoryAtIndex);

    // widget.pageController.addListener(_onPageChanged);
    // _scrollController.addListener(() {
    //   _onScroll();
    // });
    // pluginResponseExpanded = List.filled(
    //     widget.memoryBloc.state.memories[widget.memoryAtIndex].pluginsResponse
    //         .length,
    //     false);
  }

  // void _onPageChanged() {
  //   final currentPage = widget.pageController.page?.round();
  //   if (currentPage != null) {
  //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: currentPage));
  //     setState(() {
  //       pluginResponseExpanded = List.filled(
  //         widget.memoryBloc.state.memories[currentPage].pluginsResponse.length,
  //         false,
  //       );
  //     });
  //   }
  // }

  // void _onScroll() {
  //   if (_scrollController.position.pixels >
  //       (_scrollController.position.maxScrollExtent + 50)) {
  //     _pageController.nextPage(
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //     );
  //   }

  //   if (_scrollController.position.pixels <
  //       (_scrollController.position.minScrollExtent - 50)) {
  //     _pageController.previousPage(
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  // @override
  // void dispose() {
  //   widget.pageController.removeListener(_onPageChanged);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: widget.memoryBloc,
      builder: (context, state) {
        final selectedMemory = state.memories[state.memoryIndex];

        final structured = selectedMemory.structured.target!;
        // ignore: unused_local_variable
        final time = selectedMemory.startedAt == null
            ? dateTimeFormat('h:mm a', selectedMemory.createdAt)
            : '${dateTimeFormat('h:mm a', selectedMemory.startedAt)} to ${dateTimeFormat('h:mm a', selectedMemory.finishedAt)}';

        // return PageView.builder(
        //   scrollDirection: Axis.vertical,
        //   // controller: _pageController,
        //   itemCount: state.memories.length,
        //   onPageChanged: (index) {
        //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: index));
        //   },
        // itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            // controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //*--- TITLE ---*//
                // const SizedBox(height: 12),
                // selectedMemory.discarded
                //     ? Text(
                //         'Discarded Memory',
                //         style: Theme.of(context)
                //             .textTheme
                //             .titleLarge!
                //             .copyWith(fontSize: 32),
                //       )
                //     : EditableTitle(
                //         initialText: structured.title,
                //         onTextChanged: (String newTitle) {
                //           structured.title = newTitle;
                //           widget.memoryBloc
                //               .add(UpdatedMemory(structured: structured));
                //         },
                //         discarded: selectedMemory.discarded,
                //         style: Theme.of(context)
                //             .textTheme
                //             .titleLarge!
                //             .copyWith(fontSize: 32),
                //       ),
                // Text(
                //     structured.title,
                //     style: Theme.of(context)
                //         .textTheme
                //         .titleLarge!
                //         .copyWith(fontSize: 32),
                //   ),
                const SizedBox(height: 16),
                //*--- TIME ---*//
                // Text(
                //   '${dateTimeFormat('MMM d,  yyyy', selectedMemory.createdAt)} '
                //   '${selectedMemory.startedAt == null ? 'at' : 'from'} $time',
                //   style: const TextStyle(color: Colors.grey, fontSize: 16),
                // ),
                // const SizedBox(height: 16),
                //*--- IMAGE ---*//
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                  child: Image.memory(selectedMemory.memoryImg!),
                ),
                const SizedBox(height: 20),
                //*--- OVERVIEW ---*//
                selectedMemory.discarded
                    ? const SizedBox.shrink()
                    : Text(
                        'Overview',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 26),
                      ),
                selectedMemory.discarded
                    ? const SizedBox.shrink()
                    : ((selectedMemory.geolocation.target != null)
                        ? const SizedBox(height: 8)
                        : const SizedBox.shrink()),

                selectedMemory.discarded
                    ? const SizedBox.shrink()
                    : EditableTitle(
                        initialText: structured.overview,
                        onTextChanged: (String newOverview) {
                          structured.overview = newOverview;
                          widget.memoryBloc
                              .add(UpdatedMemory(structured: structured));
                        },
                        discarded: selectedMemory.discarded,
                        style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 15,
                            height: 1.3),
                      ),
                // Text(structured.overview),
                selectedMemory.discarded
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 40),
                //*--- ACTION ITEMS ---*//
                // structured.actionItems.isNotEmpty
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             'Action Items',
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .titleLarge!
                //                 .copyWith(fontSize: 26),
                //           ),
                //           IconButton(
                //             onPressed: () {
                //               Clipboard.setData(ClipboardData(
                //                   text:
                //                       '- ${structured.actionItems.map((e) => e.description).join('\n- ')}'));
                //               ScaffoldMessenger.of(context)
                //                   .showSnackBar(const SnackBar(
                //                 content: Text(
                //                     'Action items copied to clipboard'),
                //                 duration: Duration(seconds: 2),
                //               ));
                //               MixpanelManager().copiedMemoryDetails(
                //                   selectedMemory,
                //                   source: 'Action Items');
                //             },
                //             icon: const Icon(Icons.copy_rounded,
                //                 color: Colors.white, size: 20),
                //           )
                //         ],
                //       )
                //     : const SizedBox.shrink(),
                // ...structured.actionItems.map<Widget>(
                //   (item) {
                //     return Padding(
                //       padding: const EdgeInsets.only(top: 10),
                //       child: ListTile(
                //         onTap: () {
                //           setState(() {
                //             item.completed = !item.completed;
                //             MemoryProvider().updateActionItem(item);
                //           });
                //         },
                //         contentPadding: EdgeInsets.zero,
                //         leading: Icon(
                //           color:
                //               item.completed ? Colors.green : Colors.grey,
                //           item.completed
                //               ? Icons.task_alt
                //               : Icons.circle_outlined,
                //           size: 20,
                //         ),
                //         title: Text(
                //           item.description,
                //           style: TextStyle(
                //             color: Colors.grey.shade300,
                //             fontSize: 16,
                //             height: 1.3,
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                //*--- EVENTS ---*//
                // structured.events.isNotEmpty
                //     ? Row(
                //         children: [
                //           Icon(Icons.event, color: Colors.grey.shade300),
                //           const SizedBox(width: 8),
                //           Text(
                //             'Events',
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .titleLarge!
                //                 .copyWith(fontSize: 26),
                //           )
                //         ],
                //       )
                //     : const SizedBox.shrink(),
                // ...structured.events.map<Widget>(
                //   (event) {
                //     return ListTile(
                //       contentPadding: EdgeInsets.zero,
                //       title: Text(
                //         event.title,
                //         style: const TextStyle(
                //             color: Colors.white,
                //             fontSize: 16,
                //             fontWeight: FontWeight.w600),
                //       ),
                //       subtitle: Padding(
                //         padding: const EdgeInsets.only(top: 4.0),
                //         child: Text(
                //           ''
                //           '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
                //           style: const TextStyle(
                //               color: Colors.grey, fontSize: 15),
                //         ),
                //       ),
                //       trailing: IconButton(
                //         onPressed: event.created
                //             ? null
                //             : () {
                //                 var calEnabled =
                //                     SharedPreferencesUtil().calendarEnabled;
                //                 var calSelected = SharedPreferencesUtil()
                //                     .calendarId
                //                     .isNotEmpty;
                //                 if (!calEnabled || !calSelected) {
                //                   routeToPage(
                //                       context, const CalendarPage());
                //                   ScaffoldMessenger.of(context)
                //                       .showSnackBar(
                //                     SnackBar(
                //                       content: Text(!calEnabled
                //                           ? 'Enable calendar integration to add events'
                //                           : 'Select a calendar to add events to'),
                //                     ),
                //                   );
                //                   return;
                //                 }
                //                 MemoryProvider().setEventCreated(event);
                //                 setState(() => event.created = true);
                //                 CalendarUtil().createEvent(
                //                   event.title,
                //                   event.startsAt,
                //                   event.duration,
                //                   description: event.description,
                //                 );
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   const SnackBar(
                //                     content:
                //                         Text('Event added to calendar'),
                //                   ),
                //                 );
                //               },
                //         icon: Icon(event.created ? Icons.check : Icons.add,
                //             color: Colors.white),
                //       ),
                //     );
                //   },
                // ),
                // const SizedBox(
                //   height: 25,
                // ),
                // ...getPluginsWidgets(
                //   context,
                //   state.memories[index],
                //   pluginsList,
                //   pluginResponseExpanded,
                //   (i) => setState(() => pluginResponseExpanded[i] =
                //       !pluginResponseExpanded[i]),
                // )
              ],
            ),
          ),
        );
        // Card(
        //   child: Text(
        //     state.memories[index].structured.target?.title ?? '',
        //   ),
        // );
      },
    );
    // },
    // );
  }
}
