import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/capture/models/filter_item.dart';
import 'package:altio/features/capture/presentation/capture_page.dart';
import 'package:altio/features/capture/widgets/filter_widget.dart';
import 'package:altio/features/capture/widgets/greeting_card.dart';
import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/features/memories/widgets/memory_card_widget.dart';
import 'package:altio/utils/websockets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// ignore: must_be_immutable
class CaptureMemoryPage extends StatefulWidget {
  CaptureMemoryPage({
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
    required this.hasSeenTutorial,
  });

  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final List<Tuple2<String, String>> photos;
  final ScrollController? scrollController;
  final Function(DismissDirection) onDismissmissedCaptureMemory;
  final bool hasSeenTutorial;

  @override
  State<CaptureMemoryPage> createState() => _CaptureMemoryPageState();
}

class _CaptureMemoryPageState extends State<CaptureMemoryPage> {
  final List<int> items = List.generate(1, (index) => index);
  late MemoryBloc _memoryBloc;
  bool _isNonDiscarded = true;
  final GlobalKey<CapturePageState> capturePageKey =
      GlobalKey<CapturePageState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  FilterItem? _selectedFilter;
  final GlobalKey _greetingCardKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  int currentTutorialIndex = 0;

  InternetStatus? _mapConnectivityResultToInternetStatus(
      ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        return InternetStatus.connected;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
      case ConnectivityResult.other:
        return InternetStatus.disconnected;
    }
  }

  void checkTutorialStatus() async {
    bool hasSeen = widget.hasSeenTutorial;
    // SharedPreferencesUtil().hasSeenTutorial;
    if (!hasSeen) {
      _createTutorial();
    }
  }

  @override
  void initState() {
    super.initState();
    checkTutorialStatus();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));

    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 0 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });

    // Listen to connectivity changes
    BlocProvider.of<ConnectivityBloc>(context).stream.listen((state) {
      if (state is ConnectivityStatusChanged) {
        setState(() {
          widget.internetStatus =
              _mapConnectivityResultToInternetStatus(state.status);
        });
      }
    });
  }

  @override
  void didUpdateWidget(CaptureMemoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasTranscripts &&
        oldWidget.hasTranscripts != widget.hasTranscripts) {
      setState(() {
        items.clear();
        items.add(0);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityBloc>(
      create: (context) => ConnectivityBloc(),
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          return Stack(children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 25),
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: Column(
                children: [
                  if (widget.memoryCreating)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: br8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Creating new memory ...",
                            style: TextStyle(
                              color: AppColors.black,
                            ),
                          ),
                          h8,
                          TypingIndicator(),
                        ],
                      ),
                    )
                  else if (widget.hasTranscripts)
                    ...items.map(
                      (item) {
                        return Dismissible(
                            key: ValueKey(item),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) async {
                              try {
                                await widget
                                    .onDismissmissedCaptureMemory(direction);

                                setState(() {
                                  items.remove(item);
                                });
                              } catch (e) {
                                if (!context.mounted) return;
                                avmSnackBar(context,
                                    'Oops! Something went wrong.\nPlease try again.');
                              }
                            },
                            child: Column(
                              children: [
                                GreetingCard(
                                  name: '',
                                  isDisconnected: true,
                                  context: context,
                                  hasTranscripts: widget.hasTranscripts,
                                  wsConnectionState: widget.wsConnectionState,
                                  internetStatus:
                                      _mapConnectivityResultToInternetStatus(
                                          connectivityState.status),
                                  segments: widget.segments,
                                  memoryCreating: widget.memoryCreating,
                                  photos: widget.photos,
                                  scrollController: widget.scrollController,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 6),
                                  child: Text(
                                    "Swipe right to create your memory ...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ));
                      },
                    )
                  else
                    GreetingCard(
                      name: '',
                      isDisconnected: true,
                      context: context,
                      hasTranscripts: widget.hasTranscripts,
                      wsConnectionState: widget.wsConnectionState,
                      internetStatus: _mapConnectivityResultToInternetStatus(
                          connectivityState.status),
                      segments: widget.segments,
                      memoryCreating: widget.memoryCreating,
                      photos: widget.photos,
                      scrollController: widget.scrollController,
                      tutorialKey: _greetingCardKey,
                    ),
                  Divider(),
                  //*--- Filter Button ---*//

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: _memoryBloc.state.memories.isNotEmpty
                            ? true
                            : false,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isNonDiscarded = !_isNonDiscarded;
                              _memoryBloc.add(
                                DisplayedMemory(
                                    isNonDiscarded: _isNonDiscarded),
                              );
                            });
                          },
                          label: Text(
                            _isNonDiscarded
                                ? 'Show Discarded'
                                : 'Hide Discarded',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: Icon(
                            _isNonDiscarded
                                ? Icons.filter_list
                                : Icons.cancel_outlined,
                            size: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final selectedFilter = await showDialog<FilterItem>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                shape:
                                    RoundedRectangleBorder(borderRadius: br12),
                                backgroundColor: AppColors.commonPink,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.filter_alt_outlined,
                                        color: AppColors.blue),
                                    w8,
                                    Text(
                                      "Choose Filter",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.blueGreyDark,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Divider(
                                      color: AppColors.purpleDark,
                                      thickness: 1.5,
                                    ),
                                    FilterOptionWidget(
                                      title: "Today's Memory",
                                      isSelected: _selectedFilter?.filterType ==
                                          "Today",
                                      onTap: () {
                                        Navigator.pop(
                                            context,
                                            _selectedFilter?.filterType ==
                                                    "Today"
                                                ? null
                                                : FilterItem(
                                                    filterType: "Today"));
                                      },
                                    ),
                                    FilterOptionWidget(
                                      title: "This Week's Memory",
                                      isSelected: _selectedFilter?.filterType ==
                                          "This Week",
                                      onTap: () {
                                        Navigator.pop(
                                            context,
                                            _selectedFilter?.filterType ==
                                                    "This Week"
                                                ? null
                                                : FilterItem(
                                                    filterType: "This Week"));
                                      },
                                    ),
                                    FilterOptionWidget(
                                      title: "Date Range Selection",
                                      isSelected: _selectedFilter?.filterType ==
                                          "DateRange",
                                      onTap: () async {
                                        final DateTimeRange? dateRange =
                                            await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );

                                        if (dateRange != null) {
                                          if (!context.mounted) return;
                                          Navigator.pop(
                                            context,
                                            _selectedFilter?.filterType ==
                                                    "DateRange"
                                                ? null
                                                : FilterItem(
                                                    filterType: "DateRange",
                                                    startDate: dateRange.start,
                                                    endDate: dateRange.end,
                                                  ),
                                          );
                                        }
                                      },
                                    ),
                                    FilterOptionWidget(
                                      title: "Show All",
                                      isSelected: _selectedFilter?.filterType ==
                                          "Show All",
                                      onTap: () {
                                        Navigator.pop(
                                            context,
                                            _selectedFilter?.filterType ==
                                                    "Show All"
                                                ? null
                                                : FilterItem(
                                                    filterType: "Show All"));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          setState(() {
                            _selectedFilter = selectedFilter;
                          });

                          if (selectedFilter != null) {
                            if (!context.mounted) return;
                            context.read<MemoryBloc>().add(
                                  FilterMemory(
                                    filterItem: selectedFilter,
                                    startDate: selectedFilter.startDate,
                                    endDate: selectedFilter.endDate,
                                  ),
                                );
                          }
                        },
                        label: const Text(
                          'Filter',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(
                          Icons.filter_alt_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),

                  //*--- MEMORY LIST ---*//

                  BlocConsumer<MemoryBloc, MemoryState>(
                      bloc: _memoryBloc,
                      builder: (context, state) {
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
                          return MemoryCardWidget(
                            memoryBloc: _memoryBloc,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      listener: (context, state) {
                        if (state.status == MemoryStatus.success) {
                          setState(() {});
                        }
                        if (state.status == MemoryStatus.failure) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.failure ??
                                'Oops! An unknown error occurred.'),
                          ));
                        }
                      }),
                ],
              ),
            ),
            if (_isScrolled)
              Positioned(
                  top: 0, left: 0, right: 0, child: _buildScrollGradient()),
          ]);
        },
      ),
    );
  }

  Widget _buildScrollGradient() {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.commonPink.withValues(alpha: 0.025)
          ],
        ),
      ),
    );
  }

  Future<void> _createTutorial() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Define all tutorial targets
      final List<TargetFocus> targets = [
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          radius: 8.0,
          alignSkip: Alignment.bottomRight,
          identify: 'greetingCard',
          keyTarget: _greetingCardKey,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  textAlign: TextAlign.center,
                  'While speaking tap this widget to see live transcripts',
                  style: TextStyle(
                      color: AppColors.white, fontSize: 17, height: 1.3),
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          radius: 8.0,
          identify: 'greetingCard',
          keyTarget: _greetingCardKey,
          alignSkip: Alignment.bottomRight,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  textAlign: TextAlign.center,
                  'After speaking, swipe right to create your memory',
                  style: TextStyle(
                      color: AppColors.white, fontSize: 17, height: 1.3),
                ),
              ),
            ),
          ],
        ),
      ];

      void showTutorialFromIndex() {
        final tutorial = TutorialCoachMark(
          textSkip: "NEXT",
          textStyleSkip: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.white,
          ),
          targets: targets.sublist(currentTutorialIndex),
          colorShadow: AppColors.black.withValues(alpha: 0.7),
          onSkip: () {
            currentTutorialIndex++;
            if (currentTutorialIndex < targets.length) {
              showTutorialFromIndex();
            }
            SharedPreferencesUtil().hasSeenTutorial = true;
            return true;
          },
          onFinish: () {
            SharedPreferencesUtil().hasSeenTutorial = true;
          },
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          tutorial.show(context: context);
        });
      }

      showTutorialFromIndex();
    });
  }
}
