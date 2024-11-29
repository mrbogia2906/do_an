import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/data/view_model/auth_viewmodel.dart';
import 'package:speech_to_text_app/screen/account/account_state.dart';

class AccountViewModel extends BaseViewModel<AccountState> {
  AccountViewModel({
    required this.ref,
    required this.authViewModel,
  }) : super(AccountState());

  final Ref ref;

  AuthViewModel authViewModel;

  Future<void> initData() async {}

  void setLoaded() {
    state = state.copyWith(loading: !state.loading);
  }

  Future<void> changeUserName(String userName) async {
    try {
      state = state.copyWith(loading: true);
      await authViewModel.changeUserName(userName);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, BuildContext context) async {
    try {
      state = state.copyWith(loading: true);
      await authViewModel.changePassword(oldPassword, newPassword, context);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }
}
