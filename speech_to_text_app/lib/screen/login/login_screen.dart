import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/data/view_model/auth_viewmodel.dart';
import 'package:speech_to_text_app/resources/app_text_styles.dart';
import 'package:speech_to_text_app/screen/login/login_state.dart';
import 'package:speech_to_text_app/screen/login/login_view_model.dart';
import 'package:speech_to_text_app/utilities/constants/text_constants.dart';

import '../../components/loading/container_with_loading.dart';
import '../../components/text_field/common_text_form_field.dart';
import '../../data/providers/auth_repository_provider.dart';
import '../../router/app_router.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(
    ref: ref,
  ),
);

@RoutePage()
class LoginScreen extends BaseView {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseViewState<LoginScreen, LoginViewModel> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthViewModel get authViewModel => ref.read(authViewModelProvider.notifier);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    const minPasswordLengthRequired = 6;
    return ContainerWithLoading(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TextConstants.getStart,
                  style: AppTextStyles.s38w700,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CommonTextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: TextConstants.email,
                          validator: (value) {
                            return value != null &&
                                    !EmailValidator.validate(value)
                                ? TextConstants.warningEmail
                                : null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CommonTextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          hintText: TextConstants.password,
                          validator: (value) {
                            return value != null &&
                                    value.length < minPasswordLengthRequired
                                ? TextConstants.warningPassword
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                viewModel.setEmail(_emailController.text);
                                viewModel.setPassword(_passwordController.text);
                                await onLoading(() async {
                                  await authViewModel.loginUser(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                });
                                final loginState =
                                    ref.read(authViewModelProvider);
                                loginState.when(
                                  data: (user) {
                                    context.router.replace(const HomeRoute());
                                  },
                                  error: (error, stackTrace) {
                                    handleError(error);
                                  },
                                  loading: () {
                                    // Bạn có thể hiển thị một loading indicator nếu cần
                                  },
                                );
                              }
                            },
                            child: const Text(TextConstants.signIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(TextConstants.dontHaveAccount),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context.router.replace(const RegisterRoute());
                  },
                  child: const Text(TextConstants.signUp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  String get screenName => LoginRoute.name;

  @override
  LoginViewModel get viewModel => ref.read(loginProvider.notifier);
}
