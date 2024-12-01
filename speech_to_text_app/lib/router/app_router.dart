import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text_app/data/models/api/responses/audio_file/audio_file.dart';

import '../screen/home/home_screen.dart';
import '../screen/account/account_screen.dart';
import '../screen/audio_details/audio_details_screen.dart';
import '../screen/login/login_screen.dart';
import '../screen/main/main_screen.dart';
import '../screen/main/main_state.dart';
import '../screen/register/register_screen.dart';
import '../screen/search/search_screen.dart';
import '../screen/splash/splash_screen.dart';
import '../screen/todo/todo_screen.dart';
import '../screen/upgrade/upgrade_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          path: '/',
          initial: true,
        ),
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
        ),
        AutoRoute(
          page: RegisterRoute.page,
          path: '/register',
        ),
        AutoRoute(
          page: MainRoute.page,
          path: '/main',
          children: [
            AutoRoute(
              page: HomeTabRoute.page,
              path: 'homeTab',
              children: [
                AutoRoute(
                  page: HomeRoute.page,
                  path: '',
                ),
              ],
            ),
            AutoRoute(
              page: UpgradeTabRoute.page,
              path: 'upgradeTab',
              children: [
                AutoRoute(
                  page: UpgradeRoute.page,
                  path: '',
                ),
              ],
            ),
            AutoRoute(
              page: TodoTabRoute.page,
              path: 'todoTab',
              children: [
                AutoRoute(
                  page: TodoRoute.page,
                  path: '',
                ),
              ],
            ),
            AutoRoute(
              page: AccountTabRoute.page,
              path: 'accountTab',
              children: [
                AutoRoute(
                  page: AccountRoute.page,
                  path: '',
                ),
              ],
            ),
          ],
        ),
        AutoRoute(
          page: AudioDetailsRoute.page,
          path: '/audioDetails',
        ),
        AutoRoute(
          page: SearchRoute.page,
          path: '/search',
        ),
      ];
}

@RoutePage(name: 'HomeTabRoute')
class HomeTabPage extends AutoRouter {
  const HomeTabPage({super.key});
}

@RoutePage(name: 'UpgradeTabRoute')
class UpgradeTabPage extends AutoRouter {
  const UpgradeTabPage({super.key});
}

@RoutePage(name: 'AccountTabRoute')
class AccountTabPage extends AutoRouter {
  const AccountTabPage({super.key});
}

@RoutePage(name: 'TodoTabRoute')
class TodoTabPage extends AutoRouter {
  const TodoTabPage({super.key});
}
