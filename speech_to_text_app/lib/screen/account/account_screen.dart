import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/data/view_model/auth_viewmodel.dart';
import 'package:speech_to_text_app/screen/account/account_state.dart';
import 'package:speech_to_text_app/screen/account/account_view_model.dart';

import '../../components/failure/failure.dart';
import '../../components/loading/loading_view_model.dart';
import '../../data/models/api/responses/user/user_model.dart';
import '../../data/providers_gen/current_user_notifier.dart';
import '../../router/app_router.dart';
import '../../utilities/global.dart';

final accountProvider = StateNotifierProvider<AccountViewModel, AccountState>(
  (ref) => AccountViewModel(
    ref: ref,
    authViewModel: ref.read(authViewModelProvider.notifier),
  ),
);

@RoutePage()
class AccountScreen extends BaseView {
  const AccountScreen({super.key});

  @override
  BaseViewState<AccountScreen, AccountViewModel> createState() =>
      _AccountViewState();
}

class _AccountViewState extends BaseViewState<AccountScreen, AccountViewModel> {
  AuthViewModel get authViewModel => ref.read(authViewModelProvider.notifier);

  UserModel? get currentUser => ref.watch(currentUserNotifierProvider);

  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ProfileHeader(
              name: currentUser?.name ?? '', email: currentUser?.email ?? ''),
          const SizedBox(height: 20),
          AccountAction(
            icon: Icons.portrait,
            title: 'Change username',
            onTap: () => _showChangeUsernameBottomSheet(context),
          ),
          const SizedBox(height: 10),
          AccountAction(
            icon: Icons.key,
            title: 'Change password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 10),
          AccountAction(
            icon: Icons.logout,
            title: 'Log out',
            onTap: () {
              authViewModel.logoutUser();
              context.router.replace(const LoginRoute());
            },
          ),
        ],
      ),
    );
  }

  @override
  AccountViewModel get viewModel => ref.read(accountProvider.notifier);

  @override
  String get screenName => AccountRoute.name;

  AccountState get state => ref.watch(accountProvider);

  LoadingStateViewModel get loading => ref.read(loadingStateProvider.notifier);

  Future<void> _onInitData() async {
    Object? error;
    await loading.whileLoading(context, () async {
      try {
        await viewModel.initData();
      } catch (e) {
        error = e;
      }
    });

    if (error != null) {
      handleError(error!);
    }
  }

  // Show dialog to change username
  void _showChangeUsernameBottomSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), // Adjust padding based on keyboard height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Username',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: "Enter new username"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        // Show confirmation before applying change
                        bool confirm = await _showConfirmationDialog(
                          context,
                          'Are you sure you want to change your username?',
                        );
                        if (confirm) {
                          viewModel.changeUserName(controller.text);
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Show dialog to change password
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Change Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Old password', style: TextStyle(color: Colors.grey)),
              TextFormField(
                controller: oldPasswordController,
                decoration:
                    const InputDecoration(hintText: "Enter old password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Text('New password', style: TextStyle(color: Colors.grey)),
              TextFormField(
                controller: newPasswordController,
                decoration:
                    const InputDecoration(hintText: "Enter new password"),
                obscureText: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final oldPassword = oldPasswordController.text;
                      final newPassword = newPasswordController.text;
                      Object? error;

                      // Validate password length
                      if (oldPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter old password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter new password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPassword.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'New password must be at least 6 characters long'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (oldPassword == newPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'New password must be different from old password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Show confirmation dialog before updating password
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Password Change'),
                          content: Text(
                              'Are you sure you want to change your password?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Confirm'),
                            ),
                          ],
                        ),
                      );

                      // Kiểm tra xem người dùng có xác nhận không
                      if (confirm == true && mounted) {
                        try {
                          await viewModel.changePassword(
                              oldPassword, newPassword, context);
                          if (mounted) {
                            Navigator.pop(context); // Đóng bottom sheet
                          }
                        } catch (e) {
                          error = e;
                        }
                      }
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Show confirmation dialog before updating user details
  Future<bool> _showConfirmationDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}

class AccountAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const AccountAction({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person, size: 40, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
