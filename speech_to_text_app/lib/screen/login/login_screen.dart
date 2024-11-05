import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/resources/app_text_styles.dart';
import 'package:speech_to_text_app/screen/login/login_state.dart';
import 'package:speech_to_text_app/screen/login/login_view_model.dart';
import 'package:speech_to_text_app/utilities/constants/text_constants.dart';

import '../../data/providers/auth_repository_provider.dart';
import '../../router/app_router.dart';

final _provider = StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(
    ref: ref,
    authRepository: ref.watch(authRepositoryProvider),
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
                TextConstants.getStart,
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
                        keyboardType: TextInputType.emailAddress,
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
                        keyboardType: TextInputType.text,
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: TextConstants.password,
                          border: OutlineInputBorder(),
                        ),
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await viewModel.login(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (state.authenticated) {
                                  context.router.replace(const HomeRoute());
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
                              : const Text(TextConstants.signIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(TextConstants.dontHaveAccount),
              const SizedBox(
                height: 10,
              ),
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
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  String get screenName => LoginRoute.name;

  @override
  LoginViewModel get viewModel => ref.read(_provider.notifier);

  LoginState get state => ref.watch(_provider);

  LoadingStateViewModel get loading => ref.read(loadingStateProvider.notifier);
}
