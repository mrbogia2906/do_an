import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/providers/search_repository_provider.dart';

import '../../components/base_view/base_view.dart';
import '../../components/loading/container_with_loading.dart';
import '../../router/app_router.dart';
import '../../utilities/constants/text_constants.dart';
import 'search_state.dart';
import 'search_view_model.dart';

final _provider =
    StateNotifierProvider.autoDispose<SearchViewModel, SearchState>(
  (ref) => SearchViewModel(
    ref: ref,
    searchProvider: ref.read(searchProvider),
  ),
);

@RoutePage()
class SearchScreen extends BaseView {
  const SearchScreen({super.key});

  @override
  BaseViewState<SearchScreen, SearchViewModel> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends BaseViewState<SearchScreen, SearchViewModel> {
  final _searchController = TextEditingController();

  SearchState get state => ref.watch(_provider);

  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, _onInitData);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return ContainerWithLoading(
      child: Column(
        children: [
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: TextConstants.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.setSearchQuery('');
                    viewModel.setSearchResults();
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          viewModel.setSearchQuery(value);
        },
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (value) {},
      ),
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  String get screenName => SearchRoute.name;

  @override
  SearchViewModel get viewModel => ref.read(_provider.notifier);

  Future<void> _onInitData() async {
    await onLoading(viewModel.initData);
  }
}
