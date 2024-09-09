import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_card.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_search.dart';
import 'package:friend_private/pages/capture/widgets/widgets.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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

  @override
  State<CaptureMemoryPage> createState() => _CaptureMemoryPageState();
}

class _CaptureMemoryPageState extends State<CaptureMemoryPage> {
  late MemoryBloc _memoryBloc;
  bool _isNonDiscarded = true;
  // final List<FilterItem> _filters = [
  //   FilterItem(filterType: 'Show All', filterStatus: false),
  //   FilterItem(filterType: 'Technology', filterStatus: false),
  // ];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));

    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super
        .dispose(); // This ensures that the parent class's dispose method is called.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //*--- SEARCH BAR ---*//
        MemorySearchWidget(
          searchController: _searchController,
          memoryBloc: _memoryBloc,
        ),
        const SizedBox(height: 8),
        //*-- Capture --//
        CaptureCard(
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
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   child: Align(
        //     alignment: Alignment.centerRight,
        //     child: PopupMenuButton<FilterItem>(
        //       icon: const Icon(
        //         Icons.filter_alt_sharp,
        //         size: 16,
        //         color: Colors.grey,
        //       ),
        //       onSelected: (filterItem) {
        //         print(
        //             'filteredItem ${filterItem.filterStatus},${filterItem.filterType}');
        //         _memoryBloc.add(FilterMemory(filterItem: filterItem));
        //         // setState(() {
        //         //   filterItem.filterStatus = !filterItem.filterStatus;

        //         //   if (filterItem.filterType == 'Show All') {
        //         //     _memoryBloc.add(DisplayedMemory(
        //         //         isNonDiscarded: filterItem.filterStatus));
        //         //   }

        //         //   print(
        //         //       'Selected filter: ${filterItem.filterType}, Status: ${filterItem.filterStatus}');
        //         // });
        //       },
        //       itemBuilder: (context) => _filters.map((filterItem) {
        //         return PopupMenuItem<FilterItem>(
        //           value: filterItem,
        //           child: Row(
        //             children: [
        //               filterItem.filterStatus
        //                   ? const Icon(
        //                       Icons.check,
        //                       color: Colors.green,
        //                     )
        //                   : const Icon(
        //                       Icons.check,
        //                       color: Colors.grey,
        //                     ),
        //               Text(filterItem.filterType),
        //             ],
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isNonDiscarded = !_isNonDiscarded;
                  _memoryBloc.add(
                    DisplayedMemory(isNonDiscarded: _isNonDiscarded),
                  );
                });
              },
              label: Icon(
                _isNonDiscarded ? Icons.cancel_outlined : Icons.filter_list,
                size: 16,
                color: Colors.grey,
              ),
              icon: Text(
                _isNonDiscarded ? 'Hide Discarded' : 'Show Discarded',
                style: const TextStyle(
                    color: Color.fromARGB(255, 212, 212, 212),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
        //*--- MEMORY LIST ---*//
        BlocConsumer<MemoryBloc, MemoryState>(
          bloc: _memoryBloc,
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
          },
        ),
      ],
    );
  }
}
