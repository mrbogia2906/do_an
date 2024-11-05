import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_state.freezed.dart';

@freezed
class TodoState with _$TodoState {
  factory TodoState({
    @Default(true) bool loading,
  }) = _TodoState;

  const TodoState._();
}
