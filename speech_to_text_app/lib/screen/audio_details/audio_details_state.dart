import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_details_state.freezed.dart';

@freezed
class AudioDetailsState with _$AudioDetailsState {
  factory AudioDetailsState({
    @Default(true) bool loading,
  }) = _AudioDetailsState;

  const AudioDetailsState._();
}
