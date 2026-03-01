import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';

/// アプリ設定を SharedPreferences に繼続保存するサービス。
class SettingsService {
  static const String _settingsKey = 'app_settings';

  /// 保存済み設定を読み込む。未保存の場合はデフォルト値を返す。
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
      // パース失敗時はデフォルト値で復帰
      return AppSettings();
    }
  }

  /// 設定を保存する。
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = json.encode(settings.toMap());
    await prefs.setString(_settingsKey, settingsJson);
  }
}
