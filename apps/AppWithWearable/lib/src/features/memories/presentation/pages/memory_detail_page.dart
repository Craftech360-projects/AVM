import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/category_chip.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/overall_tab.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/tab_bar.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/transcript_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      appBar: AppBar(
        centerTitle: false,
         backgroundColor: const Color(0xFFE6F5FA),
        title: Text(
          '21 Oct 2024 | 09:21 PM',
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
              'Embracing the change and growth in Technology',
              style: textTheme.labelLarge?.copyWith(fontSize: 20.h),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.0,
              children: List.generate(
                5,
                (index) => const CategoryChip(
                  tagName: 'Technology',
                ),
              ),
            ),
            SizedBox(height: 12.h),
            const Expanded(
              child: CustomTabBar(
                tabs: [
                  Tab(text: 'Overall'),
                  Tab(text: 'Transcript'),
                ],
                children: [
                  OverallTab(),
                  TranscriptTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
