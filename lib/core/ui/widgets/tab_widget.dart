import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../constant/app_size/app_size.dart';

class TabBarWidget extends StatefulWidget {
  final int tabLength;
  final bool isScrollable;
  final bool isIndicatorColor;
  final int? initTab;
  final List<Widget> screenList;
  final List<String> screenTitleList;
  final Function(int?)? onChangedIndex;
  const TabBarWidget({
    super.key,
    this.initTab,
    this.onChangedIndex,
    required this.tabLength,
    required this.screenList,
    required this.screenTitleList,
    required this.isScrollable,
    required this.isIndicatorColor,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget>
    with TickerProviderStateMixin {
  int? tabIndex;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabIndex = widget.initTab ?? 0;
    tabController = TabController(
      length: widget.tabLength,
      vsync: this,
      initialIndex: tabIndex ?? 0,
    );

    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.9.sh,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: widget.isScrollable,
            padding: const EdgeInsets.symmetric(horizontal: AppSize.size_16),
            indicatorColor: widget.isIndicatorColor
                ? Colors.pink
                : Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (value) {
              setState(() {
                tabController.index = value;
                tabIndex = value;
              });
              if (widget.onChangedIndex != null) {
                widget.onChangedIndex!(value);
              }
            },
            controller: tabController,
            tabs: List.generate(
              widget.tabLength,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: (tabIndex == index)
                        ? Colors.transparent
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Tab(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        widget.screenTitleList[index],
                        style: AppTextStyle.getBoldStyle(
                          color: (tabIndex == index)
                              ? AppColors.primary
                              : AppColors.grey8E,
                          fontSize: AppSize.size_16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: List.generate(
                widget.screenList.length,
                (index) => widget.screenList[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
