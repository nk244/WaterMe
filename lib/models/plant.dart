class Plant {
  final String id;
  final String name;
  final String? variety;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final String? imagePath;
  final int? wateringIntervalDays;
  final DateTime? nextWateringDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plant({
    required this.id,
    required this.name,
    this.variety,
    this.purchaseDate,
    this.purchaseLocation,
    this.imagePath,
    this.wateringIntervalDays,
    this.nextWateringDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchaseLocation': purchaseLocation,
      'imagePath': imagePath,
      'wateringIntervalDays': wateringIntervalDays,
      'nextWateringDate': nextWateringDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      variety: map['variety'],
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'])
          : null,
      purchaseLocation: map['purchaseLocation'],
      imagePath: map['imagePath'],
      wateringIntervalDays: map['wateringIntervalDays'],
      nextWateringDate: map['nextWateringDate'] != null
          ? DateTime.parse(map['nextWateringDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Plant copyWith({
    String? name,
    String? variety,
    DateTime? purchaseDate,
    String? purchaseLocation,
    String? imagePath,
    int? wateringIntervalDays,
    DateTime? nextWateringDate,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      imagePath: imagePath ?? this.imagePath,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      nextWateringDate: nextWateringDate ?? this.nextWateringDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
