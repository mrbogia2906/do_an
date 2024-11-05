import 'package:flutter/material.dart';

import '../../../resources/gen/assets.gen.dart';
import '../../../utilities/constants/text_constants.dart';

enum MainTab {
  home,
  favorite,
  search,
  setting,
}

extension MainTabExtension on MainTab {
  String getLabel(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return TextConstants.home;
      case MainTab.favorite:
        return TextConstants.favorite;
      case MainTab.search:
        return TextConstants.search;
      case MainTab.setting:
        return TextConstants.setting;
    }
  }

  String iconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.home.path;
      case MainTab.favorite:
        return Assets.icons.favorite.path;
      case MainTab.search:
        return Assets.icons.search.path;
      case MainTab.setting:
        return Assets.icons.profile.path;
    }
  }

  String activeIconPath(BuildContext context) {
    switch (this) {
      case MainTab.home:
        return Assets.icons.homeOn.path;
      case MainTab.favorite:
        return Assets.icons.favoriteOn.path;
      case MainTab.search:
        return Assets.icons.searchOn.path;
      case MainTab.setting:
        return Assets.icons.profileOn.path;
    }
  }
}
