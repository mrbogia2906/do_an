import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screen/main/main_state.dart';
import '../models/api/responses/audio_file/audio_file.dart';
import '../providers_gen/current_user_notifier.dart';
import '../services/audio_service/audio_service.dart';

final audioFilesProvider =
    StateNotifierProvider<AudioFilesNotifier, List<AudioFile>>(
  (ref) => AudioFilesNotifier(ref),
);

class AudioFilesNotifier extends StateNotifier<List<AudioFile>> {
  final Ref ref;
  final AudioService _audioService = AudioService();

  AudioFilesNotifier(this.ref) : super([]);

  void setAudioFiles(List<AudioFile> audioFiles) {
    state = audioFiles;
    print(
        'AudioFilesProvider - setAudioFiles: ${audioFiles.length} files loaded');
  }

  void addAudioFile(AudioFile audioFile) {
    state = [audioFile, ...state];
    print('AudioFilesProvider - Added: ${audioFile.id} - ${audioFile.title}');
  }

  void clearAudioFiles() {
    state = [];
    print('AudioFilesProvider - Audio files cleared');
  }

  // Future<void> fetchAudioFiles() async {
  //   final user = ref.watch(currentUserNotifierProvider);
  //   if (user == null) return;

  //   try {
  //     final audioFiles = await _audioService.getAudioFiles(user.token);
  //     state = audioFiles;
  //   } catch (e) {
  //     print("Error fetching audio files: $e");
  //     // Xử lý lỗi nếu cần
  //   }
  // }

  Future<void> uploadAudio(File audio, String title) async {
    final user = ref.watch(currentUserNotifierProvider);
    if (user == null) return;

    try {
      final newAudio =
          await _audioService.uploadAudio(audio, title, user.token);
      state = [...state, newAudio];
    } catch (e) {
      print("Error uploading audio: $e");
      // Xử lý lỗi nếu cần
    }
  }
}

// final transcriptionProvider = FutureProvider.family<TranscriptionEntry, String>(
//     (ref, transcriptionId) async {
//   final audioService = AudioService();
//   final user = ref.watch(currentUserNotifierProvider);
//   if (user == null) throw Exception("User not logged in");
//   return await audioService.getTranscription(transcriptionId, user.token);
// });
