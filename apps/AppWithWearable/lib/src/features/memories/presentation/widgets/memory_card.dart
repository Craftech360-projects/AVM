// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/src/core/common_widget/card.dart';
// import 'package:friend_private/src/core/constant/custom_colors.dart';
// import 'package:friend_private/src/core/constant/icon_image.dart';

// class MemoryCard extends StatelessWidget {
//   const MemoryCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return CustomCard(
//       borderRadius: 30.h + 12.h,
//       padding: EdgeInsets.all(12.h),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(30.h),
//             child: Image.asset(
//               IconImage.imagePlaceholder,
//               height: 100.h,
//               width: 100.w,
//               fit: BoxFit.fitHeight,
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Expanded(
//               child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Embracing the change and growth in Technology'
//                 'Embracing the change and growth in Technology',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style:
//                     textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400),
//               ),
//               SizedBox(height: 12.h),
//               Text(
//                 '21 Oct 2024 | 09:21 PM',
//                 style: textTheme.bodySmall?.copyWith(
//                   color: CustomColors.greyLight,
//                 ),
//               ),
//             ],
//           ))
//         ],
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/src/core/common_widget/card.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';
import 'package:friend_private/src/core/constant/icon_image.dart';
import 'package:intl/intl.dart'; // Import the intl package
// Make sure you import the Memory class

class MemoryCard extends StatelessWidget {
  final Memory memory; // Accept the memory object in the constructor

  const MemoryCard(
      {super.key,
      required this.memory}); // Constructor updated to accept Memory object

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      borderRadius: 30.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.h),
            child: Image.memory(
              memory.memoryImg ??
                  Uint8List(0), // Display image if available, fallback to empty
              height: 100.h,
              width: 100.w,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the memory title

                Text(
                  memory.structured.target?.title ??
                      'Untitled Memory', // Safely show title
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 12.h),

                // SizedBox(height: 12.h),
                // Display the formatted date of the memory
                Text(
                  formatDate(memory.createdAt), // Function to format the date

                  style: textTheme.bodySmall
                      ?.copyWith(color: CustomColors.greyLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format the date

// Helper function to format the date
  String formatDate(DateTime? date) {
    if (date == null) return 'No Date';

    // Use the DateFormat class from intl package to format the date
    final formattedDate = DateFormat('d MMM yyyy | hh:mm a').format(date);
    return formattedDate;
  }
}
