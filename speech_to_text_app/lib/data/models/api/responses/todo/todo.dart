class Todo {
  final String id;
  final String transcriptionId;
  final String title;
  final String? description;
  bool? isCompleted;

  Todo({
    required this.id,
    required this.transcriptionId,
    required this.title,
    this.description,
    this.isCompleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      transcriptionId: json['transcription_id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
