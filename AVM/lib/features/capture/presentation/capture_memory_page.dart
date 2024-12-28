import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/core/widgets/typing_indicator.dart';
import 'package:avm/features/capture/presentation/capture_page.dart';
import 'package:avm/features/capture/widgets/greeting_card.dart';
import 'package:avm/features/capture/widgets/real_time_bot.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/features/memory/presentation/widgets/memory_card.dart';
import 'package:avm/pages/skeleton/screen_skeleton.dart';
import 'package:avm/utils/websockets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _CaptureMemoryPageState extends State<CaptureMemoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<int> items = List.generate(1, (index) => index);
  late MemoryBloc _memoryBloc;
  bool _isNonDiscarded = true;
  final GlobalKey<CapturePageState> capturePageKey =
      GlobalKey<CapturePageState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _switchValue = SharedPreferencesUtil().notificationPlugin;

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: br8),
              content: FittedBox(
                fit: BoxFit.scaleDown,
                child: buildPopupContent(
                  setState,
                  _switchValue,
                  (bool value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 08),
    )..repeat(reverse: true);

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
    _animationController.dispose();
    super.dispose();
  }

  // void _resetDismissedList() {
  //   setState(() {
  //     dismissedList.clear();
  //     dismissedList.addAll(List.filled(widget.segments?.length ?? 0, false));
  //     // dismissedList.addAll(List.generate(widget.segments?.length ?? 0, (_) => false));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 14),
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              if (widget.memoryCreating)
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
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
                      h10,
                      TypingIndicator(),
                    ],
                  ),
                ),
              if (widget.hasTranscripts)
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
                              device: widget.device,
                              internetStatus: widget.internetStatus,
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
                                  fontWeight: FontWeight.w600,
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
                  device: widget.device,
                  internetStatus: widget.internetStatus,
                  segments: widget.segments,
                  memoryCreating: widget.memoryCreating,
                  photos: widget.photos,
                  scrollController: widget.scrollController,
                ),
              h10,
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
                      _isNonDiscarded
                          ? Icons.cancel_outlined
                          : Icons.filter_list,
                      size: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ),

              //*--- MEMORY LIST ---*//

              BlocConsumer<MemoryBloc, MemoryState>(
                bloc: _memoryBloc,
                builder: (context, state) {
                  // print('>>>-${state.toString()}');
                  if (state.status == MemoryStatus.loading) {
                    return const Center(
                      child: ScreenSkeleton(),
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
          ),
        ),
        if (_isScrolled)
          Positioned(top: 0, left: 0, right: 0, child: _buildScrollGradient()),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 8, 22),
          alignment: Alignment.bottomRight,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double value = _animationController.value;
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.purpleDark, AppColors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [value, 1 - value],
                  ),
                ),
                child: FloatingActionButton(
                  shape: CircleBorder(),
                  elevation: 0.8,
                  backgroundColor: Colors.transparent,
                  onPressed: _showPopup,
                  child: Image.asset(
                    AppImages.botIcon,
                    width: 45,
                    height: 45,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
}
