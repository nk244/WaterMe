import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  ViewMode get viewMode => _settings.viewMode;
  AppTheme get theme => _settings.theme;
  ThemePreference get themePreference => _settings.themePreference;
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
