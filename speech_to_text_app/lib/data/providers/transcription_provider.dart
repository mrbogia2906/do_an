// lib/providers/transcription_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screen/main/main_state.dart';

class TranscriptionNotifier extends StateNotifier<List<TranscriptionEntry>> {
  TranscriptionNotifier() : super([]);

  void addTranscription(TranscriptionEntry entry) {
    state = [entry, ...state];
    print('TranscriptionProvider - Added: ${entry.id} - ${entry.content}');
  }

  void updateTranscription(TranscriptionEntry updatedEntry) {
    state = state
        .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
        .toList();
    print(
        'TranscriptionProvider - Updated: ${updatedEntry.id} - ${updatedEntry.content}');
  }

  void removeTranscription(String id) {
    state = state.where((entry) => entry.id != id).toList();
    print('TranscriptionProvider - Removed: $id');
  }

  void clearTranscriptions() {
    state = [];
    print('TranscriptionProvider - All transcriptions cleared');
  }
}

final transcriptionProvider =
    StateNotifierProvider<TranscriptionNotifier, List<TranscriptionEntry>>(
        (ref) => TranscriptionNotifier());
