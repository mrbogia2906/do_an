import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/todo/todo_state.dart';

class TodoViewModel extends BaseViewModel<TodoState> {
  TodoViewModel({
    required this.ref,
  }) : super(TodoState());

  final Ref ref;

  Future<void> initData() async {}
}
