// lib/screen/home/home_view_model.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/models/api/responses/audio_file/audio_file.dart';
import 'package:speech_to_text_app/data/providers/transcription_provider.dart';
import 'package:speech_to_text_app/data/services/audio_service/audio_service.dart';
import 'package:speech_to_text_app/screen/home/home_state.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';

import '../../data/providers/audio_provider.dart';
import '../../data/repositories/auth/auth_local_repository.dart';
import '../main/main_state.dart';

class HomeViewModel extends BaseViewModel<HomeState> {
  HomeViewModel({required this.ref}) : super(HomeState());

  final Ref ref;
  final AudioService _audioService = AudioService();

  Future<void> initData() async {
    state = state.copyWith(isLoading: true, audioFiles: []);
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Handle token missing
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final audioFiles = await _audioService.getAudioFiles(token);
      ref.read(audioFilesProvider.notifier).setAudioFiles(audioFiles);
      state = state.copyWith(audioFiles: audioFiles, isLoading: false);

      // Fetch transcription content for each audio file
      for (var audio in audioFiles) {
        if (!audio.isProcessing && audio.transcriptionId != null) {
          try {
            final transcription = await _audioService.getTranscription(
                audio.transcriptionId!, token);
            // Add transcription content to transcriptionProvider
            ref.read(transcriptionProvider.notifier).addTranscription(
                  TranscriptionEntry(
                    id: transcription.id,
                    audioFileId: transcription.audioFileId,
                    content: transcription.content,
                    createdAt: transcription.createdAt,
                    isProcessing: transcription.isProcessing,
                    isError: transcription.isError,
                  ),
                );
          } catch (e) {
            // Handle error fetching transcription
            ref.read(transcriptionProvider.notifier).addTranscription(
                  TranscriptionEntry(
                    id: audio.transcriptionId!,
                    audioFileId: audio.id,
                    content: 'Failed to fetch transcription.',
                    createdAt: audio.uploadedAt,
                    isProcessing: false,
                    isError: true,
                  ),
                );
          }
        } else if (audio.isProcessing) {
          // Add entry with processing state
          ref.read(transcriptionProvider.notifier).addTranscription(
                TranscriptionEntry(
                  id: audio.transcriptionId ?? '',
                  audioFileId: audio.id,
                  content: 'Transcription in progress...',
                  createdAt: audio.uploadedAt,
                  isProcessing: true,
                  isError: false,
                ),
              );
        } else {
          // Add entry with no transcription
          ref.read(transcriptionProvider.notifier).addTranscription(
                TranscriptionEntry(
                  id: audio.transcriptionId ?? '',
                  audioFileId: audio.id,
                  content: 'No transcription available.',
                  createdAt: audio.uploadedAt,
                  isProcessing: false,
                  isError: false,
                ),
              );
        }
      }
    } catch (e) {
      print('Error fetching audio files: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void removeTranscriptionEntry(TranscriptionEntry entry) {
    ref.read(transcriptionProvider.notifier).removeTranscription(entry.id);
  }

  // Các phương thức khác nếu cần
}
