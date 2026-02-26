// copyWith の sentinel 値（content を明示的に null にしたい場合に使用）
const Object _sentinel = Object();

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

  // sentinel: content を明示的に null (削除) にしたい場合は clearContent: true を渡す
  Note copyWith({
    String? title,
    Object? content = _sentinel,
    List<String>? imagePaths,
    List<String>? plantIds,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content == _sentinel ? this.content : content as String?,
      imagePaths: imagePaths ?? this.imagePaths,
      plantIds: plantIds ?? this.plantIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
