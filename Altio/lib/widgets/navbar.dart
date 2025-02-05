import 'dart:async';

import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/chat/presentation/chat_screen.dart';
import 'package:altio/main.dart';
import 'package:altio/src/common_widget/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
    this.onMemorySearch,
    this.isUserMessageSent = false,
    this.hintText,
    this.onBackBtnPressed,
  });

  final bool? isChat;
  final bool? isMemory;
  final bool isUserMessageSent;
  final Function(String)? onSendMessage;
  final Function(String)? onMemorySearch;
  final String? hintText;
  final VoidCallback? onBackBtnPressed;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode chatTextFieldFocusNode = FocusNode();
  final FocusNode searchTextFieldFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (widget.onMemorySearch != null) {
        widget.onMemorySearch!(_searchController.text.trim());
      }
    });
  }

  void toggleSearchVisibility() {
    Provider.of<NavbarState>(context, listen: false).expand();
    Provider.of<NavbarState>(context, listen: false).setChatVisibility(false);
    Provider.of<NavbarState>(context, listen: false).setMemoryVisibility(true);

    setState(() {
      searchTextFieldFocusNode.requestFocus();
    });
  }

  void toggleMessageVisibility() {
    Provider.of<NavbarState>(context, listen: false).setChatVisibility(true);
    Provider.of<NavbarState>(context, listen: false).setMemoryVisibility(false);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
          textFieldFocusNode: chatTextFieldFocusNode,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: fadeInAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void collapse() {
    setState(() {
      Provider.of<NavbarState>(context, listen: false).collapse();
      FocusScope.of(context).unfocus();
    });
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage?.call(message);
      _messageController.clear();
      FocusScope.of(context).unfocus();
    } else {
      null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navbarState = Provider.of<NavbarState>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.020,
      ),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: br15,
            border: Border.all(
              color: AppColors.white,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(118, 122, 122, 122),
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
            color: AppColors.commonPink,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              if (!navbarState.isExpanded) _buildVerticalDivider(),
              if (!navbarState.isExpanded) _buildSearchButton(),
              if (!navbarState.isExpanded) _buildMessageButton(),
              if (navbarState.isExpanded) _buildExpandedSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: () async {
          if (widget.onBackBtnPressed != null) {
            widget.onBackBtnPressed!();
          } else {
            Provider.of<NavbarState>(context, listen: false).collapse();
          }
        },
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

  Widget _buildExpandedSection() {
    final navbarState = Provider.of<NavbarState>(context);

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: br10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 14, letterSpacing: 0),
                focusNode: navbarState.isChatVisible
                    ? chatTextFieldFocusNode
                    : searchTextFieldFocusNode,
                controller: navbarState.isChatVisible
                    ? _messageController
                    : (navbarState.isMemoryVisible ? _searchController : null),
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 14),
                  hintText: navbarState.isChatVisible
                      ? widget.hintText ?? 'Type a message...'
                      : (navbarState.isMemoryVisible
                          ? 'Search memories...'
                          : ''),
                  border: InputBorder.none,
                ),
              ),
            ),
            navbarState.isChatVisible
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: widget.isUserMessageSent
                        ? TypingIndicator(
                            dotHeight: 6,
                            dotWidth: 6,
                          )
                        : InkWell(
                            onTap: navbarState.isChatVisible
                                ? _handleSendMessage
                                : null,
                            child: Icon(
                              Icons.send_rounded,
                              size: 32.w,
                              color: AppColors.purpleDark,
                            ),
                          ),
                  )
                : (navbarState.isMemoryVisible
                    ? Icon(
                        Icons.cancel_outlined,
                        size: 28.w,
                      )
                    : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    chatTextFieldFocusNode.dispose();
    searchTextFieldFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
