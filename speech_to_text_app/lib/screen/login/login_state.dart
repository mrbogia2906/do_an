import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  factory LoginState({
    @Default(false) bool authenticated,
    @Default(false) bool loading,
  }) = _LoginState;

  const LoginState._();
}
