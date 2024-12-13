import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/core/constants/constants.dart';
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
            border: Border.all(
                color: AppColors.greyMedium.withOpacity(0.5), width: 1)
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.grey.withOpacity(0.2),
            //     spreadRadius: 8,
            //     blurRadius: 8,
            //     offset: const Offset(2, 2),
            //   ),
            // ],
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
        horizontal: 8.w,
        vertical: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 0.75.sw), // Limit message width
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.purpleDark, // Or your theme's primary color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
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
                        color: AppColors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    h5,
                    // Timestamp
                    if (message?.createdAt != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat('HH:mm').format(message!.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                                fontSize: 11,
                              )),
                          
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
