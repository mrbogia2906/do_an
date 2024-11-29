import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/api/responses/todo/todo.dart';
import '../main/main_state.dart';

part 'audio_details_state.freezed.dart';

@freezed
class AudioDetailsState with _$AudioDetailsState {
  factory AudioDetailsState({
    @Default(true) bool loading,
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    @Default([]) List<Todo> todos,
    @Default(true) bool isExpanded,
    @Default(true) bool isVisibleCreateTodoButton,
    @Default(0) int selectedTabIndex,
  }) = _AudioDetailsState;

  const AudioDetailsState._();
}
