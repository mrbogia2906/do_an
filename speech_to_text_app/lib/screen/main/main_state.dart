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
  }) = _MainState;
}

class TranscriptionEntry {
  final String id; // Corresponds to transcription_id from backend
  final String audioFileId; // Corresponds to AudioFile.id
  final String? content;
  final DateTime createdAt;
  final bool isProcessing;
  final bool isError;

  TranscriptionEntry({
    required this.id,
    required this.audioFileId,
    this.content,
    required this.createdAt,
    this.isProcessing = false,
    this.isError = false,
  });

  TranscriptionEntry copyWith({
    String? id,
    String? audioFileId,
    String? content,
    DateTime? createdAt,
    bool? isProcessing,
    bool? isError,
  }) {
    return TranscriptionEntry(
      id: id ?? this.id,
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
        audioFileId: json['audio_file_id'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
        isProcessing: json['is_processing'],
        isError: json['is_error'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'audio_file_id': audioFileId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'is_processing': isProcessing,
        'is_error': isError,
      };
}

enum RecordingState { idle, recording, paused }
