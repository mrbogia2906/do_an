import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/register/register_state.dart';

import '../../data/repositories/firebase/auth_repository.dart';

class RegisterViewModel extends BaseViewModel<RegisterState> {
  RegisterViewModel({
    required this.ref,
  }) : super(RegisterState());

  Ref ref;

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(
      passwordVisible: !state.passwordVisible,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      confirmPasswordVisible: !state.confirmPasswordVisible,
    );
  }
}
