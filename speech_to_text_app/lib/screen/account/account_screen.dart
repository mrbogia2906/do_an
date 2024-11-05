import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/account/account_state.dart';
import 'package:speech_to_text_app/screen/account/account_view_model.dart';

import '../../router/app_router.dart';

final accountProvider =
    StateNotifierProvider.autoDispose<AccountViewModel, AccountState>(
  (ref) => AccountViewModel(
    ref: ref,
  ),
);

@RoutePage()
class AccountScreen extends BaseView {
  const AccountScreen({super.key});

  @override
  BaseViewState<AccountScreen, AccountViewModel> createState() =>
      _AccountViewState();
}

class _AccountViewState extends BaseViewState<AccountScreen, AccountViewModel> {
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
    return Container(
      child: ElevatedButton(
        onPressed: () {
          viewModel.setLoaded();
        },
        child: Text('Set Loaded'),
      ),
    );
  }

  @override
  AccountViewModel get viewModel => ref.read(accountProvider.notifier);

  @override
  String get screenName => AccountRoute.name;

  AccountState get state => ref.watch(accountProvider);

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
