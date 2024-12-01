import 'package:flutter/material.dart';

import '../../../resources/gen/assets.gen.dart';
import '../../../utilities/constants/text_constants.dart';

enum MainTab {
  home,
  todo,
  upgrade,
  account,
}

extension MainTabExtension on MainTab {
  String getLabel(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return TextConstants.home;
      case MainTab.todo:
        return TextConstants.todo;
      case MainTab.upgrade:
        return TextConstants.upgrade;
      case MainTab.account:
        return TextConstants.account;
    }
  }

  String iconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.home1.path;
      case MainTab.todo:
        return Assets.icons.todo.path;
      case MainTab.upgrade:
        return Assets.icons.star.path;
      case MainTab.account:
        return Assets.icons.account.path;
    }
  }

  String activeIconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.home1.path;
      case MainTab.todo:
        return Assets.icons.todo.path;
      case MainTab.upgrade:
        return Assets.icons.star.path;
      case MainTab.account:
        return Assets.icons.account.path;
    }
  }
}
