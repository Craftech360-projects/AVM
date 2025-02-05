import 'dart:async';

import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/chat/presentation/chat_screen.dart';
import 'package:altio/main.dart';
import 'package:altio/pages/home/page.dart';
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
          margin: EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: br15,
            border: Border.all(
              color: AppColors.white,
              width: 2,
            ),
            color: AppColors.commonPink,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              // if (!navbarState.isExpanded) _buildVerticalDivider(),
              if (!navbarState.isExpanded) _buildSearchButton(),
              if (!navbarState.isExpanded) _buildMessageButton(),
              if (navbarState.isExpanded) _buildExpandedSection(navbarState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomIconButton(
          iconPath: AppImages.memories,
          size: 26,
          onPressed: () {
            Provider.of<NavbarState>(context, listen: false).collapse();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePageWrapper()));
          }),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomIconButton(
        iconPath: AppImages.search,
        size: 26,
        onPressed: toggleSearchVisibility,
      ),
    );
  }

  Widget _buildMessageButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomIconButton(
        iconPath: AppImages.message,
        size: 26,
        onPressed: toggleMessageVisibility,
      ),
    );
  }

  Widget _buildExpandedSection(navbarState) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 6, right: 6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
