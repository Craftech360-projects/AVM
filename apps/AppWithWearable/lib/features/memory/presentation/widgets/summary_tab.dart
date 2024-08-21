import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/pages/memory_detail/enable_title.dart';
import 'package:friend_private/pages/settings/calendar.dart';
import 'package:friend_private/utils/features/calendar.dart';
import 'package:friend_private/utils/other/temp.dart';

class SummaryTab extends StatefulWidget {
  const SummaryTab({
    super.key,
    required MemoryBloc memoryBloc,
    required this.memoryAtIndex,
  }) : _memoryBloc = memoryBloc;

  final MemoryBloc _memoryBloc;
  final int memoryAtIndex;

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  late MemoryBloc memoryBloc;
  List<Memory>? memories;
  late Memory selectedMemory;
  late Structured structured;
  late String time;
  late PageController _pageController;
  late ScrollController _scrollController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.memoryAtIndex);
    _scrollController = ScrollController();
    memoryBloc = widget._memoryBloc;
    _currentPage = widget.memoryAtIndex;
    memories = widget._memoryBloc.state.memories;
    selectedMemory = memories![widget.memoryAtIndex];
    structured = selectedMemory.structured.target!;
    time = selectedMemory.startedAt == null
        ? dateTimeFormat('h:mm a', selectedMemory.createdAt)
        : '${dateTimeFormat('h:mm a', selectedMemory.startedAt)} to ${dateTimeFormat('h:mm a', selectedMemory.finishedAt)}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom
      if (_currentPage < memories!.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent) {
      // Reached the top
      if (_currentPage > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(_onScroll);
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: memories!.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
          selectedMemory = memories![index];
          structured = selectedMemory.structured.target!;
          time = selectedMemory.startedAt == null
              ? dateTimeFormat('h:mm a', selectedMemory.createdAt)
              : '${dateTimeFormat('h:mm a', selectedMemory.startedAt)} to ${dateTimeFormat('h:mm a', selectedMemory.finishedAt)}';
        });
      },
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //*--- TITLE ---*//
                const SizedBox(height: 12),
                selectedMemory.discarded
                    ? Text(
                        'Discarded Memory',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 32),
                      )
                    : EditableTitle(
                        initialText: structured.title,
                        onTextChanged: (String newTitle) {
                          structured.title = newTitle;
                          memoryBloc.add(UpdatedMemory(structured: structured));
                        },
                        discarded: selectedMemory.discarded,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 32),
                      ),
                // Text(
                //     structured.title,
                //     style: Theme.of(context)
                //         .textTheme
                //         .titleLarge!
                //         .copyWith(fontSize: 32),
                //   ),
                const SizedBox(height: 16),
                //*--- TIME ---*//
                Text(
                  '${dateTimeFormat('MMM d,  yyyy', selectedMemory.createdAt)} '
                  '${selectedMemory.startedAt == null ? 'at' : 'from'} $time',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),
                //*--- IMAGE ---*//
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                      child: Image.memory(selectedMemory.memoryImg!),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Text(
                          '${structured.category[0].toUpperCase()}'
                          '${structured.category.substring(1).toLowerCase()}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
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
                          memoryBloc.add(UpdatedMemory(structured: structured));
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
                structured.actionItems.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Action Items',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: 26),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      '- ${structured.actionItems.map((e) => e.description).join('\n- ')}'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Action items copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ));
                              MixpanelManager().copiedMemoryDetails(
                                  selectedMemory,
                                  source: 'Action Items');
                            },
                            icon: const Icon(Icons.copy_rounded,
                                color: Colors.white, size: 20),
                          )
                        ],
                      )
                    : const SizedBox.shrink(),
                ...structured.actionItems.map<Widget>(
                  (item) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            item.completed = !item.completed;
                            MemoryProvider().updateActionItem(item);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          color: item.completed ? Colors.green : Colors.grey,
                          item.completed
                              ? Icons.task_alt
                              : Icons.circle_outlined,
                          size: 20,
                        ),
                        title: Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                //*--- EVENTS ---*//
                structured.events.isNotEmpty
                    ? Row(
                        children: [
                          Icon(Icons.event, color: Colors.grey.shade300),
                          const SizedBox(width: 8),
                          Text(
                            'Events',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: 26),
                          )
                        ],
                      )
                    : const SizedBox.shrink(),
                ...structured.events.map<Widget>(
                  (event) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        event.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          ''
                          '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: event.created
                            ? null
                            : () {
                                var calEnabled =
                                    SharedPreferencesUtil().calendarEnabled;
                                var calSelected = SharedPreferencesUtil()
                                    .calendarId
                                    .isNotEmpty;
                                if (!calEnabled || !calSelected) {
                                  routeToPage(context, const CalendarPage());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(!calEnabled
                                          ? 'Enable calendar integration to add events'
                                          : 'Select a calendar to add events to'),
                                    ),
                                  );
                                  return;
                                }
                                MemoryProvider().setEventCreated(event);
                                setState(() => event.created = true);
                                CalendarUtil().createEvent(
                                  event.title,
                                  event.startsAt,
                                  event.duration,
                                  description: event.description,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Event added to calendar'),
                                  ),
                                );
                              },
                        icon: Icon(event.created ? Icons.check : Icons.add,
                            color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 250,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
