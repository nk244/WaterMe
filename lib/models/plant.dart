class Plant {
  final String id;
  final String name;
  final String? variety;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final String? imagePath;
  final int? wateringIntervalDays;
  // 肥料間隔（日数指定 / 水やりN回に1回 どちらか一方のみ設定）
  final int? fertilizerIntervalDays;
  final int? fertilizerEveryNWaterings;
  // 活力剤間隔（同上）
  final int? vitalizerIntervalDays;
  final int? vitalizerEveryNWaterings;
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
    this.fertilizerIntervalDays,
    this.fertilizerEveryNWaterings,
    this.vitalizerIntervalDays,
    this.vitalizerEveryNWaterings,
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
      'fertilizerIntervalDays': fertilizerIntervalDays,
      'fertilizerEveryNWaterings': fertilizerEveryNWaterings,
      'vitalizerIntervalDays': vitalizerIntervalDays,
      'vitalizerEveryNWaterings': vitalizerEveryNWaterings,
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
      fertilizerIntervalDays: map['fertilizerIntervalDays'],
      fertilizerEveryNWaterings: map['fertilizerEveryNWaterings'],
      vitalizerIntervalDays: map['vitalizerIntervalDays'],
      vitalizerEveryNWaterings: map['vitalizerEveryNWaterings'],
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
    Object? fertilizerIntervalDays = _sentinel,
    Object? fertilizerEveryNWaterings = _sentinel,
    Object? vitalizerIntervalDays = _sentinel,
    Object? vitalizerEveryNWaterings = _sentinel,
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
      fertilizerIntervalDays: fertilizerIntervalDays == _sentinel
          ? this.fertilizerIntervalDays
          : fertilizerIntervalDays as int?,
      fertilizerEveryNWaterings: fertilizerEveryNWaterings == _sentinel
          ? this.fertilizerEveryNWaterings
          : fertilizerEveryNWaterings as int?,
      vitalizerIntervalDays: vitalizerIntervalDays == _sentinel
          ? this.vitalizerIntervalDays
          : vitalizerIntervalDays as int?,
      vitalizerEveryNWaterings: vitalizerEveryNWaterings == _sentinel
          ? this.vitalizerEveryNWaterings
          : vitalizerEveryNWaterings as int?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

const Object _sentinel = Object();
