import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    super.key,
    required this.children,
    required this.tabs,
  });
  final List<Widget> children;
  final List<Widget> tabs;
  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.h + 8.h),
            color: AppColors.white,
            border: Border.all(
              color: AppColors.commonPink,
              width: 2,
            ),
          ),
          child: SizedBox(
            height: 40.h,
            child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                // padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.grey,
                indicator: BoxDecoration(
                  borderRadius: br12,
                  color: AppColors.black,
                ),
                indicatorWeight: 0,
                labelPadding: EdgeInsets.zero,
                tabs: widget.tabs),
          ),
        ),
        Expanded(
          child:
              TabBarView(controller: _tabController, children: widget.children),
        ),
      ],
    );
  }
}
