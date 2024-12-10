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
  final String id;
  final String? transcriptionId;
  final String audioFileId;
  final List<WordInfo> words;
  final String? content;
  final String? summary;
  final DateTime createdAt;
  final bool isProcessing;
  final bool isError;

  TranscriptionEntry({
    required this.id,
    this.transcriptionId,
    required this.audioFileId,
    required this.words,
    this.content,
    this.summary,
    required this.createdAt,
    this.isProcessing = false,
    this.isError = false,
  });

  // Factory constructor để tạo TranscriptionEntry từ JSON
  factory TranscriptionEntry.fromJson(Map<String, dynamic> json) {
    var wordsFromJson = json['word_timings'] as List<dynamic>?;

    return TranscriptionEntry(
      id: json['id'],
      transcriptionId: json['transcription_id'],
      audioFileId: json['audio_file_id'],
      content: json['content'],
      summary: json['summary'],
      createdAt: DateTime.parse(json['created_at']),
      isProcessing: json['is_processing'] ?? false,
      isError: json['is_error'] ?? false,
      words: wordsFromJson != null
          ? wordsFromJson
              .map((wordJson) => WordInfo.fromJson(wordJson))
              .toList()
          : [],
    );
  }

  factory TranscriptionEntry.empty() {
    return TranscriptionEntry(
      id: '',
      audioFileId: '',
      createdAt: DateTime.now(),
      content: '',
      summary: '',
      words: [],
      isProcessing: false,
      isError: false,
    );
  }

  // Chuyển TranscriptionEntry thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcription_id': transcriptionId,
      'audio_file_id': audioFileId,
      'content': content,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
      'is_processing': isProcessing,
      'is_error': isError,
      'word_timings': words.map((word) => word.toJson()).toList(),
    };
  }

  // Phương thức copyWith để sao chép TranscriptionEntry với các giá trị mới
  TranscriptionEntry copyWith({
    String? id,
    String? transcriptionId,
    String? audioFileId,
    List<WordInfo>? words,
    String? content,
    String? summary,
    DateTime? createdAt,
    bool? isProcessing,
    bool? isError,
  }) {
    return TranscriptionEntry(
      id: id ?? this.id,
      transcriptionId: transcriptionId ?? this.transcriptionId,
      audioFileId: audioFileId ?? this.audioFileId,
      words: words ?? this.words,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isProcessing: isProcessing ?? this.isProcessing,
      isError: isError ?? this.isError,
    );
  }
}

class WordInfo {
  final String word;
  final double startTime; // In seconds
  final double endTime; // In seconds

  WordInfo({
    required this.word,
    required this.startTime,
    required this.endTime,
  });

  // Factory constructor để tạo WordInfo từ JSON
  factory WordInfo.fromJson(Map<String, dynamic> json) {
    return WordInfo(
      word: json['sentence'],
      startTime: (json['start_time'] as num).toDouble(),
      endTime: (json['end_time'] as num).toDouble(),
    );
  }

  // Chuyển WordInfo thành JSON
  Map<String, dynamic> toJson() {
    return {
      'sentence': word,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  // Phương thức copyWith để sao chép WordInfo với các giá trị mới
  WordInfo copyWith({
    String? word,
    double? startTime,
    double? endTime,
  }) {
    return WordInfo(
      word: word ?? this.word,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

enum RecordingState { idle, recording, paused }
