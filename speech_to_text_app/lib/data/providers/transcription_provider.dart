// lib/providers/transcription_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screen/main/main_state.dart';

class TranscriptionNotifier extends StateNotifier<List<TranscriptionEntry>> {
  TranscriptionNotifier() : super([]);

  // Thêm TranscriptionEntry mới
  void addTranscription(TranscriptionEntry entry) {
    state = [entry, ...state];
    print('TranscriptionProvider - Added: ${entry.id} - ${entry.content}');
  }

  void updateTranscriptionByTempId(
      String tempId, TranscriptionEntry updatedEntry) {
    state = [
      for (final entry in state)
        if (entry.id == tempId) updatedEntry else entry,
    ];
  }

  // Cập nhật TranscriptionEntry dựa trên audioFileId
  void updateTranscriptionByAudioFileId(
      String audioFileId, TranscriptionEntry updatedEntry) {
    state = state.map((entry) {
      if (entry.audioFileId == audioFileId) {
        return updatedEntry;
      } else {
        return entry;
      }
    }).toList();
    print(
        'TranscriptionProvider - Updated: ${updatedEntry.id} - ${updatedEntry.content}');
  }

  void setTranscriptions(List<TranscriptionEntry> transcriptions) {
    state = transcriptions;
    print('TranscriptionProvider - Set transcriptions');
  }

  // Xóa TranscriptionEntry dựa trên audioFileId
  void removeTranscription(String audioFileId) {
    state = state.where((entry) => entry.audioFileId != audioFileId).toList();
    print('TranscriptionProvider - Removed: $audioFileId');
  }

  // Xóa tất cả các TranscriptionEntry
  void clearTranscriptions() {
    state = [];
    print('TranscriptionProvider - All transcriptions cleared');
  }
}

final transcriptionProvider =
    StateNotifierProvider<TranscriptionNotifier, List<TranscriptionEntry>>(
        (ref) => TranscriptionNotifier());
