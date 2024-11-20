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
      state = state.copyWith(todos: todos);
    } catch (e) {
      // Handle error
    }
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setSelectedTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}
