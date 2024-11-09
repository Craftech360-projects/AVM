// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/src/core/common_widget/common_widget.dart';
// import 'package:friend_private/src/core/constant/constant.dart';
// import 'package:friend_private/src/features/memories/presentation/widgets/category_chip.dart';
// import 'package:friend_private/src/features/memories/presentation/widgets/overall_tab.dart';
// import 'package:friend_private/src/features/memories/presentation/widgets/tab_bar.dart';
// import 'package:friend_private/src/features/memories/presentation/widgets/transcript_tab.dart';

// class MemoryDetailPage extends StatefulWidget {
//   const MemoryDetailPage({super.key});
//   static const String name = 'memoryDetailPage';
//   @override
//   State<MemoryDetailPage> createState() => _MemoryDetailPageState();
// }

// class _MemoryDetailPageState extends State<MemoryDetailPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return CustomScaffold(
//       appBar: AppBar(
//         centerTitle: false,
//          backgroundColor: const Color(0xFFE6F5FA),
//         title: Text(
//           '21 Oct 2024 | 09:21 PM',
//           style: textTheme.titleSmall?.copyWith(
//             color: CustomColors.greyLight,
//           ),
//         ),
//         actions: [
//           CustomIconButton(
//             size: 20.h,
//             iconPath: IconImage.share,
//             onPressed: () {},
//           ),
//           SizedBox(width: 8.w),
//           CustomIconButton(
//             size: 20.h,
//             iconPath: IconImage.moreHorizontal,
//             onPressed: () {},
//           ),
//           SizedBox(width: 8.w),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 14.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Embracing the change and growth in Technology',
//               style: textTheme.labelLarge?.copyWith(fontSize: 20.h),
//             ),
//             SizedBox(height: 12.h),
//             Wrap(
//               spacing: 8.0,
//               children: List.generate(
//                 5,
//                 (index) => const CategoryChip(
//                   tagName: 'Technology',
//                 ),
//               ),
//             ),
//             SizedBox(height: 12.h),
//             const Expanded(
//               child: CustomTabBar(
//                 tabs: [
//                   Tab(text: 'Overall'),
//                   Tab(text: 'Transcript'),
//                 ],
//                 children: [
//                   OverallTab(),
//                   TranscriptTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/category_chip.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/overall_tab.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/tab_bar.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/transcript_tab.dart';
import 'package:intl/intl.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';

class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({super.key});
  static const String name = 'memoryDetailPage';
  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy | hh:mm a').format(dateTime);
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MemoryBloc, MemoryState>(
      builder: (context, state) {
        // Get the current memory using the memoryIndex from state
        final currentMemory = state.memories.isNotEmpty &&
                state.memoryIndex < state.memories.length
            ? state.memories[state.memoryIndex]
            : null;

        print('Current Memory: ${currentMemory?.structured.target?.title}');
        print('>>>>>>>>>, ${currentMemory?.structured.target?.overview}');

        if (currentMemory == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories =
            _getCategories(currentMemory.structured.target?.category);

        return CustomScaffold(
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: const Color(0xFFE6F5FA),
            title: Text(
              _formatDateTime(currentMemory.createdAt),
              style: textTheme.titleSmall?.copyWith(
                color: CustomColors.greyLight,
              ),
            ),
            actions: [
              CustomIconButton(
                size: 20.h,
                iconPath: IconImage.share,
                onPressed: () {},
              ),
              SizedBox(width: 8.w),
              CustomIconButton(
                size: 20.h,
                iconPath: IconImage.moreHorizontal,
                onPressed: () {},
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentMemory.structured.target?.title ?? 'Untitled Memory',
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
                SizedBox(height: 12.h),
                Expanded(
                  child: CustomTabBar(
                    tabs: const [
                      Tab(text: 'Overall'),
                      Tab(text: 'Transcript'),
                    ],
                    children: [
                      OverallTab(target: currentMemory.structured.target!),

                      const TranscriptTab(),
                      // OverallTab(memory: currentMemory),
                      // TranscriptTab(memory: currentMemory),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
