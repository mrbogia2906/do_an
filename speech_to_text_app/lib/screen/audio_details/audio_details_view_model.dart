// lib/screen/audio_details/audio_details_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/audio_details/audio_details_state.dart';

import '../../data/repositories/auth/auth_local_repository.dart';
import '../../data/services/audio_service/audio_service.dart';
import '../main/main_state.dart';

class AudioDetailsViewModel extends BaseViewModel<AudioDetailsState> {
  AudioDetailsViewModel({
    required this.ref,
    required this.transcriptionEntry,
  }) : super(AudioDetailsState());

  final Ref ref;
  final TranscriptionEntry transcriptionEntry;
  final AudioService _audioService = AudioService();

  Future<void> initData() async {
    await fetchTodos();
  }

  Future<void> generateTodos() async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Handle missing token
      return;
    }

    try {
      await _audioService.generateTodos(transcriptionEntry.id, token);
      // After enqueuing, start polling or fetch the to-dos after a delay
      await Future.delayed(const Duration(seconds: 5));
      await fetchTodos();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchTodos() async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Handle missing token
      return;
    }

    try {
      final todos = await _audioService.getTodos(transcriptionEntry.id, token);
      // Update the state with the fetched to-dos
      print('Fetched todos: $todos');
      if (todos.isEmpty) {
        state = state.copyWith(isVisibleCreateTodoButton: true);
      } else {
        state = state.copyWith(isVisibleCreateTodoButton: false);
      }
      state = state.copyWith(todos: todos);
    } catch (e) {
      // Handle error
      print('Error fetching todos: $e, ${transcriptionEntry.id}');
    }
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setSelectedTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void toggleTodoCompletion(String id, bool bool) {}

  Future<void> updateSummary(String newSummary) async {
    try {
      // Lưu nội dung summary mới vào API hoặc nơi bạn lưu trữ
      // await ref.read(audioServiceProvider).updateTranscriptionSummary(
      //     transcriptionEntry.id, newSummary);

      // Cập nhật lại trạng thái
      state = state.copyWith(loading: false); // Cập nhật lại UI
    } catch (e) {
      // Handle error
    }
  }
}
