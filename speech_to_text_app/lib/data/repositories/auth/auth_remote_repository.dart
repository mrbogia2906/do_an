// auth_remote_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../components/failure/failure.dart';
import '../../../utilities/constants/server_constants.dart';
import '../../models/api/responses/user/user_model.dart';

abstract class AuthRemoteRepository {
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> changeUserName({
    required String name,
    required String token,
  });

  Future<UserModel> changeUserPassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  });

  Future<UserModel> getCurrentUserData(String token);
}

class AuthRemoteRepositoryImpl implements AuthRemoteRepository {
  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ServerConstant.serverURL}/auth/signup',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': name,
            'email': email,
            'password': password,
          },
        ),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        // {'detail': 'error message'}
        throw AppFailure(resBodyMap['detail'] ?? 'Signup failed');
      }

      return UserModel.fromMap(resBodyMap);
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      } else {
        throw AppFailure(e.toString());
      }
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ServerConstant.serverURL}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'email': email,
            'password': password,
          },
        ),
      );

      if (response.statusCode != 200) {
        String errorDetail = 'Login failed';
        try {
          final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
          errorDetail = resBodyMap['detail'] ?? errorDetail;
        } catch (e) {}
        throw AppFailure(errorDetail);
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      return UserModel.fromMap(resBodyMap['user']).copyWith(
        token: resBodyMap['token'],
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      } else {
        throw AppFailure(e.toString());
      }
    }
  }

  @override
  Future<UserModel> changeUserName({
    required String name,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ServerConstant.serverURL}/auth/change-name',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            'new_username': name,
          },
        ),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw AppFailure(resBodyMap['detail'] ?? 'Changing name failed');
      }

      return UserModel.fromMap(resBodyMap);
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      } else {
        throw AppFailure(e.toString());
      }
    }
  }

  @override
  Future<UserModel> changeUserPassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ServerConstant.serverURL}/auth/change-password',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            'old_password': oldPassword,
            'new_password': newPassword,
          },
        ),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw AppFailure(resBodyMap['detail'] ?? 'Changing password failed');
      }

      return UserModel.fromMap(resBodyMap);
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      } else {
        throw AppFailure(e.toString());
      }
    }
  }

  @override
  Future<UserModel> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ServerConstant.serverURL}/auth/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw AppFailure(resBodyMap['detail'] ?? 'Fetching user data failed');
      }

      return UserModel.fromMap(resBodyMap).copyWith(
        token: token,
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      } else {
        throw AppFailure(e.toString());
      }
    }
  }
}
