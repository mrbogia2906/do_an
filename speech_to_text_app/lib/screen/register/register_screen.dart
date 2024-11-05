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

import '../../data/providers/auth_repository_provider.dart';
import '../../router/app_router.dart';

final _provider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>(
  (ref) => RegisterViewModel(
    ref: ref,
    authRepository: ref.watch(authRepositoryProvider),
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return Center(
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
              const SizedBox(
                height: 18,
              ),
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: TextConstants.email,
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return value != null &&
                                  !EmailValidator.validate(value)
                              ? TextConstants.warningEmail
                              : null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: TextConstants.password,
                          border: const OutlineInputBorder(),
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
                        ),
                        obscureText: state.passwordVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return value != null && value.length < 6
                              ? TextConstants.warningPassword
                              : null;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: TextConstants.confirmPassword,
                          border: const OutlineInputBorder(),
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
                        ),
                        obscureText: state.confirmPasswordVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              try {
                                await viewModel.register(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (state.authenticated) {
                                  unawaited(context.router
                                      .replace(const HomeRoute()));
                                }
                              } on Exception catch (e) {
                                if (mounted) {
                                  final errorMessage = e
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: state.loading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(TextConstants.signUp),
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
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  String get screenName => RegisterRoute.name;

  @override
  RegisterViewModel get viewModel => ref.read(_provider.notifier);

  RegisterState get state => ref.watch(_provider);
}
