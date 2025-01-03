import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/core/widgets/typing_indicator.dart';
import 'package:avm/features/capture/models/filter_item.dart';
import 'package:avm/features/capture/presentation/capture_page.dart';
import 'package:avm/features/capture/widgets/greeting_card.dart';
import 'package:avm/features/capture/widgets/real_time_bot.dart';
import 'package:avm/features/connectivity/bloc/connectivity_bloc.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/features/memory/presentation/widgets/memory_card.dart';
import 'package:avm/pages/memories/widgets/empty_memories.dart';
import 'package:avm/pages/skeleton/screen_skeleton.dart';
import 'package:avm/utils/websockets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';

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

  @override
  State<CaptureMemoryPage> createState() => _CaptureMemoryPageState();
}

class _CaptureMemoryPageState extends State<CaptureMemoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFlippingRight = true;
  final List<int> items = List.generate(1, (index) => index);
  late MemoryBloc _memoryBloc;
  bool _isNonDiscarded = true;
  final GlobalKey<CapturePageState> capturePageKey =
      GlobalKey<CapturePageState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _switchValue = SharedPreferencesUtil().notificationPlugin;
  String _activeFilter = 'Show All';

  @override
  void initState() {
    super.initState();
    _initializeMemoryBloc();
    _initializeAnimationController();
    _initializeScrollController();
    _initializeConnectivityListener();
  }

  void _initializeMemoryBloc() {
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resetAnimation();
      }
    });

    _animationController.forward();
  }

  void _initializeScrollController() {
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

  void _initializeConnectivityListener() {
    BlocProvider.of<ConnectivityBloc>(context).stream.listen((state) {
      if (state is ConnectivityStatusChanged) {
        setState(() {
          widget.internetStatus =
              _mapConnectivityResultToInternetStatus(state.status);
        });
      }
    });
  }

  void _resetAnimation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isFlippingRight = !_isFlippingRight;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityBloc>(
      create: (context) => ConnectivityBloc(),
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          return Stack(
            children: [
              _buildScrollView(connectivityState),
              if (_isScrolled) _buildScrollGradient(),
              _buildFloatingActionButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollView(ConnectivityState connectivityState) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 14),
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          if (widget.memoryCreating) _buildMemoryCreationIndicator(),
          if (widget.hasTranscripts) ..._buildTranscriptItems(),
          if (!widget.hasTranscripts) _buildGreetingCard(connectivityState),
          _buildFilterButtonRow(),
          _buildMemoryList(),
        ],
      ),
    );
  }

  Widget _buildMemoryCreationIndicator() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        borderRadius: br8,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Creating new memory ...",
              style: TextStyle(color: AppColors.black),
            ),
            h10,
            TypingIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTranscriptItems() {
    return items.map((item) {
      return Dismissible(
        key: ValueKey(item),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) async {
          try {
            await widget.onDismissmissedCaptureMemory(direction);
            setState(() {
              items.remove(item);
            });
          } catch (e) {
            avmSnackBar(
                context, 'Oops! Something went wrong.\nPlease try again.');
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
              internetStatus: widget.internetStatus,
              segments: widget.segments,
              memoryCreating: widget.memoryCreating,
              photos: widget.photos,
              scrollController: widget.scrollController,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
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
        ),
      );
    }).toList();
  }

  Widget _buildGreetingCard(ConnectivityState connectivityState) {
    return GreetingCard(
      name: '',
      isDisconnected: true,
      context: context,
      hasTranscripts: widget.hasTranscripts,
      wsConnectionState: widget.wsConnectionState,
      internetStatus:
          _mapConnectivityResultToInternetStatus(connectivityState.status),
      segments: widget.segments,
      memoryCreating: widget.memoryCreating,
      photos: widget.photos,
      scrollController: widget.scrollController,
    );
  }

  Widget _buildFilterButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShowHideDiscardedButton(),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildShowHideDiscardedButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _isNonDiscarded = !_isNonDiscarded;
            _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
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
    );
  }

  Widget _buildFilterButton() {
    return TextButton.icon(
      onPressed: _showFilterDialog,
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
    );
  }

  void _showFilterDialog() async {
    final selectedFilter = await showDialog<FilterItem>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: br12),
          backgroundColor: AppColors.commonPink,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt_outlined, color: AppColors.blue),
              w10,
              Text(
                maxLines: 2,
                "Choose Filter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.blueGreyDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: AppColors.purpleDark, thickness: 1.5),
              _buildFilterListTile("Today's Memory", "Today"),
              _buildFilterListTile("This Week's Memory", "This Week"),
              _buildFilterListTile("Date Range Selection", "DateRange"),
              _buildFilterListTile("Show All", "Show All"),
            ],
          ),
        );
      },
    );

    if (selectedFilter != null) {
      setState(() {
        _activeFilter = selectedFilter.filterType;
      });
      context.read<MemoryBloc>().add(
            FilterMemory(
              filterItem: selectedFilter,
              startDate: selectedFilter.startDate,
              endDate: selectedFilter.endDate,
            ),
          );
    }
  }

  Widget _buildFilterListTile(String title, String filterType) {
    bool isActive = _activeFilter == filterType;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 08),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purpleDark : AppColors.white,
          border: Border.all(color: AppColors.purpleDark),
          borderRadius: br12,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.black,
          ),
        ),
      ),
      onTap: () async {
        if (filterType == "DateRange") {
          // Trigger date range picker
          final DateTimeRange? selectedRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );

          // If a range is selected, pass it back and set the active filter
          if (selectedRange != null) {
            Navigator.pop(
                context,
                FilterItem(
                  filterType: "DateRange",
                  startDate: selectedRange.start,
                  endDate: selectedRange.end,
                ));
          }
        } else {
          Navigator.pop(context, FilterItem(filterType: filterType));
        }
      },
    );
  }

  Widget _buildMemoryList() {
    return BlocConsumer<MemoryBloc, MemoryState>(
      bloc: _memoryBloc,
      builder: (context, state) {
        if (state.status == MemoryStatus.loading) {
          return const Center(child: ScreenSkeleton());
        }

        if (state.status == MemoryStatus.failure) {
          return const Center(
            child: Text(
              'Oops! Failed to load memories',
              style: TextStyle(color: AppColors.grey),
            ),
          );
        }

        if (state.memories.isEmpty) {
          return _buildEmptyMemories();
        }

        return MemoryCardWidget(memoryBloc: _memoryBloc);
      },
      listener: (context, state) {
        if (state.status == MemoryStatus.failure) {
          avmSnackBar(context, 'Error: ${state.failure}');
        }
      },
    );
  }

  Widget _buildEmptyMemories() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 08.0, vertical: 40.0),
      child: EmptyMemoriesWidget(),
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
            AppColors.commonPink.withValues(alpha: 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 14,
      right: 08,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              double flipValue =
                  _isFlippingRight ? _animation.value : -_animation.value;
              Matrix4 transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipValue);

              return Transform(
                alignment: Alignment.center,
                transform: transform,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  elevation: 8.0,
                  backgroundColor: AppColors.purpleDark,
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
          h10,
          if (SharedPreferencesUtil().notificationPlugin) TypingIndicator(),
        ],
      ),
    );
  }
}
