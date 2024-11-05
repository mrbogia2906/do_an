import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/firebase/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);
