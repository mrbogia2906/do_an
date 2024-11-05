import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_state.freezed.dart';

@freezed
class AccountState with _$AccountState {
  factory AccountState({
    @Default(true) bool loading,
  }) = _AccountState;

  const AccountState._();
}
