import 'package:freezed_annotation/freezed_annotation.dart';

part 'loading_state.freezed.dart';

@freezed
class LoadingState with _$LoadingState {
  factory LoadingState({
    @Default(false) bool isLoading,
  }) = _LoadingState;
}
