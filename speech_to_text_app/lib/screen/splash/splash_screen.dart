import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/screen/splash/splash_state.dart';

import '../../../../components/base_view/base_view.dart';
import '../../data/models/api/responses/user/user_model.dart';
import '../../data/providers_gen/current_user_notifier.dart';
import '../../data/view_model/auth_viewmodel.dart';
import '../../resources/gen/assets.gen.dart';
import '../../router/app_router.dart';
import 'splash_view_model.dart';

final _provider =
    StateNotifierProvider.autoDispose<SplashViewModel, SplashState>(
  (ref) => SplashViewModel(),
);

/// Screen code: A_01
@RoutePage()
class SplashScreen extends BaseView {
  const SplashScreen({super.key});

  @override
  BaseViewState<SplashScreen, SplashViewModel> createState() =>
      _SplashViewState();
}

class _SplashViewState extends BaseViewState<SplashScreen, SplashViewModel> {
  bool _hasNavigated = false;
  SplashState get state => ref.watch(_provider);

  UserModel? get currentUser => ref.watch(currentUserNotifierProvider);

  @override
  void initState() {
    super.initState();

    // Thêm độ trễ 2 giây trước khi khởi tạo ứng dụng
    Future.delayed(const Duration(seconds: 2), () async {
      if (currentUser != null) {
        context.router.replace(const MainRoute());
      } else {
        context.router.replace(const LoginRoute());
      }
      // if (currentUser != null) {
      //   await context.router.replace(const MainRoute());
      // } else {
      //   await context.router.replace(const LoginRoute());
      // }
    });
  }

  void _initializeApp() async {
    await ref.read(authViewModelProvider.notifier).initSharedPreferences();
    await ref.read(authViewModelProvider.notifier).getData();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    print('currentUser: $currentUser');
    // ref.listen<UserModel?>(
    //   currentUserNotifierProvider,
    //   (previous, next) {
    //     if (_hasNavigated) return;

    //     if (next != null) {
    //       _hasNavigated = true;
    //       // Điều hướng đến HomeRoute
    //       context.router.replace(const HomeRoute());
    //     } else {
    //       _hasNavigated = true;
    //       // Điều hướng đến LoginRoute
    //       context.router.replace(const LoginRoute());
    //     }
    //   },
    // );
    // final currentUser = ref.watch(currentUserNotifierProvider);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   if (_hasNavigated) return;

    //   _hasNavigated = true;

    //   if (currentUser != null) {
    //     context.router.replace(const HomeRoute());
    //   } else {
    //     context.router.replace(const LoginRoute());
    //   }
    // });

    return Center(
      child: Assets.images.logo2.image(
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  SplashViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => SplashRoute.name;
}
