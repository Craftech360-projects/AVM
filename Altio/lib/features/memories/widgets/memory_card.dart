import 'package:altio/backend/database/memory.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final bool isSelected;
  final VoidCallback onSelect;

  const MemoryCard(
      {super.key,
      required this.memory,
      required this.isSelected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: br8,
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: br5,
            child: Image.memory(
              memory.memoryImg!,
              height: 80.h,
              width: 80.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/image_placeholder.png',
                  height: 80.h,
                  width: 80.w,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),
          w8,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memory.structured.target?.title ?? 'No Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.2)),
                h4,
                Text(
                  '${DateFormat('d MMM').format(memory.createdAt)} -'
                  ' ${DateFormat('h:mm a').format(memory.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (isSelected)
            Checkbox(
              activeColor: AppColors.red,
              value: isSelected,
              onChanged: (value) {
                onSelect();
              },
            ),
        ],
      ),
    );
  }
}
