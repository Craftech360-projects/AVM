import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core_updated/assets/app_images.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/features/home/presentation/pages/navbar.dart';
import 'package:friend_private/src/features/home/presentation/widgets/widgets.dart';
import 'package:friend_private/src/features/live_transcript/presentation/widgets/battery_indicator.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/memory_shimmer.dart';
import 'package:go_router/go_router.dart';

class TranscriptMemoryPage extends StatefulWidget {
  const TranscriptMemoryPage({
    super.key,
  });
  static const String name = 'transcriptMemoryPage';
  @override
  State<TranscriptMemoryPage> createState() => _TranscriptMemoryPageState();
}

class _TranscriptMemoryPageState extends State<TranscriptMemoryPage> {
  late Future<bool> _showMemoryCards;

  @override
  void initState() {
    super.initState();
    _showMemoryCards = Future.delayed(const Duration(seconds: 2), () => true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE6F5FA),
        leading: const BatteryIndicator(),
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.greyLavender,
            child: CustomIconButton(
              size: 16.h,
              iconPath: AppImages.gearIcon,
              onPressed: () {
                context.pushNamed(SettingPage.name);
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Capture Card
            const CaptureCard(),

            SizedBox(height: 8.h),

            /// Filter
            const Text('Show Discarded'),
            SizedBox(height: 8.h),

            /// Memory Cards
            Expanded(
              child: FutureBuilder<bool>(
                future: _showMemoryCards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => const MemoryShimmer(),
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 4.h),
                    );
                  } else {
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => GestureDetector(
                        //   child: const MemoryCard(),
                        onTap: () {
                          context.pushNamed(MemoryDetailPage.name);
                        },
                      ),
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 4.h),
                    );
                  }
                },
              ),
            ),
            const Center(
              child: CustomNavBar(
                isMemory: true,
                isChat: false,
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
