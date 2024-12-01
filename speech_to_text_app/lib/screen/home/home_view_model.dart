// lib/screen/home/home_view_model.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/models/api/responses/audio_file/audio_file.dart';
import 'package:speech_to_text_app/data/providers/transcription_provider.dart';
import 'package:speech_to_text_app/data/services/audio_service/audio_service.dart';
import 'package:speech_to_text_app/screen/home/home_state.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/utilities/constants/server_constants.dart';
import '../../data/providers/audio_provider.dart';
import '../../data/repositories/auth/auth_local_repository.dart';
import '../main/main_state.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomeViewModel extends BaseViewModel<HomeState> {
  HomeViewModel({required this.ref}) : super(HomeState());

  final Ref ref;
  final AudioService _audioService = AudioService();
  // final String _baseUrl = ServerConstant.serverURL;

  Future<void> initData() async {
    print('HomeViewModel: initData called');
    state = state.copyWith(isLoading: true, audioFiles: []);
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      print('HomeViewModel: Token is missing');
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final audioFiles = await _audioService.getAudioFiles(token);
      ref.read(audioFilesProvider.notifier).setAudioFiles(audioFiles);
      state = state.copyWith(audioFiles: audioFiles, isLoading: false);

      // Prepare a list to collect TranscriptionEntry Futures
      List<Future<TranscriptionEntry>> transcriptionEntryFutures = [];

      // Collect all futures for fetching transcriptions
      for (var audio in audioFiles) {
        if (!audio.isProcessing && audio.transcriptionId != null) {
          // Add a future to the list
          transcriptionEntryFutures.add(_fetchTranscriptionEntry(audio, token));
        } else if (audio.isProcessing) {
          if (audio.transcriptionId != null &&
              audio.transcriptionId!.isNotEmpty) {
            transcriptionEntryFutures.add(Future.value(
              TranscriptionEntry(
                id: Uuid().v4(),
                transcriptionId: audio.transcriptionId,
                audioFileId: audio.id,
                content: 'Transcription in progress...',
                createdAt: audio.uploadedAt,
                isProcessing: true,
                isError: false,
              ),
            ));
          }
        } else {
          transcriptionEntryFutures.add(Future.value(
            TranscriptionEntry(
              id: Uuid().v4(),
              transcriptionId: null,
              audioFileId: audio.id,
              content: 'No transcription available.',
              createdAt: audio.uploadedAt,
              isProcessing: false,
              isError: false,
            ),
          ));
        }
      }

      // Await all the futures
      List<TranscriptionEntry> transcriptionEntries =
          await Future.wait(transcriptionEntryFutures);

      // After collecting all TranscriptionEntries, update the provider at once
      ref
          .read(transcriptionProvider.notifier)
          .setTranscriptions(transcriptionEntries);
    } catch (e) {
      print('HomeViewModel: Error fetching audio files: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<TranscriptionEntry> _fetchTranscriptionEntry(
      AudioFile audio, String token) async {
    try {
      final transcription =
          await _audioService.getTranscription(audio.transcriptionId!, token);
      print('HomeViewModel: Fetched transcription for ${audio.id}');

      return TranscriptionEntry(
        id: transcription.id, // Unique ID (UUID)
        transcriptionId: transcription.transcriptionId,
        audioFileId: audio.id,
        content: transcription.content ?? 'No content',
        createdAt: transcription.createdAt,
        isProcessing: transcription.isProcessing,
        isError: transcription.isError,
      );
    } catch (e) {
      print('HomeViewModel: Error fetching transcription for ${audio.id}: $e');

      return TranscriptionEntry(
        id: Uuid().v4(), // Unique ID (UUID)
        transcriptionId: audio.transcriptionId,
        audioFileId: audio.id,
        content: 'Failed to fetch transcription.',
        createdAt: audio.uploadedAt,
        isProcessing: false,
        isError: true,
      );
    }
  }

  /// Phương thức để xoá AudioFile và Transcription
  Future<void> deleteAudioFile(AudioFile audioFile) async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Xử lý khi token bị thiếu, ví dụ: chuyển hướng tới trang đăng nhập
      print('Token is missing. Please log in again.');
      return;
    }

    try {
      await _audioService.deleteAudioFile(audioFile.id, token);
      // Xoá AudioFile và Transcription từ local state
      removeAudioFileEntry(audioFile);
      // Thông báo thành công (tuỳ chọn)
      print('AudioFile and Transcription deleted successfully.');
    } catch (e) {
      print('Error deleting AudioFile: $e');
      // Xử lý lỗi, ví dụ: hiển thị thông báo cho người dùng
    }
  }

  /// Phương thức để xoá transcription từ state
  void removeTranscriptionEntry(TranscriptionEntry entry) {
    ref
        .read(transcriptionProvider.notifier)
        .removeTranscription(entry.audioFileId);
  }

  /// Phương thức để xoá AudioFile từ state
  void removeAudioFileEntry(AudioFile audioFile) {
    ref.read(audioFilesProvider.notifier).removeAudioFile(audioFile.id);
    // Xoá Transcription liên quan
    ref.read(transcriptionProvider.notifier).removeTranscription(audioFile.id);
  }

  Future<void> updateAudioFileTitle(
      AudioFile audioFile, String newTitle) async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Xử lý khi token bị thiếu, ví dụ: chuyển hướng tới trang đăng nhập
      print('Token is missing. Please log in again.');
      return;
    }

    try {
      // state = state.copyWith(isUpdatingTitle: true);

      final updatedAudioFile = await _audioService.updateAudioFileTitle(
          audioFile.id, newTitle, token);

      // Cập nhật AudioFile trong local state
      ref.read(audioFilesProvider.notifier).updateAudioFile(updatedAudioFile);

      final transcriptionEntries = ref.read(transcriptionProvider);
      final updatedTranscriptions = transcriptionEntries.map((entry) {
        if (entry.audioFileId == audioFile.id) {
          return TranscriptionEntry(
            id: entry.id,
            transcriptionId: entry.transcriptionId,
            audioFileId: entry.audioFileId,
            content: entry.content,
            createdAt: entry.createdAt,
            isProcessing: entry.isProcessing,
            isError: entry.isError,
          );
        }
        return entry;
      }).toList();
      ref
          .read(transcriptionProvider.notifier)
          .setTranscriptions(updatedTranscriptions);

      print('AudioFile title updated successfully.');

      // state = state.copyWith(isUpdatingTitle: false);
    } catch (e) {
      print('Error updating AudioFile title: $e');
      // state = state.copyWith(isUpdatingTitle: false);
    }
  }
}
