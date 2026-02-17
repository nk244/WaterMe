import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      return AppSettings();
    }
    
    try {
      final Map<String, dynamic> map = json.decode(settingsJson);
      return AppSettings.fromMap(map);
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = json.encode(settings.toMap());
    await prefs.setString(_settingsKey, settingsJson);
  }
}
