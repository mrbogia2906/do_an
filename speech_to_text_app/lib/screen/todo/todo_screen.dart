import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/container_with_loading.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/todo/todo_state.dart';
import 'package:speech_to_text_app/screen/todo/todo_view_model.dart';

import '../../data/models/api/responses/todo/todo.dart';
import '../../router/app_router.dart';

final _provider = StateNotifierProvider.autoDispose<TodoViewModel, TodoState>(
  (ref) => TodoViewModel(
    ref: ref,
  ),
);

@RoutePage()
class TodoScreen extends BaseView {
  const TodoScreen({super.key});

  @override
  BaseViewState<TodoScreen, TodoViewModel> createState() => _TodoViewState();
}

class _TodoViewState extends BaseViewState<TodoScreen, TodoViewModel> {
  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => AppBar(
        title: const Text('To-do list',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      );

  @override
  Widget buildBody(BuildContext context) {
    // Group todos by their audio title
    final Map<String, List<Todo>> groupedTodos = {};

    for (var todo in state.todos) {
      String groupTitle = todo.audioTitle ?? 'Unknown';
      if (!groupedTodos.containsKey(groupTitle)) {
        groupedTodos[groupTitle] = [];
      }
      groupedTodos[groupTitle]!.add(todo);
    }

    return ContainerWithLoading(
      child: RefreshIndicator(
        onRefresh: _refreshScreen,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // To-do list section
              Expanded(
                child: ListView.builder(
                  itemCount: groupedTodos.keys.length,
                  itemBuilder: (context, index) {
                    String groupTitle = groupedTodos.keys.elementAt(index);
                    List<Todo> todoItems = groupedTodos[groupTitle]!;

                    return TodoGroup(
                      groupTitle: groupTitle,
                      todoItems: todoItems
                          .map((todo) => _buildTodoItem(
                              todo.id, todo.title, todo.isCompleted ?? false))
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(String id, String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (bool? value) {
              viewModel.toggleTodoCompletion(id, value ?? false);
            },
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshScreen() async {
    await viewModel.initData();
  }

  @override
  TodoViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => TodoRoute.name;

  TodoState get state => ref.watch(_provider);

  LoadingStateViewModel get loading => ref.read(loadingStateProvider.notifier);

  Future<void> _onInitData() async {
    Object? error;

    await loading.whileLoading(context, () async {
      try {
        await viewModel.initData();
      } catch (e) {
        error = e;
      }
    });

    if (error != null) {
      handleError(error!);
    }
  }
}

class TodoGroup extends StatelessWidget {
  final String groupTitle;
  final List<Widget> todoItems;

  const TodoGroup({
    super.key,
    required this.groupTitle,
    required this.todoItems,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...todoItems,
          ],
        ),
      ),
    );
  }
}
