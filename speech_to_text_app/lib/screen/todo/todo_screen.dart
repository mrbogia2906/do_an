import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/todo/todo_state.dart';
import 'package:speech_to_text_app/screen/todo/todo_view_model.dart';

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
        title: const Text('To-do list'),
        elevation: 0,
        backgroundColor: Colors.white,
      );

  @override
  Widget buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Buttons (By recording / By time)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('By recording'),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('By time'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search content',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // To-do list section
          Expanded(
            child: ListView(
              children: [
                TodoGroup(
                  groupTitle: 'Cuộc họp mẫu: Họp Đại hội Cổ',
                  todoItems: [
                    'Khai trương 6 trung tâm thương mại mới, nâng tổng số lên 89 trung tâm',
                    'Tiếp tục phát triển các sản phẩm Megamall, mô hình Life Design Mode và kiến trúc độc đáo',
                    'Cải thiện hệ thống cơ sở vật chất, nâng cao chất lượng dịch vụ khách hàng',
                  ],
                ),
                const SizedBox(height: 16),
                TodoGroup(
                  groupTitle: 'Kế hoạch 2025',
                  todoItems: [
                    'Mở rộng chi nhánh quốc tế',
                    'Triển khai hệ thống quản lý thông minh',
                    'Tăng cường đào tạo nhân viên',
                  ],
                ),
              ],
            ),
          ),

          // Add new to-do
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add new to-do'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build to-do items
  Widget _buildTodoItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
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
  final List<String> todoItems;

  const TodoGroup({
    Key? key,
    required this.groupTitle,
    required this.todoItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ...todoItems.map((item) => _buildTodoItem(item)).toList(),
      ],
    );
  }

  Widget _buildTodoItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
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
}
