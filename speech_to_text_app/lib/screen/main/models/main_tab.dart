import 'package:flutter/material.dart';

import '../../../resources/gen/assets.gen.dart';
import '../../../utilities/constants/text_constants.dart';

enum MainTab {
  home,
  todo,
  search,
  account,
}

extension MainTabExtension on MainTab {
  String getLabel(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return TextConstants.home;
      case MainTab.todo:
        return TextConstants.todo;
      case MainTab.search:
        return TextConstants.search;
      case MainTab.account:
        return TextConstants.account;
    }
  }

  String iconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.home.path;
      case MainTab.todo:
        return Assets.icons.favorite.path;
      case MainTab.search:
        return Assets.icons.search.path;
      case MainTab.account:
        return Assets.icons.profile.path;
    }
  }

  String activeIconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.homeOn.path;
      case MainTab.todo:
        return Assets.icons.favoriteOn.path;
      case MainTab.search:
        return Assets.icons.searchOn.path;
      case MainTab.account:
        return Assets.icons.profileOn.path;
    }
  }
}
