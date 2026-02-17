import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  ViewMode get viewMode => _settings.viewMode;
  AppTheme get theme => _settings.theme;

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

  Future<void> setNotificationTime(int hour, int minute) async {
    _settings = _settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
}
