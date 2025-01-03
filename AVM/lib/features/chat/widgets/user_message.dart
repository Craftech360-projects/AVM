import 'package:avm/backend/database/message.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                color: AppColors.greyMedium.withValues(alpha: 0.5), width: 1)),
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
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: size.width * 0.25),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.purpleDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 04.h,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message?.text ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
                h5,
                // Timestamp
                if (message?.createdAt != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(DateFormat('HH:mm').format(message!.createdAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                          fontSize: 11,
                        )),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
