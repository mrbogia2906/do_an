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
  final String _baseUrl = ServerConstant.serverURL;

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

      // Fetch transcription content for each audio file
      for (var audio in audioFiles) {
        if (!audio.isProcessing && audio.transcriptionId != null) {
          try {
            final transcription = await _audioService.getTranscription(
                audio.transcriptionId!, token);
            print('HomeViewModel: Fetched transcription for ${audio.id}');

            // Kiểm tra xem TranscriptionEntry đã tồn tại chưa dựa trên audioFileId
            bool exists = ref
                .read(transcriptionProvider)
                .any((entry) => entry.audioFileId == audio.id);
            if (!exists) {
              ref.read(transcriptionProvider.notifier).addTranscription(
                    TranscriptionEntry(
                      id: Uuid().v4(), // Unique ID (UUID)
                      transcriptionId: transcription.transcriptionId,
                      audioFileId: audio.id,
                      content: transcription.content ?? 'No content',
                      createdAt: transcription.createdAt,
                      isProcessing: transcription.isProcessing,
                      isError: transcription.isError,
                    ),
                  );
            }
          } catch (e) {
            print(
                'HomeViewModel: Error fetching transcription for ${audio.id}: $e');
            bool exists = ref
                .read(transcriptionProvider)
                .any((entry) => entry.audioFileId == audio.id);
            if (!exists) {
              ref.read(transcriptionProvider.notifier).addTranscription(
                    TranscriptionEntry(
                      id: Uuid().v4(), // Unique ID (UUID)
                      transcriptionId: audio.transcriptionId,
                      audioFileId: audio.id,
                      content: 'Failed to fetch transcription.',
                      createdAt: audio.uploadedAt,
                      isProcessing: false,
                      isError: true,
                    ),
                  );
            }
          }
        } else if (audio.isProcessing) {
          // Add entry with processing state if not exists
          bool exists = ref
              .read(transcriptionProvider)
              .any((entry) => entry.audioFileId == audio.id);
          if (!exists &&
              audio.transcriptionId != null &&
              audio.transcriptionId!.isNotEmpty) {
            print('HomeViewModel: Transcription in progress for ${audio.id}');
            ref.read(transcriptionProvider.notifier).addTranscription(
                  TranscriptionEntry(
                    id: Uuid().v4(), // Unique ID (UUID)
                    transcriptionId: audio.transcriptionId,
                    audioFileId: audio.id, // AudioFile.id
                    content: 'Transcription in progress...',
                    createdAt: audio.uploadedAt,
                    isProcessing: true,
                    isError: false,
                  ),
                );
          }
        } else {
          // Add entry with no transcription if not exists
          bool exists = ref
              .read(transcriptionProvider)
              .any((entry) => entry.audioFileId == audio.id);
          if (!exists) {
            print('HomeViewModel: No transcription available for ${audio.id}');
            ref.read(transcriptionProvider.notifier).addTranscription(
                  TranscriptionEntry(
                    id: Uuid().v4(), // Unique ID (UUID)
                    transcriptionId: null,
                    audioFileId: audio.id,
                    content: 'No transcription available.',
                    createdAt: audio.uploadedAt,
                    isProcessing: false,
                    isError: false,
                  ),
                );
          }
        }
      }
    } catch (e) {
      print('HomeViewModel: Error fetching audio files: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Phương thức để xoá Transcription
  Future<void> deleteTranscription(TranscriptionEntry entry) async {
    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      // Xử lý khi token bị thiếu, ví dụ: chuyển hướng tới trang đăng nhập
      print('Token is missing. Please log in again.');
      return;
    }

    final url = Uri.parse("$_baseUrl/transcriptions/${entry.transcriptionId}");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Xoá transcription từ local state
        removeTranscriptionEntry(entry);
        // Thông báo thành công (tuỳ chọn)
        print('Transcription deleted successfully.');
      } else {
        // Xử lý lỗi từ backend
        print('Failed to delete transcription: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting transcription: $e');
      // Xử lý lỗi, ví dụ: hiển thị thông báo cho người dùng
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

  // Các phương thức khác nếu cần
}
