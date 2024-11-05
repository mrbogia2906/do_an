import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/upgrade/upgrade_state.dart';
import 'package:speech_to_text_app/screen/upgrade/upgrade_view_model.dart';

import '../../router/app_router.dart';

final _provider =
    StateNotifierProvider.autoDispose<UpgradeViewModel, UpgradeState>(
  (ref) => UpgradeViewModel(
    ref: ref,
  ),
);

@RoutePage()
class UpgradeScreen extends BaseView {
  const UpgradeScreen({super.key});

  @override
  BaseViewState<UpgradeScreen, UpgradeViewModel> createState() =>
      _UpgradeViewState();
}

class _UpgradeViewState extends BaseViewState<UpgradeScreen, UpgradeViewModel> {
  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return Container();
  }

  @override
  UpgradeViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => UpgradeRoute.name;

  UpgradeState get state => ref.watch(_provider);

  LoadingStateViewModel get loading => ref.read(loadingStateProvider.notifier);

  Future<void> _onInitData() async {
    Object? error;

    await loading.whileLoading(context, () async {
      try {
        await viewModel.initData();
      } catch (e) {
        error = e;
      }
    });

    if (error != null) {
      handleError(error!);
    }
  }
}
