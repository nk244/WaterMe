class DiaryEntry {
  final String id;
  final String plantId;
  final DateTime date;
  final String? text;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.plantId,
    required this.date,
    this.text,
    this.imagePaths = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'date': date.toIso8601String(),
      'text': text,
      'imagePaths': imagePaths.join('|'),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      plantId: map['plantId'],
      date: DateTime.parse(map['date']),
      text: map['text'],
      imagePaths: map['imagePaths'] != null && map['imagePaths'].isNotEmpty
          ? (map['imagePaths'] as String).split('|')
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  DiaryEntry copyWith({
    DateTime? date,
    String? text,
    List<String>? imagePaths,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id,
      plantId: plantId,
      date: date ?? this.date,
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
