import 'package:capsoul/core/assets/app_images.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/src/common_widget/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final Function(int)? onTabChange;
  final Function(String)? onMemorySearch;

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
    _searchController.addListener(_onSearchChanged);
    isMemoryVisible = false;
    isChatVisible = false;
    isExpanded = false;
  }

  void _onSearchChanged() {
    if (widget.onMemorySearch != null && isMemoryVisible) {
      widget.onMemorySearch!(_searchController.text);
    }
  }

  void toggleSearchVisibility() {
    setState(() {
      isExpanded = true;
      isMemoryVisible = true;
      isChatVisible = false;
      widget.onTabChange?.call(0);
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      isExpanded = true;
      isChatVisible = true;
      isMemoryVisible = false;
      widget.onTabChange?.call(1);
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
    if (message.isNotEmpty) {
      widget.onSendMessage?.call(message);
      _messageController.clear();
    }
  }

  void _handleSearchMessage(String query) {
    widget.onMemorySearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 12.0),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: br20,
            border: Border.all(
              color: AppColors.white,
              width: 1.w,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(118, 122, 122, 122),
                blurRadius: 4,
                offset: Offset(0, 5),
              ),
            ],
            color: AppColors.commonPink,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isExpanded) _buildLogo(),
              if (!isExpanded) _buildVerticalDivider(),
              if (isExpanded) _buildHomeBtn(),
              if (!isExpanded) _buildSearchButton(),
              if (!isExpanded) _buildMessageButton(),
              if (isExpanded && (isMemoryVisible || isChatVisible))
                _buildExpandedSection(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: GestureDetector(
        onTap: () => widget.onTabChange?.call(0),
        child: Image.asset(
          AppImages.appLogo,
          height: 16.h,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return VerticalDivider(
      thickness: 0.5.w,
      width: 0,
      color: AppColors.brightGrey,
      endIndent: 8.h,
      indent: 8.h,
    );
  }

  Widget _buildHomeBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          if (widget.onTabChange != null) {
            widget.onTabChange!(0);
            collapse();
          }
        },
        child: Image.asset(
          AppImages.home,
          width: 24.h,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: CustomIconButton(
        iconPath: AppImages.search,
        size: 24.h,
        onPressed: toggleSearchVisibility,
      ),
    );
  }

  Widget _buildMessageButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: CustomIconButton(
        iconPath: AppImages.message,
        size: 24.h,
        onPressed: toggleMessageVisibility,
      ),
    );
  }

  Widget _buildExpandedSection(TextTheme textTheme) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: br12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 14, height: 1.2),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 3,
                minLines: 1,
                controller: isChatVisible
                    ? _messageController
                    : (isMemoryVisible ? _searchController : null),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  isDense: true,
                  hintText: isChatVisible
                      ? 'Ask Capsoul anything...'
                      : 'Search for memories...',
                  hintStyle: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.greyLight),
                  border: InputBorder.none,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: br8,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle, color: AppColors.white),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: CustomIconButton(
                  size: 24.h,
                  iconPath: AppImages.send,
                  onPressed: isChatVisible
                      ? _handleSendMessage
                      : () => _handleSearchMessage(
                            _searchController.text.trim(),
                          ),
                ),
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
    _searchController.dispose();
    super.dispose();
  }
}
