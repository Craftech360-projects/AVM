import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/home/presentation/pages/navbar.dart';
import 'package:friend_private/src/features/home/presentation/widgets/widgets.dart';
import 'package:friend_private/src/features/live_transcript/presentation/widgets/battery_indicator.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/src/features/memories/presentation/widgets/memory_shimmer.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
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
  bool showDiscarded = false;

  @override
  void initState() {
    super.initState();
    // Trigger memory load when page initializes
    context
        .read<MemoryBloc>()
        .add(DisplayedMemory(isNonDiscarded: !showDiscarded));
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
            backgroundColor: CustomColors.greyLavender,
            child: CustomIconButton(
              size: 16.h,
              iconPath: IconImage.gear,
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
            const CaptureCard(),
            SizedBox(height: 8.h),

            // Show Discarded Toggle
            Row(
              children: [
                const Text('Show Discarded'),
                // Switch(
                //   value: showDiscarded,
                //   onChanged: (value) {
                //     setState(() {
                //       showDiscarded = value;
                //     });
                //     context.read<MemoryBloc>().add(
                //           DisplayedMemory(isNonDiscarded: !value),
                //         );
                //   },
                // ),
              ],
            ),
            SizedBox(height: 8.h),

            // Memory Cards with BLoC
            Expanded(
              child: BlocBuilder<MemoryBloc, MemoryState>(
                builder: (context, state) {
                  // Add print statement here to debug state
                  print('Current MemoryState: ${state.status}');
                  print('Number of memories: ${state.memories.length}');
                  print(
                      'Memories list: ${state.memories.map((m) => m.structured.target?.title).toList()}');

                  if (state.status == MemoryStatus.loading) {
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => const MemoryShimmer(),
                      itemCount: state.memories.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 4.h),
                    );
                  } else if (state.status == MemoryStatus.success) {
                    return state.memories.isEmpty
                        ? const Center(
                            child: Text('No memories found'),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final memory = state.memories[index];
                              // Add print for each memory being rendered
                              print(
                                  'Rendering memory at index $index: ${memory.structured.target?.title}');
                              return GestureDetector(
                                child: MemoryCard(
                                  memory: memory,
                                ),
                                onTap: () {
                                  context.read<MemoryBloc>().add(
                                        MemoryIndexChanged(memoryIndex: index),
                                      );
                                  context.pushNamed(MemoryDetailPage.name);
                                },
                              );
                            },
                            itemCount: state.memories.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 4.h),
                          );
                  } else if (state.status == MemoryStatus.failure) {
                    return Center(
                      child: Text('Error: ${state.failure}'),
                    );
                  }
                  return const SizedBox.shrink();
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
