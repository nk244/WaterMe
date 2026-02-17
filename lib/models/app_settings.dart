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

class AppSettings {
  final ViewMode viewMode;
  final AppTheme theme;
  final int notificationHour;
  final int notificationMinute;

  AppSettings({
    this.viewMode = ViewMode.card,
    this.theme = AppTheme.green,
    this.notificationHour = 9,
    this.notificationMinute = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'viewMode': viewMode.name,
      'theme': theme.name,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
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
    );
  }

  AppSettings copyWith({
    ViewMode? viewMode,
    AppTheme? theme,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return AppSettings(
      viewMode: viewMode ?? this.viewMode,
      theme: theme ?? this.theme,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }
}
