import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/base_view/base_view_model.dart';
import '../../data/repositories/api/search/search_repository.dart';
import 'search_state.dart';

class SearchViewModel extends BaseViewModel<SearchState> {
  SearchViewModel({
    required this.ref,
    required this.searchProvider,
  }) : super(SearchState());

  final Ref ref;

  final SearchRepository searchProvider;

  Future<void> initData() async {}

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSearchResults() {
    state = state.copyWith(audioFiles: []);
  }
}
