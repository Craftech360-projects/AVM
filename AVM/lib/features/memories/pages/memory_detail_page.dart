// ignore_for_file: unnecessary_null_comparison, duplicate_ignore

import 'package:avm/backend/database/geolocation.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/memories/widgets/category_chip.dart';
import 'package:avm/features/memories/widgets/overall_tab.dart';
import 'package:avm/features/memories/widgets/tab_bar.dart';
import 'package:avm/features/memories/widgets/transcript_tab.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/objectbox.g.dart';
import 'package:avm/pages/memory_detail/share.dart';
import 'package:avm/pages/memory_detail/widgets.dart';
import 'package:avm/utils/memories/reprocess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // Add this line to print geolocation data
    printGeolocationData(selectedMemory.geolocation);
  }

  void printGeolocationData(ToOne<Geolocation> geolocation) {
    if (geolocation.target != null) {
      // Add more fields if necessary
    } else {
    }
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
    _getFormattedTranscript(selectedMemory.transcript);
    // Remove the old print statement
    // print(selectedMemory.geolocation);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppColors.white,
        title: Text(
            // ignore: unnecessary_null_comparison
            selectedMemory.createdAt != null
                ? '${DateFormat('d MMM').format(selectedMemory.createdAt)} -'
                    ' ${DateFormat('h:mm a').format(selectedMemory.createdAt)}'
                : 'No Date',
            style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            onPressed: () {
              showShareBottomSheet(
                context,
                widget.memoryBloc.state.memories[widget.memoryAtIndex],
                setState,
              );
            },
            icon: const Icon(Icons.ios_share, size: 24),
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
            icon: const Icon(Icons.more_vert_rounded, size: 25),
          ),
          w10,
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
            h5,
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
            h20,
            Expanded(
              child: CustomTabBar(
                tabs: const [
                  Tab(text: 'Overall'),
                  Tab(text: 'Transcript'),
                ],
                children: [
                  OverallTab(
                    target: selectedMemory.structured.target!,
                    geolocation: selectedMemory.geolocation.target, // Pass geolocation
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
