import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth/auth_remote_repository.dart';

final authRemoteRepositoryProvider = Provider<AuthRemoteRepository>(
  (ref) => AuthRemoteRepositoryImpl(),
);
