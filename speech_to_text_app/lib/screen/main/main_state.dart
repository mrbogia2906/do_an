import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.freezed.dart';

@freezed
class MainState with _$MainState {
  const factory MainState({
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    @Default(false) bool isLoading,
    @Default(RecordingState.idle) RecordingState recordingState,
    String? audioPath,
  }) = _MainState;
}

class TranscriptionEntry {
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isProcessing;

  TranscriptionEntry({
    required this.title,
    required this.content,
    required this.timestamp,
    this.isProcessing = false,
  });

  TranscriptionEntry copyWith({
    String? title,
    String? content,
    DateTime? timestamp,
    bool? isProcessing,
  }) {
    return TranscriptionEntry(
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

enum RecordingState { idle, recording, paused }
