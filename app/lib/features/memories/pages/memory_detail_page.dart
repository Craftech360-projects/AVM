// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/memory/bloc/memory_bloc.dart';
import 'package:friend_private/pages/memory_detail/share.dart';
import 'package:friend_private/pages/memory_detail/widgets.dart';
import 'package:friend_private/features/memories/widgets/category_chip.dart';
import 'package:friend_private/features/memories/widgets/overall_tab.dart';
import 'package:friend_private/features/memories/widgets/tab_bar.dart';
import 'package:friend_private/features/memories/widgets/transcript_tab.dart';
import 'package:friend_private/utils/memories/reprocess.dart';
import 'package:intl/intl.dart';

// class MemoryDetailPage extends StatefulWidget {
//   const MemoryDetailPage({super.key});
//   static const String name = 'memoryDetailPage';
//   @override
//   State<MemoryDetailPage> createState() => _MemoryDetailPageState();
// }

class MemoryDetailPage extends StatefulWidget {
  final MemoryBloc memoryBloc;
  final int memoryAtIndex;

  const MemoryDetailPage({
    super.key,
    required this.memoryBloc, // Add memoryBloc if necessary
    required this.memoryAtIndex, // Add the index of the memory
  });

  static const String name = 'memoryDetailPage';

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Memory selectedMemory;
  //log(selectedMemory);
  TextEditingController titleController = TextEditingController();
  TextEditingController overviewController = TextEditingController();
  PageController pageController = PageController();

  List<bool> pluginResponseExpanded = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedMemory = widget.memoryBloc.state.memories[widget.memoryAtIndex];
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
      // If it's a string, check if it's a bracketed list
      if (category.startsWith('[') && category.endsWith(']')) {
        // Remove brackets and split by comma
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

  // Convert the transcript data to the required format
  List<Map<String, String>> _getFormattedTranscript(Object? transcript) {
    //   log("BBJHB, $transcript"); // Log the original transcript before processing

    if (transcript == null) return [];

    if (transcript is List) {
      List<Map<String, String>> formattedTranscript = transcript.map((item) {
        // Log the keys of the item to check if they are correct
        //    log("Transcript Item: $item");

        // Ensure 'speaker' and 'text' keys are present and are of type String
        final speaker =
            item['speaker']?.toString() ?? ''; // cast to String, fallback to ''
        final text =
            item['text']?.toString() ?? ''; // cast to String, fallback to ''

        // Log the formatted speaker and text
        // log("Formatted Item: speaker=$speaker, text=$text");

        return {
          'speaker': speaker,
          'text': text,
        };
      }).toList();

      // Log the final list after formatting
      //log("Formatted Transcript: $formattedTranscript");

      return formattedTranscript;
    }
    // print("null");
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // log(selectedMemory.toString());
    final categories =
        _getCategories(selectedMemory.structured.target?.category);
    final formattedTranscript =
        _getFormattedTranscript(selectedMemory.transcript);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color(0xFFE6F5FA),
        title: Text(
          selectedMemory.createdAt != null
              ? '${DateFormat('d MMM').format(selectedMemory.createdAt)}   '
                  '${DateFormat('h:mm a').format(selectedMemory.createdAt)}'
              : 'No Date',
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.greyLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showShareBottomSheet(
                context,
                widget.memoryBloc.state.memories[widget.memoryAtIndex],
                setState,
              );
            },
            icon: const Icon(Icons.ios_share, size: 20),
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
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedMemory.createdAt != null
                      ? '${selectedMemory.structured.target?.title}'
                      : "Not title",
                  style: textTheme.labelLarge?.copyWith(fontSize: 20.h),
                ),
                SizedBox(height: 12.h),
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
                SizedBox(height: 32.h),
                //  const SizedBox(height: 32),
                Expanded(
                  child: CustomTabBar(
                    tabs: const [
                      Tab(text: 'Overall'),
                      Tab(text: 'Transcript'),
                    ],
                    children: [
                      OverallTab(
                        target: selectedMemory.structured.target!,

                        //pluginsResponse: selectedMemory.pluginsResponse
                      ),
                      //  TranscriptTab(target: selectedMemory.transcript!),
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
        ],
      ),
    );
  }

  _reProcessMemory(BuildContext context, StateSetter setModalState,
      Memory memory, Function changeLoadingState) async {
    Memory? newMemory = await reProcessMemory(
      context,
      memory,
      () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error while processing memory. Please try again later.'))),
      changeLoadingState,
    );

    pluginResponseExpanded = List.filled(memory.pluginsResponse.length, false);
    overviewController.text = newMemory!.structured.target!.overview;
    titleController.text = newMemory.structured.target!.title;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Memory processed! 🚀',
              style: TextStyle(color: Colors.white))),
    );
    Navigator.pop(context, true);
  }
}
