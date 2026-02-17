enum ViewMode {
  list,
  card,
}

enum AppTheme {
  green,
  blue,
  purple,
  orange,
}

enum PlantSortOrder {
  nameAsc,           // 名前昇順
  nameDesc,          // 名前降順
  purchaseDateDesc,  // 購入日が新しい順
  purchaseDateAsc,   // 購入日が古い順
  custom,            // ユーザー指定
}

class LogTypeColors {
  final int wateringBg;
  final int wateringFg;
  final int fertilizerBg;
  final int fertilizerFg;
  final int vitalizerBg;
  final int vitalizerFg;

  LogTypeColors({
    this.wateringBg = 0xFFBBDEFB,    // Colors.blue.shade100
    this.wateringFg = 0xFF0D47A1,    // Colors.blue.shade900
    this.fertilizerBg = 0xFFC8E6C9,  // Colors.green.shade100
    this.fertilizerFg = 0xFF1B5E20,  // Colors.green.shade900
    this.vitalizerBg = 0xFFFFECB3,   // Colors.amber.shade100
    this.vitalizerFg = 0xFFFF6F00,   // Colors.amber.shade900
  });

  Map<String, dynamic> toMap() {
    return {
      'wateringBg': wateringBg,
      'wateringFg': wateringFg,
      'fertilizerBg': fertilizerBg,
      'fertilizerFg': fertilizerFg,
      'vitalizerBg': vitalizerBg,
      'vitalizerFg': vitalizerFg,
    };
  }

  factory LogTypeColors.fromMap(Map<String, dynamic> map) {
    return LogTypeColors(
      wateringBg: map['wateringBg'] ?? 0xFFBBDEFB,
      wateringFg: map['wateringFg'] ?? 0xFF0D47A1,
      fertilizerBg: map['fertilizerBg'] ?? 0xFFC8E6C9,
      fertilizerFg: map['fertilizerFg'] ?? 0xFF1B5E20,
      vitalizerBg: map['vitalizerBg'] ?? 0xFFFFECB3,
      vitalizerFg: map['vitalizerFg'] ?? 0xFFFF6F00,
    );
  }

  LogTypeColors copyWith({
    int? wateringBg,
    int? wateringFg,
    int? fertilizerBg,
    int? fertilizerFg,
    int? vitalizerBg,
    int? vitalizerFg,
  }) {
    return LogTypeColors(
      wateringBg: wateringBg ?? this.wateringBg,
      wateringFg: wateringFg ?? this.wateringFg,
      fertilizerBg: fertilizerBg ?? this.fertilizerBg,
      fertilizerFg: fertilizerFg ?? this.fertilizerFg,
      vitalizerBg: vitalizerBg ?? this.vitalizerBg,
      vitalizerFg: vitalizerFg ?? this.vitalizerFg,
    );
  }
}

class AppSettings {
  final ViewMode viewMode;
  final AppTheme theme;
  final int notificationHour;
  final int notificationMinute;
  final LogTypeColors logTypeColors;
  final PlantSortOrder plantSortOrder;
  final List<String> customSortOrder;

  AppSettings({
    this.viewMode = ViewMode.card,
    this.theme = AppTheme.green,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    LogTypeColors? logTypeColors,
    this.plantSortOrder = PlantSortOrder.nameAsc,
    this.customSortOrder = const [],
  }) : logTypeColors = logTypeColors ?? LogTypeColors();

  Map<String, dynamic> toMap() {
    return {
      'viewMode': viewMode.name,
      'theme': theme.name,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'logTypeColors': logTypeColors.toMap(),
      'plantSortOrder': plantSortOrder.name,
      'customSortOrder': customSortOrder,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      viewMode: ViewMode.values.firstWhere(
        (e) => e.name == map['viewMode'],
        orElse: () => ViewMode.card,
      ),
      theme: AppTheme.values.firstWhere(
        (e) => e.name == map['theme'],
        orElse: () => AppTheme.green,
      ),
      notificationHour: map['notificationHour'] ?? 9,
      notificationMinute: map['notificationMinute'] ?? 0,
      logTypeColors: map['logTypeColors'] != null
          ? LogTypeColors.fromMap(map['logTypeColors'])
          : LogTypeColors(),
      plantSortOrder: PlantSortOrder.values.firstWhere(
        (e) => e.name == map['plantSortOrder'],
        orElse: () => PlantSortOrder.nameAsc,
      ),
      customSortOrder: map['customSortOrder'] != null
          ? List<String>.from(map['customSortOrder'])
          : [],
    );
  }

  AppSettings copyWith({
    ViewMode? viewMode,
    AppTheme? theme,
    int? notificationHour,
    int? notificationMinute,
    LogTypeColors? logTypeColors,
    PlantSortOrder? plantSortOrder,
    List<String>? customSortOrder,
  }) {
    return AppSettings(
      viewMode: viewMode ?? this.viewMode,
      theme: theme ?? this.theme,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      logTypeColors: logTypeColors ?? this.logTypeColors,
      plantSortOrder: plantSortOrder ?? this.plantSortOrder,
      customSortOrder: customSortOrder ?? this.customSortOrder,
    );
  }
}
