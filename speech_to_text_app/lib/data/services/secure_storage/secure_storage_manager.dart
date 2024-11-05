import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  SecureStorageManager(this._storage);

  final FlutterSecureStorage _storage;

  static const _story = 'story';
  static const _post = 'post';

  Future<String?> _read({
    required String key,
  }) async {
    return _storage.read(key: key);
  }

  Future<void> _delete({
    required String key,
  }) async {
    await _storage.delete(key: key);
  }

  Future<void> _write({
    required String key,
    required String? value,
  }) async {
    await _storage.write(key: key, value: value);
  }
}
