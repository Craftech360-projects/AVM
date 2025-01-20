// ignore_for_file: unnecessary_null_comparison, duplicate_ignore

import 'package:capsaul/backend/database/geolocation.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/features/memories/widgets/category_chip.dart';
import 'package:capsaul/features/memories/widgets/overall_tab.dart';
import 'package:capsaul/features/memories/widgets/share.dart';
import 'package:capsaul/features/memories/widgets/tab_bar.dart';
import 'package:capsaul/features/memories/widgets/transcript_tab.dart';
import 'package:capsaul/features/memories/widgets/widgets.dart';
import 'package:capsaul/objectbox.g.dart';
import 'package:capsaul/utils/memories/reprocess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MemoryDetailPage extends StatefulWidget {
  final MemoryBloc memoryBloc;
  final int memoryAtIndex;
  final TabController? tabController;

  const MemoryDetailPage({
    super.key,
    required this.memoryBloc,
    required this.memoryAtIndex,
    this.tabController
  });

  static const String name = 'memoryDetailPage';

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Memory selectedMemory;
  TextEditingController titleController = TextEditingController();
  TextEditingController overviewController = TextEditingController();
  PageController pageController = PageController();

  List<bool> pluginResponseExpanded = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedMemory = widget.memoryBloc.state.memories[widget.memoryAtIndex];
    printGeolocationData(selectedMemory.geolocation);
  }

  void printGeolocationData(ToOne<Geolocation> geolocation) {
    if (geolocation.target != null) {
    } else {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getCategories(dynamic category) {
    if (category == null) return [];

    if (category is List) {
      return category.map((e) => e.toString()).toList();
    } else if (category is String) {
      if (category.startsWith('[') && category.endsWith(']')) {
        return category
            .substring(1, category.length - 1)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
      return [category];
    }

    return [];
  }

  List<Map<String, String>> _getFormattedTranscript(Object? transcript) {
    if (transcript == null) return [];

    if (transcript is List) {
      List<Map<String, String>> formattedTranscript = transcript.map((item) {
        final speaker = item['speaker']?.toString() ?? '';
        final text = item['text']?.toString() ?? '';

        return {
          'speaker': speaker,
          'text': text,
        };
      }).toList();

      return formattedTranscript;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // log(selectedMemory.toString());
    final categories =
        _getCategories(selectedMemory.structured.target?.category);
    _getFormattedTranscript(selectedMemory.transcript);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        title: Text(
            // ignore: unnecessary_null_comparison
            selectedMemory.createdAt != null
                ? '${DateFormat('d MMM').format(selectedMemory.createdAt)} -'
                    ' ${DateFormat('h:mm a').format(selectedMemory.createdAt)}'
                : 'No Date',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            onPressed: () {
              showShareBottomSheet(
                context,
                widget.memoryBloc.state.memories[widget.memoryAtIndex],
                setState,
              );
            },
            icon: const Icon(
              Icons.ios_share,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              showOptionsBottomSheet(
                context,
                setState,
                widget.memoryBloc.state.memories[widget.memoryAtIndex],
                _reProcessMemory,
              );
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 25,
            ),
          ),
          w8,
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 1.0],
            colors: [AppColors.white, AppColors.commonPink],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              selectedMemory.createdAt != null
                  ? '${selectedMemory.structured.target?.title}'
                  : "No title",
              style:
                  textTheme.labelLarge?.copyWith(fontSize: 20.h, height: 1.25),
            ),
            h4,
            if (categories.isNotEmpty)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: categories
                    .map(
                      (category) => CategoryChip(
                        tagName: category,
                      ),
                    )
                    .toList(),
              ),
            h16,
            Expanded(
              child: CustomTabBar(
                tabs: const [
                  Tab(text: 'Overall'),
                  Tab(text: 'Transcript'),
                ],
                children: [
                  OverallTab(
                    tabController: widget.tabController,
                    target: selectedMemory.structured.target!,
                    geolocation:
                        selectedMemory.geolocation.target, // Pass geolocation
                    //pluginsResponse: selectedMemory.pluginsResponse
                  ),
                  TranscriptTab(
                    memoryBloc: widget.memoryBloc,
                    memoryAtIndex: widget.memoryAtIndex, // Add this
                    // pageController: widget
                    //     .pageController, // Add this// Pass the formatted transcript
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _reProcessMemory(BuildContext context, StateSetter setModalState,
      Memory memory, Function changeLoadingState) async {
    Memory? newMemory = await reProcessMemory(
      context,
      memory,
      () => avmSnackBar(
        context,
        'Memory processing failed! Please try again.',
      ),
      changeLoadingState,
    );

    pluginResponseExpanded = List.filled(memory.pluginsResponse.length, false);
    overviewController.text = newMemory!.structured.target!.overview;
    titleController.text = newMemory.structured.target!.title;

    avmSnackBar(context, "Memory reprocessed successfully!");
    Navigator.pop(context, true);
  }
}
