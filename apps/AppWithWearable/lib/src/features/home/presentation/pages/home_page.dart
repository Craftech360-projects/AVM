import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/home/presentation/widgets/widgets.dart';
import 'package:friend_private/src/features/live_transcript/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/memory_shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor: Colors.transparent,
        actions: [
          CircleAvatar(
            backgroundColor: CustomColors.greyOffWhite,
            child: CustomIconButton(
              size: 16.h,
              iconPath: IconImage.gear,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BleConnectionPage()));
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
                        child: const MemoryCard(),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MemoryDetailPage()));
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
          ],
        ),
      ),
    );
  }
}
