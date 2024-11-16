// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/src/core/common_widget/common_widget.dart';
// import 'package:friend_private/src/core/constant/constant.dart';
// import 'package:friend_private/src/features/chats/presentation/pages/chats_page.dart';
// import 'package:friend_private/src/features/live_transcript/presentation/pages/transcript_memory_page.dart';
// import 'package:go_router/go_router.dart';

// class CustomNavBar extends StatefulWidget {
//   const CustomNavBar({
//     super.key,
//     this.isChat = false,
//     this.isMemory = false,
//     this.onSendMessage, // Make onSendMessage nullable
//   });
//   final bool? isChat;
//   final bool? isMemory;
//   final Function(String)? onSendMessage; // Nullable callback

//   @override
//   State<CustomNavBar> createState() => _CustomNavBarState();
// }

// class _CustomNavBarState extends State<CustomNavBar> {
//   late bool isMemoryVisible;
//   late bool isChatVisible;
//   final TextEditingController _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     isMemoryVisible = widget.isMemory!;
//     isChatVisible = widget.isChat!;
//   }

//   void toggleSearchVisibility() {
//     setState(() {
//       isMemoryVisible = !isMemoryVisible;
//       context.goNamed(TranscriptMemoryPage.name);
//       isChatVisible = false;
//     });
//   }

//   void toggleMessageVisibility() {
//     setState(() {
//       isChatVisible = !isChatVisible;
//       context.goNamed(ChatsPage.name);
//       isMemoryVisible = false;
//     });
//   }

//   // Function to handle sending a message
//   void _handleSendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty && widget.onSendMessage != null) {
//       widget.onSendMessage!(
//           message); // Use the callback to send message if not null
//       _messageController.clear(); // Clear the text field after sending
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return Container(
//       height: 64.h,
//       padding: EdgeInsets.symmetric(horizontal: 6.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20.h),
//         border: Border.all(
//           color: CustomColors.white,
//           width: 1.w,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             blurRadius: 4,
//             offset: const Offset(0, 5),
//           ),
//         ],
//         color: CustomColors.greyLavender,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // AVA Icon
//           isMemoryVisible || isChatVisible
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12.w),
//                   child: Image.asset(
//                     IconImage.avmLogo,
//                     height: 13.h,
//                   ),
//                 ),
//           isMemoryVisible || isChatVisible
//               ? const SizedBox.shrink()
//               : VerticalDivider(
//                   thickness: 0.5.w,
//                   width: 0,
//                   color: CustomColors.brightGrey,
//                   endIndent: 8.h,
//                   indent: 8.h,
//                 ),

//           // Home Icon
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             child: CustomIconButton(
//               iconPath: IconImage.home,
//               size: 22.h,
//               onPressed: toggleSearchVisibility,
//             ),
//           ),
//           isMemoryVisible || isChatVisible
//               ? Expanded(
//                   child: Visibility(
//                     visible: isMemoryVisible || isChatVisible,
//                     child: Container(
//                       height: 50.h,
//                       padding: EdgeInsets.symmetric(horizontal: 8.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12.h),
//                       ),
//                       child: ListTile(
//                         minVerticalPadding: 0,
//                         contentPadding: EdgeInsets.zero,
//                         title: TextField(
//                           controller: _messageController, // Attach controller
//                           decoration: InputDecoration(
//                             isDense: true,
//                             contentPadding:
//                                 EdgeInsets.symmetric(vertical: 20.h),
//                             hintText: isChatVisible
//                                 ? 'Type here...'
//                                 : 'Search for memories...',
//                             hintStyle: textTheme.bodyMedium
//                                 ?.copyWith(color: CustomColors.greyLight),
//                             border: InputBorder.none,
//                           ),
//                         ),
//                         trailing: isChatVisible
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(8.h),
//                                 child: Container(
//                                   color: CustomColors.greyLavender,
//                                   padding: EdgeInsets.all(4.h),
//                                   child: CustomIconButton(
//                                     size: 22.h,
//                                     iconPath: IconImage.send,
//                                     onPressed:
//                                         _handleSendMessage, // Trigger send
//                                   ),
//                                 ),
//                               )
//                             : null,
//                       ),
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink(),

//           // Message Icon
//           isChatVisible
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12.w),
//                   child: CustomIconButton(
//                     iconPath: IconImage.message,
//                     size: 22.h,
//                     onPressed: toggleMessageVisibility,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose(); // Dispose controller when widget is disposed
//     super.dispose();
//   }
// }

//testing code below, working initial version  is above

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/chats/presentation/pages/chats_page.dart';
import 'package:friend_private/src/features/live_transcript/presentation/pages/transcript_memory_page.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
  });
  final bool? isChat;
  final bool? isMemory;
  final Function(String)? onSendMessage;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late bool isMemoryVisible;
  late bool isChatVisible;
  bool isExpanded = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start with everything collapsed
    isMemoryVisible = false;
    isChatVisible = false;
    isExpanded = false;
  }

  void toggleSearchVisibility() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
      }
      isMemoryVisible = true;
      isChatVisible = false;
      context.goNamed(TranscriptMemoryPage.name);
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
      }
      isChatVisible = true;
      isMemoryVisible = false;
      context.goNamed(ChatsPage.name);
    });
  }

  void collapse() {
    setState(() {
      isExpanded = false;
      isMemoryVisible = false;
      isChatVisible = false;
    });
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        if (!isExpanded) {
          setState(() {
            isExpanded = true;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(
            color: CustomColors.white,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
          color: CustomColors.greyLavender,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AVA Icon
            if (!isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Image.asset(
                  IconImage.avmLogo,
                  height: 13.h,
                ),
              ),
            if (!isExpanded)
              VerticalDivider(
                thickness: 0.5.w,
                width: 0,
                color: CustomColors.brightGrey,
                endIndent: 8.h,
                indent: 8.h,
              ),

            // Home Icon with collapse functionality
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: CustomIconButton(
                iconPath: IconImage.home,
                size: 22.h,
                onPressed: isExpanded ? collapse : toggleSearchVisibility,
              ),
            ),

            // Expanded search/chat section
            if (isExpanded && (isMemoryVisible || isChatVisible))
              Expanded(
                child: Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: ListTile(
                    minVerticalPadding: 0,
                    contentPadding: EdgeInsets.zero,
                    title: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20.h),
                        hintText: isChatVisible
                            ? 'Type here...'
                            : 'Search for memories...',
                        hintStyle: textTheme.bodyMedium
                            ?.copyWith(color: CustomColors.greyLight),
                        border: InputBorder.none,
                      ),
                    ),
                    trailing: isChatVisible
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.h),
                            child: Container(
                              color: CustomColors.greyLavender,
                              padding: EdgeInsets.all(4.h),
                              child: CustomIconButton(
                                size: 22.h,
                                iconPath: IconImage.send,
                                onPressed: _handleSendMessage,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),

            // Message Icon
            if (!isChatVisible)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: CustomIconButton(
                  iconPath: IconImage.message,
                  size: 22.h,
                  onPressed: toggleMessageVisibility,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
