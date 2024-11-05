import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/account/account_state.dart';

class AccountViewModel extends BaseViewModel<AccountState> {
  AccountViewModel({
    required this.ref,
  }) : super(AccountState());

  final Ref ref;

  Future<void> initData() async {}

  void setLoaded() {
    state = state.copyWith(loading: !state.loading);
  }
}
