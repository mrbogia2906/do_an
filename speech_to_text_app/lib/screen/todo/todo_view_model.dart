import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/todo/todo_state.dart';

import '../../data/repositories/auth/auth_local_repository.dart';
import '../../data/services/audio_service/audio_service.dart';

class TodoViewModel extends BaseViewModel<TodoState> {
  TodoViewModel({
    required this.ref,
  }) : super(TodoState());

  final Ref ref;
  final AudioService _audioService = AudioService();

  Future<void> initData() async {
    await fetchTodos();
  }

  Future<void> fetchTodos() async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    try {
      final todos = await _audioService.getTodoList(token!);
      state = state.copyWith(todos: todos);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleTodoCompletion(String id, bool status) async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      return;
    }

    try {
      await _audioService.updateTodoStatus(id, status, token);

      final updatedTodos = state.todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(isCompleted: status);
        }
        return todo;
      }).toList();

      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      // Handle error
      print('Error updating todo status: $e');
    }
  }
}
