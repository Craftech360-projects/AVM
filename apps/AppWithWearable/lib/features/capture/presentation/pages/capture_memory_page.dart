import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/memory_card.dart';
import 'package:friend_private/pages/capture/page.dart';
import 'package:friend_private/pages/capture/widgets/widgets.dart';
import 'package:friend_private/src/core/constant/constant.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
    return Column(
      children: [
        // FloatingActionButton(
        //   onPressed: () async {
        //     BlocProvider.of<LiveTranscriptBloc>(context).add(ScannedDevices());

        //   },
        //   child: const Icon(
        //     Icons.battery_charging_full,
        //     color: Colors.white,
        //   ),
        // ),
        // BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
        //   bloc: BlocProvider.of(context),
        //   builder: (context, state) {
        //     print('bluetooth state bloc ${state.toString()}');
        //     return ListTile();
        //   },
        // ),
        //*--- SEARCH BAR ---*//
        // const SizedBox(height: 8),
        // MemorySearchWidget(
        //   searchController: _searchController,
        //   memoryBloc: _memoryBloc,
        // ),
        // const SizedBox(height: 8),
        //! Dummy Card
        // Card(
        //   color: CustomColors.greyLavender,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       ListTile(
        //         leading: CircleAvatar(
        //           child: ClipOval(
        //             child: Image.network(
        //               'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
        //               width: 50.0,
        //               height: 50.0,
        //               fit: BoxFit.cover,
        //             ),
        //           ),
        //         ),
        //         title: const Text('Text Here'),
        //       ),
        //       const Divider(
        //         height: 0,
        //         thickness: 0.5,
        //         color: CustomColors.greyLight,
        //       ),
        //       const Text('Meta Data')
        //     ],
        //   ),
        // ),

        // GreetingCard(
        //   name: 'Joe',
        //   isDisconnected: true,
        //   context: context,
        //   hasTranscripts: widget.hasTranscripts,
        //   wsConnectionState: widget.wsConnectionState,
        //   device: widget.device,
        //   internetStatus: widget.internetStatus,
        //   segments: widget.segments,
        //   memoryCreating: widget.memoryCreating,
        //   photos: widget.photos,
        //   scrollController: widget.scrollController,
        //   avatarUrl:
        //       'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
        // ),
        //*-- Capture --//
        widget.hasTranscripts
            ? SizedBox(
                // height: 176,
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
                  child: Padding(
                    // Add margin using Padding
                    padding: const EdgeInsets.all(8.0),
                    // child: CaptureCard(
                    //   context: context,
                    //   hasTranscripts: widget.hasTranscripts,
                    //   wsConnectionState: widget.wsConnectionState,
                    //   device: widget.device,
                    //   internetStatus: widget.internetStatus,
                    //   segments: widget.segments,
                    //   memoryCreating: widget.memoryCreating,
                    //   photos: widget.photos,
                    //   scrollController: widget.scrollController,
                    // ),
                    child: GreetingCard(
                      name: 'Joe',
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
                ),
              )
            : Padding(
                // Add margin using Padding
                padding: const EdgeInsets.all(8.0),
                // child: CaptureCard(
                //   context: context,
                //   hasTranscripts: widget.hasTranscripts,
                //   wsConnectionState: widget.wsConnectionState,
                //   device: widget.device,
                //   internetStatus: widget.internetStatus,
                //   segments: widget.segments,
                //   memoryCreating: widget.memoryCreating,
                //   photos: widget.photos,
                //   scrollController: widget.scrollController,
                // ),
                child: GreetingCard(
                  name: 'Joe',
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
                      fontWeight: FontWeight.w500),
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
          },
        ),
      ],
    );
  }
}



            //!
            // final batteryLevelStream = await BleConnectionDatasource()
            //     .getBleBatteryLevelListener('C4:E8:E3:9F:D2:AE');

            // if (batteryLevelStream != null) {
            //   batteryLevelStream.onData(
            //     (data) => print('datat received ${data.first.toString()}'),
            //   );
            //   print(
            //       'Connected to BLE device. Listening for battery level updates...');
            // }
            //!
            // final wavBytesUtil = WavBytesUtil();
            // StreamSubscription? stream = await BleConnectionDatasource()
            //     .getBleAudioBytesListener('C4:E8:E3:9F:D2:AE',
            //         onAudioBytesReceived: (List<int> value) {
            //   print('audio values printed $value');
            //   if (value.isEmpty) return;
            //   value.removeRange(0, 3);
            //   for (int i = 0; i < value.length; i += 2) {
            //     int byte1 = value[i];
            //     int byte2 = value[i + 1];
            //     int int16Value = (byte2 << 8) | byte1;
            //     wavBytesUtil.addAudioBytes([int16Value]);
            //   }
            // });
            //!
            // final codecformat =
            //     await BleConnectionDatasource().getAudioCodec('C4:E8:E3:9F:D2:AE');
            // print('codecic format ${codecformat}');



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