import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';
import 'package:speech_to_text_app/data/providers/search_repository_provider.dart';

import '../../components/base_view/base_view.dart';
import '../../components/loading/container_with_loading.dart';
import '../../router/app_router.dart';
import '../../utilities/constants/text_constants.dart';
import 'component/highlight_text.dart';
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
    print('search length: ${state.searchResults.length}');
    return ContainerWithLoading(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.router.pop();
                },
              ),
              Expanded(
                child: _buildSearchBar(),
              ),
            ],
          ),
          _buildSearchResults(), // Tạo phần hiển thị kết quả tìm kiếm
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
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (value) async {
          viewModel.setSearchQuery(value);
          onLoading(() => viewModel.search(value));
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: state.searchResults.length,
        itemBuilder: (context, index) {
          final result = state.searchResults[index];
          final audioFile = result.audio;
          final transcription = result.transcription;

          String? highlightedText =
              _findHighlightedSentence(transcription.content ?? '');
          if (highlightedText == null || highlightedText.trim().isEmpty) {
            return SizedBox.shrink();
          }

          return Card(
            child: ListTile(
              title: HighlightText(
                text: audioFile.title,
                words: {
                  normalizeText(state.searchQuery): HighlightStyle(
                    backgroundColor: Colors.yellow,
                    textStyle: TextStyle(fontWeight: FontWeight.w400),
                  ),
                },
                textStyle: TextStyle(color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: HighlightText(
                text: highlightedText,
                words: {
                  normalizeText(state.searchQuery): HighlightStyle(
                    backgroundColor: Colors.yellow,
                    textStyle: TextStyle(fontWeight: FontWeight.w400),
                  ),
                },
                textStyle: TextStyle(color: Colors.black),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                AutoRouter.of(context).push(
                  AudioDetailsRoute(
                    entry: result.transcription,
                    audioFile: result.audio,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _findHighlightedSnippet(String content, String keyword) {
    final keywordLower = keyword.toLowerCase();
    final pattern = RegExp(r'\b$keywordLower\b', caseSensitive: false);
    final match = pattern.firstMatch(content);
    if (match == null) {
      return content; // Keyword not found, return the entire content
    }
    final start = match.start;
    final end = match.end;
    // Find the start of the snippet
    int snippetStart = start > 50 ? start - 50 : 0;
    snippetStart = _findWordStart(content, snippetStart);
    // Find the end of the snippet
    int snippetEnd = end < content.length - 50 ? end + 50 : content.length;
    snippetEnd = _findWordEnd(content, snippetEnd);
    // Extract the snippet
    final snippet = content.substring(snippetStart, snippetEnd);
    // Ensure the snippet includes the keyword
    if (!snippet.contains(keywordLower)) {
      return content; // Fallback if keyword is not in the snippet
    }
    // Limit the snippet to 200 characters
    if (snippet.length > 200) {
      // Find the last space before 200 characters to avoid cutting words
      final cutoff = snippet.lastIndexOf(' ', 200);
      if (cutoff != -1) {
        return '${snippet.substring(0, cutoff)}...';
      } else {
        return '${snippet.substring(0, 200)}...';
      }
    }
    return snippet;
  }

  int _findWordStart(String content, int index) {
    while (index > 0 && content[index - 1] != ' ') {
      index--;
    }
    return index;
  }

  int _findWordEnd(String content, int index) {
    while (index < content.length && content[index] != ' ') {
      index++;
    }
    return index;
  }

  String? _findHighlightedSentence(String content) {
    // Tách từ khóa thành các từ riêng biệt
    List<String> keywords = state.searchQuery.split(' ');

    String? resultText;
    for (var keyword in keywords) {
      // Loại bỏ dấu và chuyển thành chữ thường
      final normalizedContent = removeDiacritics(content.toLowerCase());
      final normalizedKeyword = removeDiacritics(keyword.toLowerCase());

      final index = normalizedContent.indexOf(normalizedKeyword);

      if (index != -1) {
        int start =
            (index - 50 >= 0) ? index - 50 : 0; // Cắt 50 ký tự trước từ khóa
        int end = (index + normalizedKeyword.length + 50 <= content.length)
            ? index + normalizedKeyword.length + 50
            : content.length; // Cắt 50 ký tự sau từ khóa
        resultText = content.substring(start, end);
      }
    }

    return resultText;
  }

  String normalizeText(String text) {
    // Remove diacritics and convert to lowercase
    return removeDiacritics(text.toLowerCase());
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
