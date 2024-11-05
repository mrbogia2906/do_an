import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/login/login_state.dart';

import '../../data/repositories/firebase/auth_repository.dart';

class LoginViewModel extends BaseViewModel<LoginState> {
  LoginViewModel({
    required this.ref,
    required this.authRepository,
  }) : super(LoginState());

  final Ref ref;
  final AuthRepository authRepository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true);
    try {
      await authRepository.login(email, password);
      state = state.copyWith(authenticated: true, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }
}
