import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../main/main_state.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  factory HomeState({
    @Default(true) bool isLoading,
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    @Default([]) List<AudioFile> audioFiles,
    String? audioPath,
  }) = _HomeState;

  const HomeState._();
}
