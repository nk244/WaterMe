import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  ViewMode get viewMode => _settings.viewMode;
  AppTheme get theme => _settings.theme;
  ThemePreference get themePreference => _settings.themePreference;
  bool get notificationEnabled => _settings.notificationEnabled;
  LogTypeColors get logTypeColors => _settings.logTypeColors;
  PlantSortOrder get plantSortOrder => _settings.plantSortOrder;
  List<String> get customSortOrder => _settings.customSortOrder;

  Future<void> loadSettings() async {
    _settings = await _settingsService.loadSettings();
    notifyListeners();
  }

  Future<void> setViewMode(ViewMode mode) async {
    _settings = _settings.copyWith(viewMode: mode);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference pref) async {
    _settings = _settings.copyWith(themePreference: pref);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    _settings = _settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await _settingsService.saveSettings(_settings);
    notifyListeners();
    // 通知が有効なら再スケジュール
    if (_settings.notificationEnabled && !kIsWeb) {
      await NotificationService().scheduleDailyWateringReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationEnabled: enabled);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
    if (!kIsWeb) {
      if (enabled) {
        // パーミッション確認してからスケジュール
        final granted = await NotificationService().requestPermission();
        if (granted) {
          await NotificationService().scheduleDailyWateringReminder(
            hour: _settings.notificationHour,
            minute: _settings.notificationMinute,
          );
        } else {
          // パーミッション拒否されたら設定を戻す
          _settings = _settings.copyWith(notificationEnabled: false);
          await _settingsService.saveSettings(_settings);
          notifyListeners();
        }
      } else {
        await NotificationService().cancelDailyWateringReminder();
      }
    }
  }

  Future<void> setLogTypeColors(LogTypeColors colors) async {
    _settings = _settings.copyWith(logTypeColors: colors);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setPlantSortOrder(PlantSortOrder order) async {
    _settings = _settings.copyWith(plantSortOrder: order);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setCustomSortOrder(List<String> order) async {
    _settings = _settings.copyWith(customSortOrder: order);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
}
