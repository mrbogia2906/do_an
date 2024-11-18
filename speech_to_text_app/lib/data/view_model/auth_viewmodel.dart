// lib/features/auth/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/failure/failure.dart';
import '../models/api/responses/user/user_model.dart';
import '../providers/auth_local_repository_provider.dart';
import '../providers/auth_remote_repository_provider.dart';
import '../providers_gen/current_user_notifier.dart';
import '../repositories/auth/auth_local_repository.dart';
import '../repositories/auth/auth_remote_repository.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>(
  (ref) => AuthViewModel(
    authRemoteRepository: ref.read(authRemoteRepositoryProvider),
    authLocalRepository: ref.read(authLocalRepositoryProvider),
    currentUserNotifier: ref.read(currentUserNotifierProvider.notifier),
  ),
);

class AuthViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRemoteRepository _authRemoteRepository;
  final AuthLocalRepository _authLocalRepository;
  final CurrentUserNotifier _currentUserNotifier;

  AuthViewModel({
    required AuthRemoteRepository authRemoteRepository,
    required AuthLocalRepository authLocalRepository,
    required CurrentUserNotifier currentUserNotifier,
  })  : _authRemoteRepository = authRemoteRepository,
        _authLocalRepository = authLocalRepository,
        _currentUserNotifier = currentUserNotifier,
        super(const AsyncValue.loading()) {
    initSharedPreferences();
  }

  // Khởi tạo SharedPreferences
  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
    state = const AsyncValue.data(null);
  }

  // Phương thức đăng ký người dùng
  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRemoteRepository.signup(
        name: name,
        email: email,
        password: password,
      );
      // Lưu token vào cục bộ
      if (user.token != null) {
        await _authLocalRepository.setToken(user.token);
        print('Token saved after login: ${user.token}');
      } else {
        print('No token received after login');
      }
      // Cập nhật trạng thái người dùng hiện tại
      _currentUserNotifier.addUser(user);
      // Cập nhật trạng thái
      state = AsyncValue.data(user);
    } catch (e) {
      if (e is AppFailure) {
        state = AsyncValue.error(e.message, StackTrace.current);
      } else {
        state = AsyncValue.error(
            'An unexpected error occurred', StackTrace.current);
      }
    }
  }

  // Phương thức đăng nhập người dùng
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRemoteRepository.login(
        email: email,
        password: password,
      );

      // Kiểm tra xem token có hợp lệ không
      if (user.token == null) {
        throw AppFailure('Login failed: No token received.');
      }

      // Lưu token vào cục bộ
      if (user.token != null) {
        await _authLocalRepository.setToken(user.token);
        print('Token saved after login: ${user.token}');
      } else {
        print('No token received after login');
      }

      // Cập nhật trạng thái người dùng hiện tại
      _currentUserNotifier.addUser(user);

      // Cập nhật trạng thái
      state = AsyncValue.data(user);
    } catch (e) {
      // Xóa token nếu có lỗi
      await _authLocalRepository.clearToken();
      _currentUserNotifier.removeUser();
      if (e is AppFailure) {
        state = AsyncValue.error(e.message, StackTrace.current);
      } else {
        state = AsyncValue.error(
          'An unexpected error occurred',
          StackTrace.current,
        );
      }
    }
  }

  // Phương thức lấy dữ liệu người dùng hiện tại
  Future<void> getCurrentUserData() async {
    state = const AsyncValue.loading();
    try {
      final token = await _authLocalRepository.getToken();
      if (token == null) {
        throw AppFailure('No token found. Please log in.');
      }
      final user = await _authRemoteRepository.getCurrentUserData(token);
      // Cập nhật trạng thái người dùng hiện tại
      _currentUserNotifier.addUser(user);
      // Cập nhật trạng thái
      state = AsyncValue.data(user);
    } catch (e) {
      if (e is AppFailure) {
        state = AsyncValue.error(e.message, StackTrace.current);
      } else {
        state = AsyncValue.error(
            'An unexpected error occurred', StackTrace.current);
      }
    }
  }

  // Phương thức đăng xuất người dùng
  Future<void> logoutUser() async {
    try {
      await _authLocalRepository.clearToken();
      _currentUserNotifier.removeUser();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error('Failed to logout', StackTrace.current);
    }
  }

  Future<void> getData() async {
    state = const AsyncValue.loading();
    try {
      final token = await _authLocalRepository.getToken();
      if (token == null) {
        throw AppFailure('No token found. Please log in.');
      }
      final user = await _authRemoteRepository.getCurrentUserData(token);
      // Cập nhật trạng thái người dùng hiện tại
      _currentUserNotifier.addUser(user);
      // Cập nhật trạng thái
      state = AsyncValue.data(user);
    } catch (e) {
      // Xóa token nếu có lỗi
      await _authLocalRepository.clearToken();
      _currentUserNotifier.removeUser();
      if (e is AppFailure) {
        state = AsyncValue.error(e.message, StackTrace.current);
      } else {
        state = AsyncValue.error(
          'An unexpected error occurred',
          StackTrace.current,
        );
      }
    }
  }

  AsyncValue<UserModel?> _getDataSuccess(UserModel user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}
