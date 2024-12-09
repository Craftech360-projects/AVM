import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/features/memory/bloc/memory_bloc.dart';
import 'package:friend_private/pages/settings/widgets/calendar.dart';
import 'package:friend_private/utils/features/calendar.dart';
import 'package:friend_private/utils/other/temp.dart';

class EventTab extends StatefulWidget {
  const EventTab(
      {super.key,
      required this.memoryAtIndex,
      required this.memoryBloc,
      required this.pageController});
  final int memoryAtIndex;
  final MemoryBloc memoryBloc;
  final PageController pageController;

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
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
      builder: (context, state) {
        final structured = state.memories[state.memoryIndex].structured.target!;
        // return PageView.builder(
        //   scrollDirection: Axis.vertical,
        //   // controller: _pageController,
        //   itemCount: state.memories.length,
        //   onPageChanged: (index) {
        //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: index));
        //   },
        //   itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                    : const SizedBox(
                        height: 400,
                        child: Center(
                            child: Text("Oops! This Memory Don't have Events")),
                      ),
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
              ],
            ),
          ),
        );
      },
    );
    // },
    // );
  }
}
