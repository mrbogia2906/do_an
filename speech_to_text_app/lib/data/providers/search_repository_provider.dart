import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/api/search/search_repository.dart';

final searchProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl();
});
