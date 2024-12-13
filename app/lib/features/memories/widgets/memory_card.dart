import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/features/chat/widgets/user_message.dart';
import 'package:intl/intl.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 7.h + 12.h,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: br12,
            child: Image.memory(
              memory.memoryImg!,
              height: 100.h,
              width: 100.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/image_placeholder.png',
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),
          w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memory.structured.target?.title ?? 'No Title',
                    // Using memory.title
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
                h10,
                Text(
                  '${DateFormat('d MMM').format(memory.createdAt)} -'
                  ' ${DateFormat('h:mm a').format(memory.createdAt)}',
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
