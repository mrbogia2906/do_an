class TranscriptionEntry {
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isProcessing;

  TranscriptionEntry({
    required this.title,
    required this.content,
    required this.timestamp,
    required this.isProcessing,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isProcessing': isProcessing,
      };

  factory TranscriptionEntry.fromJson(Map<String, dynamic> json) =>
      TranscriptionEntry(
        title: json['title'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        isProcessing: json['isProcessing'],
      );
}
