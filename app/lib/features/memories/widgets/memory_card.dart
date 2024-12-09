import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/src/common_widget/card.dart';
import 'package:intl/intl.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 30.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.h),
            child: Image.memory(
              memory.memoryImg!,
              height: 100.h,
              width: 100.w,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/image_placeholder.png', // Replace with your dummy image path
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memory.structured.target?.title ?? 'No Title',
                    // Using memory.title
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12.h),
                Text(
                  '${DateFormat('d MMM').format(memory.createdAt)}  '
                  '   ${DateFormat('h:mm a').format(memory.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
