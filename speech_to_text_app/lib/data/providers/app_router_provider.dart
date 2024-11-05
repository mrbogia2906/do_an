import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/app_router.dart';

final appRouterProvider = Provider<AppRouter>(
  (ref) => AppRouter(),
);
