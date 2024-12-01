class AudioFile {
  final String id;
  final String title;
  final String fileUrl;
  final DateTime uploadedAt;
  final String? transcriptionId;
  final bool isProcessing;

  AudioFile({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.uploadedAt,
    this.transcriptionId,
    required this.isProcessing,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) => AudioFile(
        id: json['id'],
        title: json['title'],
        fileUrl: json['file_url'],
        uploadedAt: DateTime.parse(json['uploaded_at']),
        transcriptionId: json['transcription_id'],
        isProcessing: json['is_processing'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'file_url': fileUrl,
        'uploaded_at': uploadedAt.toIso8601String(),
        'transcription_id': transcriptionId,
        'is_processing': isProcessing,
      };
}
