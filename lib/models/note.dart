class Note {
  final String id;
  final String title;
  final String? content;
  final List<String> imagePaths;
  final List<String> plantIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    this.content,
    this.imagePaths = const [],
    this.plantIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePaths': imagePaths.join('|'),
      'plantIds': plantIds.join('|'),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePaths: map['imagePaths'] != null && map['imagePaths'].isNotEmpty
          ? (map['imagePaths'] as String).split('|')
          : [],
      plantIds: map['plantIds'] != null && map['plantIds'].isNotEmpty
          ? (map['plantIds'] as String).split('|')
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Note copyWith({
    String? title,
    String? content,
    List<String>? imagePaths,
    List<String>? plantIds,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      plantIds: plantIds ?? this.plantIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
