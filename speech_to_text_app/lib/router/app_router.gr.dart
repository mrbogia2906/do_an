// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AccountRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccountScreen(),
      );
    },
    AccountTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccountTabPage(),
      );
    },
    AudioDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<AudioDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AudioDetailsScreen(
          key: args.key,
          entry: args.entry,
          audioFile: args.audioFile,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    HomeTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeTabPage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainScreen(),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TodoRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TodoScreen(),
      );
    },
    TodoTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TodoTabPage(),
      );
    },
    UpgradeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UpgradeScreen(),
      );
    },
    UpgradeTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UpgradeTabPage(),
      );
    },
  };
}

/// generated route for
/// [AccountScreen]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
      : super(
          AccountRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AccountTabPage]
class AccountTabRoute extends PageRouteInfo<void> {
  const AccountTabRoute({List<PageRouteInfo>? children})
      : super(
          AccountTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AudioDetailsScreen]
class AudioDetailsRoute extends PageRouteInfo<AudioDetailsRouteArgs> {
  AudioDetailsRoute({
    Key? key,
    required TranscriptionEntry entry,
    required AudioFile audioFile,
    List<PageRouteInfo>? children,
  }) : super(
          AudioDetailsRoute.name,
          args: AudioDetailsRouteArgs(
            key: key,
            entry: entry,
            audioFile: audioFile,
          ),
          initialChildren: children,
        );

  static const String name = 'AudioDetailsRoute';

  static const PageInfo<AudioDetailsRouteArgs> page =
      PageInfo<AudioDetailsRouteArgs>(name);
}

class AudioDetailsRouteArgs {
  const AudioDetailsRouteArgs({
    this.key,
    required this.entry,
    required this.audioFile,
  });

  final Key? key;

  final TranscriptionEntry entry;

  final AudioFile audioFile;

  @override
  String toString() {
    return 'AudioDetailsRouteArgs{key: $key, entry: $entry, audioFile: $audioFile}';
  }
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeTabPage]
class HomeTabRoute extends PageRouteInfo<void> {
  const HomeTabRoute({List<PageRouteInfo>? children})
      : super(
          HomeTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TodoScreen]
class TodoRoute extends PageRouteInfo<void> {
  const TodoRoute({List<PageRouteInfo>? children})
      : super(
          TodoRoute.name,
          initialChildren: children,
        );

  static const String name = 'TodoRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TodoTabPage]
class TodoTabRoute extends PageRouteInfo<void> {
  const TodoTabRoute({List<PageRouteInfo>? children})
      : super(
          TodoTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'TodoTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UpgradeScreen]
class UpgradeRoute extends PageRouteInfo<void> {
  const UpgradeRoute({List<PageRouteInfo>? children})
      : super(
          UpgradeRoute.name,
          initialChildren: children,
        );

  static const String name = 'UpgradeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UpgradeTabPage]
class UpgradeTabRoute extends PageRouteInfo<void> {
  const UpgradeTabRoute({List<PageRouteInfo>? children})
      : super(
          UpgradeTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'UpgradeTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
