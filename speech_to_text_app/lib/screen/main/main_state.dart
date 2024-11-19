import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';

part 'main_state.freezed.dart';

@freezed
class MainState with _$MainState {
  const factory MainState({
    @Default([]) List<TranscriptionEntry> transcriptionHistory,
    @Default([]) List<AudioFile> audioFiles,
    @Default(false) bool isLoading,
    @Default(RecordingState.idle) RecordingState recordingState,
    String? audioPath,
    String? error,
  }) = _MainState;
}

class TranscriptionEntry {
  final String id; // Unique identifier, e.g., UUID
  final String? transcriptionId; // transcription_id từ backend, nullable
  final String audioFileId; // Corresponds to AudioFile.id
  final String? content;
  final DateTime createdAt;
  final bool isProcessing;
  final bool isError;

  TranscriptionEntry({
    required this.id,
    this.transcriptionId,
    required this.audioFileId,
    this.content,
    required this.createdAt,
    this.isProcessing = false,
    this.isError = false,
  });

  TranscriptionEntry copyWith({
    String? id,
    String? transcriptionId,
    String? audioFileId,
    String? content,
    DateTime? createdAt,
    bool? isProcessing,
    bool? isError,
  }) {
    return TranscriptionEntry(
      id: id ?? this.id,
      transcriptionId: transcriptionId ?? this.transcriptionId,
      audioFileId: audioFileId ?? this.audioFileId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isProcessing: isProcessing ?? this.isProcessing,
      isError: isError ?? this.isError,
    );
  }

  factory TranscriptionEntry.fromJson(Map<String, dynamic> json) =>
      TranscriptionEntry(
        id: json['id'],
        transcriptionId: json['transcription_id'],
        audioFileId: json['audio_file_id'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
        isProcessing: json['is_processing'] ?? false,
        isError: json['is_error'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'transcription_id': transcriptionId,
        'audio_file_id': audioFileId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'is_processing': isProcessing,
        'is_error': isError,
      };
}

enum RecordingState { idle, recording, paused }
