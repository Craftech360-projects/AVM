import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/capture/presentation/capture_page.dart';
import 'package:friend_private/features/capture/widgets/greeting_card.dart';
import 'package:friend_private/features/memory/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_card.dart';
import 'package:friend_private/utils/other/notifications.dart'; // Import the notification utility file
import 'package:friend_private/utils/websockets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';

class CaptureMemoryPage extends StatefulWidget {
  const CaptureMemoryPage({
    super.key,
    required this.context,
    required this.hasTranscripts,
    this.device,
    required this.wsConnectionState,
    this.internetStatus,
    this.segments,
    required this.memoryCreating,
    required this.photos,
    this.scrollController,
    required this.onDismissmissedCaptureMemory,
  });
  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final List<Tuple2<String, String>> photos;
  final ScrollController? scrollController;
  final Function(DismissDirection) onDismissmissedCaptureMemory;

  @override
  State<CaptureMemoryPage> createState() => _CaptureMemoryPageState();
}

class _CaptureMemoryPageState extends State<CaptureMemoryPage> {
  late MemoryBloc _memoryBloc;
  bool _isNonDiscarded = true;
  final GlobalKey<CapturePageState> capturePageKey =
      GlobalKey<CapturePageState>();
  // final List<FilterItem> _filters = [
  //   FilterItem(filterType: 'Show All', filterStatus: false),
  //   FilterItem(filterType: 'Technology', filterStatus: false),
  // ];
  final TextEditingController _searchController = TextEditingController();
  bool notificationPlugin = false;

  @override
  void initState() {
    super.initState();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));

    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });

    initializeNotifications(); // Initialize notifications
  }

  void _activateNotification() async {
    bool isNotificationEnabled = SharedPreferencesUtil().notificationPlugin;
    print('Notification status: $isNotificationEnabled');

    SharedPreferencesUtil().notificationPlugin = !isNotificationEnabled;
  }

  // void _PluginNotification() async {

  //     String transcript = '''
  //   Speaker 1: Hey, how have you been?
  //   Speaker 2: I've been good, just busy with work. How about you?
  //   Speaker 1: Same here. I wanted to catch up and see if you're free this weekend for a hike.
  //   ''';
  //     // Replace with actual transcript
  //     String friendlyReplyJson = await generateFriendlyReply(transcript);
  //     var friendlyReplyMap = jsonDecode(friendlyReplyJson);
  //     debugPrint(friendlyReplyMap.toString());
  //     String friendlyReply =
  //         friendlyReplyMap['reply'] ?? 'Default friendly reply';
  //     print(friendlyReply);
  //     // createNotification(
  //     //   title: 'Notification Title',
  //     //   body: friendlyReply,
  //     //   notificationId: 10,
  //     // );
  //     createMessagingNotification('AVM', friendlyReply);

  //     print('Notification activated');
  //   }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.hasTranscripts
            ? Dismissible(
                background: Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 124, 121, 121),
                  highlightColor: AppColors.white,
                  child: const Center(
                    child: Text(
                      'Please Wait!..\nCreating Memory',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                key: capturePageKey,
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) =>
                    widget.onDismissmissedCaptureMemory(direction),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GreetingCard(
                    name: '',
                    isDisconnected: true,
                    context: context,
                    hasTranscripts: widget.hasTranscripts,
                    wsConnectionState: widget.wsConnectionState,
                    device: widget.device,
                    internetStatus: widget.internetStatus,
                    segments: widget.segments,
                    memoryCreating: widget.memoryCreating,
                    photos: widget.photos,
                    scrollController: widget.scrollController,
                    avatarUrl:
                        'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GreetingCard(
                  name: '',
                  isDisconnected: true,
                  context: context,
                  hasTranscripts: widget.hasTranscripts,
                  wsConnectionState: widget.wsConnectionState,
                  device: widget.device,
                  internetStatus: widget.internetStatus,
                  segments: widget.segments,
                  memoryCreating: widget.memoryCreating,
                  photos: widget.photos,
                  scrollController: widget.scrollController,
                  avatarUrl:
                      'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
                ),
              ),

        //*--- Filter Button ---*//

        if (_isNonDiscarded || _memoryBloc.state.memories.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isNonDiscarded = !_isNonDiscarded;
                  _memoryBloc.add(
                    DisplayedMemory(isNonDiscarded: _isNonDiscarded),
                  );
                });
              },
              label: Text(
                _isNonDiscarded ? 'Show Discarded' : 'Hide Discarded',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Icon(
                _isNonDiscarded ? Icons.cancel_outlined : Icons.filter_list,
                size: 16,
                color: AppColors.grey,
              ),
            ),
          ),
        //*--- NOTIFICATION BUTTON ---*//
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _activateNotification,
            child: const Text('Activate Notification'),
          ),
        ),
        //*--- MEMORY LIST ---*//

        BlocConsumer<MemoryBloc, MemoryState>(
          bloc: _memoryBloc,
          builder: (context, state) {
            // print('>>>-${state.toString()}');
            if (state.status == MemoryStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.status == MemoryStatus.failure) {
              return const Center(
                child: Text(
                  'Oops! Failed to load memories',
                ),
              );
            } else if (state.status == MemoryStatus.success) {
              return MemoryCardWidget(memoryBloc: _memoryBloc);
            }
            return const SizedBox();
          },
          listener: (context, state) {
            if (state.status == MemoryStatus.failure) {
              avmSnackBar(context, 'Error: ${state.failure}');
            }
          },
        ),
      ],
    );
  }
}
