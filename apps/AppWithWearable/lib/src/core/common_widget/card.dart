import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';
import 'package:friend_private/src/features/chats/presentation/widgets/avm_logo.dart';

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
      child: Card(
        color: const Color.fromARGB(255, 217, 217, 218),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// Or the more customizable version:
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
          horizontal: 16.w), // Add padding for the entire row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align content to the right
        children: [
          Flexible(
            // Wrap in Flexible to handle long text
            child: CustomCard(
              borderRadius: 16.w,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  message?.text ?? '',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.right, // Align text to the right
                ),
                // subtitle: message?.createdAt != null
                //     ? Text(
                //         message!.createdAt.toString(),
                //         style: textTheme.bodySmall?.copyWith(
                //           color: CustomColors.greyLight,
                //         ),
                //         textAlign:
                //             TextAlign.right, // Align timestamp to the right
                //       )
                //     : null,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          //const AvmLogo(), // Logo at the end
        ],
      ),
    );
  }
}
