import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../resources/app_text_styles.dart';
import '../../../resources/gen/colors.gen.dart';
import '../models/main_tab.dart';

class TabItem extends ConsumerWidget {
  const TabItem({
    required this.mainTab,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final MainTab mainTab;

  final bool isActive;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isActive ? ColorName.white : ColorName.grayFFFAFAFA,
              width: isActive ? 0 : 0,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              isActive
                  ? mainTab.activeIconPath(context)
                  : mainTab.iconPath(context),
              width: 24,
              height: 24,
              colorFilter: isActive
                  ? const ColorFilter.mode(
                      ColorName.blue,
                      BlendMode.srcIn,
                    )
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              mainTab.getLabel(context),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: isActive
                  ? AppTextStyles.bottomBarItemOn.copyWith(
                      color: ColorName.blue,
                    )
                  : AppTextStyles.bottomBarItem,
            ),
          ],
        ),
      ),
    );
  }
}
