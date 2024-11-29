import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/models/api/responses/todo/todo.dart';

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void setTodos(List<Todo> todos) {
    state = todos;
  }

  void addTodo(Todo todo) {
    state = [todo, ...state];
  }

  void updateTodo(Todo updatedTodo) {
    state = state.map((todo) {
      if (todo.id == updatedTodo.id) {
        return updatedTodo;
      }
      return todo;
    }).toList();
  }

  void removeTodoById(String todoId) {
    state = state.where((todo) => todo.id != todoId).toList();
  }

  void clearTodos() {
    state = [];
  }
}
