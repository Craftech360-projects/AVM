import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/assets/app_animations.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/capture/models/filter_item.dart';
import 'package:altio/features/capture/presentation/capture_page.dart';
import 'package:altio/features/capture/widgets/filter_widget.dart';
import 'package:altio/features/capture/widgets/greeting_card.dart';
import 'package:altio/features/capture/widgets/real_time_bot.dart';
import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/features/memories/widgets/memory_card_widget.dart';
import 'package:altio/pages/skeleton/screen_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

class CaptureMemoryPage extends StatefulWidget {
  const CaptureMemoryPage({
    super.key,
    required this.context,
    required this.hasTranscripts,
    this.device,
    this.segments,
    required this.memoryCreating,
    this.scrollController,
    required this.onDismissmissedCaptureMemory,
    required this.hasSeenTutorial,
    this.tabController,
  });

  final TabController? tabController;
  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final ScrollController? scrollController;
  final Function(DismissDirection) onDismissmissedCaptureMemory;
  final bool hasSeenTutorial;

  @override
  State<CaptureMemoryPage> createState() => _CaptureMemoryPageState();
}

class _CaptureMemoryPageState extends State<CaptureMemoryPage>
    with TickerProviderStateMixin {
  late MemoryBloc _memoryBloc;

  late Animation<double> _animation;
  late AnimationController _lottieController;
  late AnimationController _buttonFlipController;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isFlippingRight = true;
  bool _switchValue = SharedPreferencesUtil().notificationPlugin;

  final List<int> items = List.generate(1, (index) => index);

  bool _isNonDiscarded = true;
  final GlobalKey<CapturePageState> capturePageKey =
      GlobalKey<CapturePageState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  FilterItem? _selectedFilter;

  final GlobalKey _greetingCardKey = GlobalKey();
  final GlobalKey _floatingActionKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  int currentTutorialIndex = 0;

  void checkTutorialStatus() async {
    bool hasSeen = widget.hasSeenTutorial;
    if (!hasSeen) {
      await _createTutorial();
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              contentPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: br2),
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
    checkTutorialStatus();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
    _switchValue = SharedPreferencesUtil().notificationPlugin;

    _searchController.addListener(() {
      _memoryBloc.add(SearchMemory(query: _searchController.text));
    });

    _lottieController = AnimationController(vsync: this);

    _buttonFlipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(
        parent: _buttonFlipController,
        curve: Curves.easeInOut,
      ),
    );

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _buttonFlipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isFlippingRight = !_isFlippingRight;
            });
            _buttonFlipController.reset();
            _buttonFlipController.forward();
          }
        });
      }
    });

    // Start the first flip
    _buttonFlipController.forward();

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
    _lottieController.dispose();
    _buttonFlipController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        if (deviceProvider.hasDevice == null) {
          return const Scaffold(
            body: ScreenSkeleton(),
          );
        }

        return BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc(),
          child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, connectivityState) {
              return deviceProvider.hasDevice == true
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 10),
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              if (widget.memoryCreating)
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: br8,
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                .onDismissmissedCaptureMemory(
                                                    direction);

                                            setState(() {
                                              items.remove(item);
                                            });
                                          } on Exception catch (e) {
                                            debugPrint(e.toString());
                                            if (!context.mounted) return;
                                            avmSnackBar(context,
                                                'Oops! Something went wrong.\nPlease try again.');
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            BlocBuilder<ConnectivityBloc,
                                                ConnectivityState>(
                                              builder:
                                                  (context, connectivityState) {
                                                return GreetingCard(
                                                  name: '',
                                                  isDisconnected: true,
                                                  context: context,
                                                  hasTranscripts:
                                                      widget.hasTranscripts,
                                                  segments: widget.segments,
                                                  memoryCreating:
                                                      widget.memoryCreating,
                                                  scrollController:
                                                      widget.scrollController,
                                                );
                                              },
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(
                                                "Swipe right to create your memory ...",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ));
                                  },
                                )
                              else
                                BlocBuilder<ConnectivityBloc,
                                    ConnectivityState>(
                                  builder: (context, connectivityState) {
                                    return GreetingCard(
                                      name: '',
                                      isDisconnected: true,
                                      context: context,
                                      hasTranscripts: widget.hasTranscripts,
                                      segments: widget.segments,
                                      memoryCreating: widget.memoryCreating,
                                      scrollController: widget.scrollController,
                                    );
                                  },
                                ),

                              const Divider(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible:
                                        _memoryBloc.state.memories.isNotEmpty
                                            ? true
                                            : false,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isNonDiscarded = !_isNonDiscarded;
                                          _memoryBloc.add(
                                            DisplayedMemory(
                                                isNonDiscarded:
                                                    _isNonDiscarded),
                                          );
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isNonDiscarded
                                                ? Icons.cancel_outlined
                                                : Icons.filter_list,
                                            size: 15,
                                          ),
                                          w4,
                                          Text(
                                            _isNonDiscarded
                                                ? 'Show Discarded'
                                                : 'Hide Discarded',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final selectedFilter =
                                          await showDialog<FilterItem>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: br12),
                                            backgroundColor:
                                                AppColors.commonPink,
                                            title: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.filter_alt_outlined,
                                                    color: AppColors.blue),
                                                w8,
                                                Text(
                                                  "Choose Filter",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        AppColors.blueGreyDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Divider(
                                                  color: AppColors.purpleDark,
                                                  thickness: 1.5,
                                                ),
                                                FilterOptionWidget(
                                                  title: "Today's Memory",
                                                  isSelected: _selectedFilter
                                                          ?.filterType ==
                                                      "Today",
                                                  onTap: () {
                                                    Navigator.pop(
                                                        context,
                                                        _selectedFilter
                                                                    ?.filterType ==
                                                                "Today"
                                                            ? null
                                                            : FilterItem(
                                                                filterType:
                                                                    "Today"));
                                                  },
                                                ),
                                                FilterOptionWidget(
                                                  title: "This Week's Memory",
                                                  isSelected: _selectedFilter
                                                          ?.filterType ==
                                                      "This Week",
                                                  onTap: () {
                                                    Navigator.pop(
                                                        context,
                                                        _selectedFilter
                                                                    ?.filterType ==
                                                                "This Week"
                                                            ? null
                                                            : FilterItem(
                                                                filterType:
                                                                    "This Week"));
                                                  },
                                                ),
                                                FilterOptionWidget(
                                                  title: "Date Range Selection",
                                                  isSelected: _selectedFilter
                                                          ?.filterType ==
                                                      "DateRange",
                                                  onTap: () async {
                                                    final DateTimeRange?
                                                        dateRange =
                                                        await showDateRangePicker(
                                                      context: context,
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime.now(),
                                                    );

                                                    if (dateRange != null) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      Navigator.pop(
                                                        context,
                                                        _selectedFilter
                                                                    ?.filterType ==
                                                                "DateRange"
                                                            ? null
                                                            : FilterItem(
                                                                filterType:
                                                                    "DateRange",
                                                                startDate:
                                                                    dateRange
                                                                        .start,
                                                                endDate:
                                                                    dateRange
                                                                        .end,
                                                              ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                FilterOptionWidget(
                                                  title: "Show All",
                                                  isSelected: _selectedFilter
                                                          ?.filterType ==
                                                      "Show All",
                                                  onTap: () {
                                                    Navigator.pop(
                                                        context,
                                                        _selectedFilter
                                                                    ?.filterType ==
                                                                "Show All"
                                                            ? null
                                                            : FilterItem(
                                                                filterType:
                                                                    "Show All"));
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
                                                startDate:
                                                    selectedFilter.startDate,
                                                endDate: selectedFilter.endDate,
                                              ),
                                            );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.filter_alt_outlined,
                                          size: 15,
                                        ),
                                        w4,
                                        Text(
                                          'Filter',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
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
                                    } else if (state.status ==
                                        MemoryStatus.failure) {
                                      return Center(
                                        child: Text(
                                          'Error: ${state.failure}',
                                        ),
                                      );
                                    } else if (state.status ==
                                        MemoryStatus.success) {
                                      return MemoryCardWidget(
                                          memoryBloc: _memoryBloc,
                                          tabController: widget.tabController);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  listener: (context, state) {
                                    if (state.status == MemoryStatus.success) {
                                      setState(() {});
                                    }
                                    if (state.status == MemoryStatus.failure) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
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
                              top: 0,
                              left: 0,
                              right: 0,
                              child: _buildScrollGradient()),
                        Positioned(
                          bottom: MediaQuery.of(context).size.width * 0.007,
                          right: 10,
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  double flipValue = _isFlippingRight
                                      ? _animation.value
                                      : -_animation.value;

                                  Matrix4 transform = Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(flipValue);

                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: transform,
                                    child: FloatingActionButton(
                                      key: _floatingActionKey,
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
                              h8,
                              if (SharedPreferencesUtil().notificationPlugin)
                                const TypingIndicator(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                        margin: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: br8,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                                textAlign: TextAlign.center,
                                "Ohoo! Seems like you don't have Capsaul with you!",
                                style: TextStyle(
                                    fontFamily: "SpaceGrotesk",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.5,
                                    height: 1.1)),
                            h8,
                            const Text(
                              textAlign: TextAlign.center,
                              "Don't worry! Click the button below to get your Capsaul and start capturing memories🤩",
                              style: TextStyle(
                                  fontFamily: "SpaceGrotesk",
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                  fontSize: 13),
                            ),
                            h8,
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: br30,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD4AF37)
                                            .withValues(alpha: 0.4),
                                        blurRadius: _scaleAnimation.value,
                                        spreadRadius:
                                            _scaleAnimation.value * 0.1,
                                      ),
                                    ],
                                  ),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFF001F3F),
                                      foregroundColor: const Color(0xFFD4AF37),
                                      side: const BorderSide(
                                          color: Color(0xFFFFC72C), width: 2.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: br30,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final Uri url = Uri.parse(
                                          'https://www.freeprivacypolicy.com/live/38486d16-4053-4bcd-8786-884b58c52ca2');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: const Text(
                                      "Get Capsaul",
                                      style: TextStyle(
                                        fontFamily: "SpaceGrotesk",
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Lottie.asset(
                              AppAnimations.orderNow,
                              controller: _lottieController,
                              onLoaded: (composition) {
                                _lottieController
                                  ..duration = composition.duration
                                  ..repeat();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Animation failed to load');
                              },
                            )
                          ],
                        ),
                      ),
                    );
            },
          ),
        );
      },
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
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: const Text(
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
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: const Text(
                  textAlign: TextAlign.center,
                  'After speaking, swipe right to create your memory',
                  style: TextStyle(
                      color: AppColors.white, fontSize: 17, height: 1.3),
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'floatingAction',
          keyTarget: _floatingActionKey,
          alignSkip: Alignment.bottomCenter,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => const Text(
                textAlign: TextAlign.center,
                'Enable Capsaul bot to get real-time responses',
                style: TextStyle(
                    color: AppColors.white, fontSize: 17, height: 1.3),
              ),
            ),
          ],
        ),
      ];

      void showTutorialFromIndex() {
        final tutorial = TutorialCoachMark(
          textStyleSkip: const TextStyle(
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
