import 'dart:convert';

class SearchResult {
  final String type;
  final String id;
  final String? title;
  final String? content;
  final String? audioFileId;
  final DateTime? uploadedAt;
  final DateTime? createdAt;

  SearchResult({
    required this.type,
    required this.id,
    this.title,
    this.content,
    this.audioFileId,
    this.uploadedAt,
    this.createdAt,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type'],
      id: json['id'],
      title: json['title'],
      content: json['content'],
      audioFileId: json['audio_file_id'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
