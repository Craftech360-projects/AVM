import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_card.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_search.dart';
import 'package:friend_private/pages/capture/capture_walkthrough.dart';
import 'package:friend_private/pages/capture/page.dart';
import 'package:friend_private/pages/capture/widgets/widgets.dart';
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
  GlobalKey searchTour = GlobalKey();
  GlobalKey captureTour = GlobalKey();
  @override
  void initState() {
    super.initState();
    captureWalkThrough(capturekey: captureTour, searchKey: searchTour);
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));

    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 
    if (SharedPreferencesUtil().isRestoreSuccessful) {
      _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
    }
    SharedPreferencesUtil().isRestoreSuccessful = false;
   
    return Column(
      children: [
        // FloatingActionButton(onPressed: () {
        //   showTutorial(context, targets: targets);
        // }),
        //*--- SEARCH BAR ---*//
        const SizedBox(height: 8),
        MemorySearchWidget(
          key: searchTour,
          searchController: _searchController,
          memoryBloc: _memoryBloc,
        ),
        const SizedBox(height: 8),
        //*-- Capture --//
        widget.hasTranscripts
            ? SizedBox(
                height: 176,
                child: Dismissible(
                  background: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    child: const Center(
                      child: Text(
                        'Please Wait!..\nMemory Creating',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  key: capturePageKey,
                  // key: ValueKey(widget.segments?.first.id ?? 'no-segment'),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) =>
                      widget.onDismissmissedCaptureMemory(direction),
                  child: CaptureCard(
                    context: context,
                    hasTranscripts: widget.hasTranscripts,
                    wsConnectionState: widget.wsConnectionState,
                    device: widget.device,
                    internetStatus: widget.internetStatus,
                    segments: widget.segments,
                    memoryCreating: widget.memoryCreating,
                    photos: widget.photos,
                    scrollController: widget.scrollController,
                  ),
                ),
              )
            : CaptureCard(
                key: captureTour,
                context: context,
                hasTranscripts: widget.hasTranscripts,
                wsConnectionState: widget.wsConnectionState,
                device: widget.device,
                internetStatus: widget.internetStatus,
                segments: widget.segments,
                memoryCreating: widget.memoryCreating,
                photos: widget.photos,
                scrollController: widget.scrollController,
              ),

        //*--- Filter Button ---*//

        if (_isNonDiscarded || _memoryBloc.state.memories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
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
                  _isNonDiscarded ? 'Hide Discarded' : 'Show Discarded',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 212, 212, 212),
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                //  Icon(
                //   _isNonDiscarded ? Icons.cancel_outlined : Icons.filter_list,
                //   size: 16,
                //   color: Colors.grey,
                // ),
                icon: Icon(
                  _isNonDiscarded ? Icons.cancel_outlined : Icons.filter_list,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        //*--- MEMORY LIST ---*//
        BlocConsumer<MemoryBloc, MemoryState>(
          bloc: _memoryBloc,
          // buildWhen: (previousState, currentState) {
          //   print('previous State${previousState.memories.length}');
          //   print('current  State${currentState.memories.length}');
          //   return previousState.memories.length !=
          //       currentState.memories.length;
          // },
          builder: (context, state) {
            print('>>>-${state.toString()}');
            if (state.status == MemoryStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.status == MemoryStatus.failure) {
              return Center(
                child: Text(
                  'Error: ${state.failure}',
                ),
              );
            } else if (state.status == MemoryStatus.success) {
              return MemoryCardWidget(memoryBloc: _memoryBloc);
            }
            return const SizedBox.shrink();
          },
          listener: (context, state) {
            if (state.status == MemoryStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.failure}'),
                ),
              );
            }
            // print('is shared prederence status ${SharedPreferencesUtil().isRestoreSuccessful}');
            // if (SharedPreferencesUtil().isRestoreSuccessful) {
            //   _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
            // }
            // SharedPreferencesUtil().isRestoreSuccessful = false;
          },
        ),
      ],
    );
  }
}
