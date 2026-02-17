enum LogType {
  watering,
  fertilizer,
  vitalizer,
}

class LogEntry {
  final String id;
  final String plantId;
  final LogType type;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  LogEntry({
    required this.id,
    required this.plantId,
    required this.type,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'],
      plantId: map['plantId'],
      type: LogType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date']),
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  LogEntry copyWith({
    DateTime? date,
    String? note,
    DateTime? updatedAt,
  }) {
    return LogEntry(
      id: id,
      plantId: plantId,
      type: type,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
