import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core_updated/assets/app_images.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
    this.onTabChange,
    this.onMemorySearch,
  });
  final bool? isChat;
  final bool? isMemory;
  final Function(String)? onSendMessage;
  final Function(int)? onTabChange; // Add this
  final Function(String)? onMemorySearch; // Add callback for memory search

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late bool isMemoryVisible;
  late bool isChatVisible;
  bool isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start with everything collapsed
    // Add listener for memory search
    _searchController.addListener(() {
      if (widget.onMemorySearch != null && isMemoryVisible) {
        widget.onMemorySearch!(_searchController.text);
      }
    });

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
      if (widget.onTabChange != null) {
        widget.onTabChange!(0); // Switch to the "Search" tab
      }
      // context.goNamed(TranscriptMemoryPage.name);
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
      }
      isChatVisible = true;
      isMemoryVisible = false;
      if (widget.onTabChange != null) {
        widget.onTabChange!(1); // Switch to the "Chat" tab
      }
      // context.goNamed(ChatsPage.name);
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

  void _handleSearchMessage(String query) {
    if (widget.onMemorySearch != null) {
      widget.onMemorySearch!(query); // Trigger the callback with the query
    } else {
      print("its empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      // onTap: () {
      //   if (!isExpanded) {
      //     setState(() {
      //       isExpanded = true;
      //     });
      //   }
      // },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(
            color: AppColors.white,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
          color: AppColors.greyLavender,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AVA Icon
            if (!isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: GestureDetector(
                  onTap: () {
                    if (widget.onTabChange != null) {
                      widget.onTabChange!(0); // Navigate to Tab 0
                    }
                  },
                  child: Image.asset(
                    AppImages.appLogo,
                    height: 13.h,
                  ),
                ),
              ),
            if (!isExpanded)
              VerticalDivider(
                thickness: 0.5.w,
                width: 0,
                color: AppColors.brightGrey,
                endIndent: 8.h,
                indent: 8.h,
              ),
            if (isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: GestureDetector(
                  onTap: () {
                    if (isExpanded) {
                      // Collapse the expanded section
                      setState(() {
                        isExpanded = false;
                        isMemoryVisible = false;
                        isChatVisible = false;
                      });
                    } else {
                      setState(() {
                        isExpanded = true;
                        // isMemoryVisible = false;
                        // isChatVisible = false;
                      });
                      // Navigate to tab 0 when not expanded
                      // if (widget.onTabChange != null) {
                      //   widget.onTabChange!(0); // Navigate to Tab 0
                      // }
                    }
                  },
                  child: Image.asset(
                    AppImages.appLogo,
                    height: 13.h,
                  ),
                ),
              ),

            // Home Icon with collapse functionality
            if (!isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: CustomIconButton(
                  iconPath: AppImages.search,
                  size: 22.h,
                  onPressed: isExpanded ? collapse : toggleSearchVisibility,
                ),
              ),
            if (!isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: CustomIconButton(
                  iconPath: AppImages.message,
                  size: 22.h,
                  onPressed: isExpanded ? collapse : toggleMessageVisibility,
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
                      controller: isChatVisible
                          ? _messageController
                          : (isMemoryVisible ? _searchController : null),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20.h),
                        hintText: isChatVisible
                            ? 'Ask your AVM anything...'
                            : 'Search for memories...',
                        hintStyle: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.greyLight),
                        border: InputBorder.none,
                      ),
                    ),
                    trailing: isChatVisible
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.h),
                            child: Container(
                              color: AppColors.greyLavender,
                              padding: EdgeInsets.all(4.h),
                              child: CustomIconButton(
                                size: 22.h,
                                iconPath: AppImages.send,
                                onPressed: _handleSendMessage,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.h),
                            child: Container(
                              color: AppColors.greyLavender,
                              padding: EdgeInsets.all(4.h),
                              child: CustomIconButton(
                                size: 22.h,
                                iconPath: AppImages.send,
                                onPressed: () => _handleSearchMessage(
                                  _searchController.text.trim(),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

            // Message Icon
            // if (isExpanded && !isChatVisible)
            //   Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 12.w),
            //     child: CustomIconButton(
            //       iconPath: AppImages.message,
            //       size: 22.h,
            //       onPressed: toggleMessageVisibility,
            //     ),
            //   ),
            // if (isExpanded && !isMemoryVisible)
            //   Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 12.w),
            //     child: CustomIconButton(
            //       iconPath: AppImages.home,
            //       size: 22.h,
            //       onPressed: toggleSearchVisibility,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
