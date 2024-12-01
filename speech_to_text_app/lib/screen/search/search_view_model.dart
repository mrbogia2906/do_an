import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/base_view/base_view_model.dart';
import '../../data/repositories/api/search/search_repository.dart';
import '../../data/repositories/auth/auth_local_repository.dart';
import 'search_state.dart';

class SearchViewModel extends BaseViewModel<SearchState> {
  SearchViewModel({
    required this.ref,
    required this.searchProvider,
  }) : super(SearchState());

  final Ref ref;

  final SearchRepository searchProvider;

  Future<void> initData() async {}

  Future<void> search(String query) async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    try {
      final results = await searchProvider.getSearchResults(token!, query);
      state = state.copyWith(searchResults: results);
    } catch (e) {
      state = state.copyWith(searchResults: []);
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSearchResults() {
    state = state.copyWith(searchResults: []);
  }
}
