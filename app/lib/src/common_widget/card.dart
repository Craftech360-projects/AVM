import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.borderRadius,
    required this.padding,
    this.onPressed,
    this.child,
  });
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 8, // Spread radius
              blurRadius: 8, // Blur radius
              offset: const Offset(2, 2), // Shadow position (x, y)
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Message? message;

  const UserCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical:
            8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 0.75.sw), // Limit message width
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.purpleDark, // Or your theme's primary color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(
                        5.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Message text
                    Text(
                      message?.text ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 4.h),
                    // Timestamp
                    if (message?.createdAt != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm')
                                .format(message!.createdAt), // Format time
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          // Icon(
                          //   Icons.done_all, // Or your preferred status icon
                          //   size: 14.sp,
                          //   color: Colors.white70,
                          // ),
                        ],
                      ),
                    ],
                    
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // User Avatar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
                height: 40.h,
                width: 40.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 40.h,
                    width: 40.w,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 24.sp,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
