import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:speech_to_text_app/data/models/api/responses/todo/todo.dart';

part 'todo_state.freezed.dart';

@freezed
class TodoState with _$TodoState {
  factory TodoState({
    @Default(true) bool loading,
    @Default([]) List<Todo> todos,
  }) = _TodoState;

  const TodoState._();
}
