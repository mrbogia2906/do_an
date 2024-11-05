import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/register/register_state.dart';

import '../../data/repositories/firebase/auth_repository.dart';

class RegisterViewModel extends BaseViewModel<RegisterState> {
  RegisterViewModel({
    required this.ref,
    required this.authRepository,
  }) : super(RegisterState());

  Ref ref;

  AuthRepository authRepository;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true);
    try {
      await authRepository.register(email, password);
      state = state.copyWith(authenticated: true, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false);
      rethrow;
    }
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
