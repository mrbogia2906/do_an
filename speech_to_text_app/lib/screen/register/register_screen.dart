import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/resources/app_text_styles.dart';
import 'package:speech_to_text_app/screen/register/register_state.dart';
import 'package:speech_to_text_app/screen/register/register_view_model.dart';
import 'package:speech_to_text_app/utilities/constants/text_constants.dart';

import '../../components/loading/container_with_loading.dart';
import '../../components/text_field/common_text_form_field.dart';
import '../../data/providers/auth_repository_provider.dart';
import '../../data/view_model/auth_viewmodel.dart';
import '../../router/app_router.dart';

final _provider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>(
  (ref) => RegisterViewModel(
    ref: ref,
  ),
);

@RoutePage()
class RegisterScreen extends BaseView {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState
    extends BaseViewState<RegisterScreen, RegisterViewModel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterState get state => ref.watch(_provider);

  AuthViewModel get authViewModel => ref.read(authViewModelProvider.notifier);

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
                  TextConstants.register,
                  style: AppTextStyles.s38w700,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CommonTextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          hintText: TextConstants.name,
                          validator: (value) {
                            return value != null && value.isEmpty
                                ? TextConstants.warningName
                                : null;
                          },
                        ),
                        const SizedBox(height: 10),
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
                          hintText: TextConstants.password,
                          obscureText: state.passwordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              viewModel.togglePasswordVisibility();
                            },
                          ),
                          validator: (value) {
                            return value != null &&
                                    value.length < minPasswordLengthRequired
                                ? TextConstants.warningPassword
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CommonTextFormField(
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.text,
                          hintText: TextConstants.confirmPassword,
                          obscureText: state.confirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              viewModel.toggleConfirmPasswordVisibility();
                            },
                          ),
                          validator: (value) {
                            return value != null &&
                                    value != _passwordController.text
                                ? TextConstants.warningMatchPassword
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
                                  await authViewModel.signUpUser(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                });
                                final signInState =
                                    ref.read(authViewModelProvider);
                                signInState.when(
                                  data: (user) async {
                                    await handlSuccess('Đăng ký thành công');
                                    context.router.replace(const LoginRoute());
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
                            child: const Text(TextConstants.signUp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(TextConstants.haveAccount),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context.router.replace(const LoginRoute());
                  },
                  child: const Text(TextConstants.signIn),
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
  String get screenName => RegisterRoute.name;

  @override
  RegisterViewModel get viewModel => ref.read(_provider.notifier);
}
