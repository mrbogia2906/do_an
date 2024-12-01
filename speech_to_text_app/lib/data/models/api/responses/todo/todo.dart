class Todo {
  final String id;
  final String transcriptionId;
  final String title;
  final String? description;
  String? audioTitle;
  bool? isCompleted;

  Todo({
    required this.id,
    required this.transcriptionId,
    required this.title,
    this.audioTitle,
    this.description,
    this.isCompleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      transcriptionId: json['transcription_id'],
      title: json['title'],
      audioTitle: json['audio_title'] ?? '',
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcription_id': transcriptionId,
      'title': title,
      'audio_title': audioTitle,
      'description': description,
      'is_completed': isCompleted,
    };
  }

  Todo copyWith({
    String? id,
    String? transcriptionId,
    String? title,
    String? audioTitle,
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      transcriptionId: transcriptionId ?? this.transcriptionId,
      title: title ?? this.title,
      audioTitle: audioTitle ?? this.audioTitle,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
