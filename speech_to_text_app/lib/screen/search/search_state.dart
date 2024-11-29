import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../main/main_state.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  factory SearchState({
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    @Default([]) List<AudioFile> audioFiles,
    @Default('') String searchQuery,
    @Default([]) List<String> searchQueryHistory,
  }) = _SearchState;

  const SearchState._();
}
