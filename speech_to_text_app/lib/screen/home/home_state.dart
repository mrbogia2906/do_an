import 'package:freezed_annotation/freezed_annotation.dart';

import '../main/main_state.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  factory HomeState({
    @Default(true) bool loading,
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    String? audioPath,
  }) = _HomeState;

  const HomeState._();
}
