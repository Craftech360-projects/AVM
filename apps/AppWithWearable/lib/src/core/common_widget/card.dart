import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';
import 'package:friend_private/src/features/chats/presentation/widgets/avm_logo.dart';
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
      // child: Card(
      //   color: CustomColors.white,
      //   elevation: 5,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(borderRadius),
      //   ),
      //   child: Padding(
      //     padding: padding,
      //     child: child,
      //   ),
      // ),

      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 8, // Spread radius
              blurRadius: 8, // Blur radius
              offset: Offset(2, 2), // Shadow position (x, y)
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

// Or the more customizable version:
// class UserCard extends StatelessWidget {
//   final Message? message;

//   const UserCard({
//     super.key,
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: 16.w), // Add padding for the entire row
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end, // Align content to the right
//         children: [
//           Flexible(
//             // Wrap in Flexible to handle long text
//             child: CustomCard(
//               borderRadius: 16.w,
//               padding: EdgeInsets.symmetric(horizontal: 12.w),
//               child: ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: Text(
//                   message?.text ?? '',
//                   style: textTheme.bodyMedium,
//                   textAlign: TextAlign.right, // Align text to the right
//                 ),
//                 subtitle: message?.createdAt != null
//                     ? Text(
//                         message!.createdAt.toString(),
//                         style: textTheme.bodySmall?.copyWith(
//                           color: CustomColors.greyLight,
//                         ),
//                         textAlign:
//                             TextAlign.right, // Align timestamp to the right
//                       )
//                     : null,
//               ),
//             ),
//           ),
//           SizedBox(width: 8.w),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Image.network(
//               'https://thumbs.dreamstime.com/b/person-gray-photo-placeholder-woman-t-shirt-white-background-131683043.jpg',
//               height: 40,
//               width: 40,
//             ),
//           ),
//           SizedBox(width: 8.h),
//           //const AvmLogo(), // Logo at the end
//         ],
//       ),
//     );
//   }
// }

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
            8.h, // Added vertical padding for better spacing between messages
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
                  color:
                      CustomColors.purpleDark, // Or your theme's primary color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(
                        5.r), // Smaller radius for chat bubble effect
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
                    // Row(
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsetsDirectional.fromSTEB(
                    //           0.0, 0.0, 4.0, 0.0),
                    //       child: Icon(
                    //         Icons.content_copy,
                    //         color: Theme.of(context).textTheme.bodySmall!.color,
                    //         size: 10.0,
                    //       ),
                    //     ),
                    //     Text(
                    //       'Copy response',
                    //       style: Theme.of(context).textTheme.bodySmall,
                    //     ),
                    //   ],
                    // ),
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
