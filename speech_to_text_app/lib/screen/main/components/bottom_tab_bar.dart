import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text_app/resources/gen/colors.gen.dart';
import 'package:speech_to_text_app/screen/main/components/tab_item.dart';
import 'package:speech_to_text_app/screen/main/models/main_tab.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    required this.tabsRouter,
    super.key,
  });

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 60,
      color: Colors.cyan.shade400,
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            child: TabItem(
              mainTab: MainTab.home,
              isActive: tabsRouter.activeIndex == MainTab.home.index,
              onTap: () => tabsRouter.setActiveIndex(MainTab.home.index),
            ),
          ),
          Flexible(
            child: TabItem(
              mainTab: MainTab.favorite,
              isActive: tabsRouter.activeIndex == MainTab.favorite.index,
              onTap: () => tabsRouter.setActiveIndex(MainTab.favorite.index),
            ),
          ),
          const SizedBox(width: 48), // Space for the FloatingActionButton
          Flexible(
            child: TabItem(
              mainTab: MainTab.search,
              isActive: tabsRouter.activeIndex == MainTab.search.index,
              onTap: () => tabsRouter.setActiveIndex(MainTab.search.index),
            ),
          ),
          Flexible(
            child: TabItem(
              mainTab: MainTab.setting,
              isActive: tabsRouter.activeIndex == MainTab.setting.index,
              onTap: () => tabsRouter.setActiveIndex(MainTab.setting.index),
            ),
          ),
        ],
      ),
    );
  }
}
