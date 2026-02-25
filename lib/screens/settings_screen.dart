import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // Theme settings
          _buildSectionHeader(context, 'テーマ'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: [
                  // Theme mode (system/light/dark)
                  RadioListTile<ThemePreference>(
                    title: const Text('システムに従う'),
                    value: ThemePreference.system,
                    groupValue: settings.themePreference,
                    onChanged: (v) => settings.setThemePreference(v!),
                  ),
                  RadioListTile<ThemePreference>(
                    title: const Text('ライトモード'),
                    value: ThemePreference.light,
                    groupValue: settings.themePreference,
                    onChanged: (v) => settings.setThemePreference(v!),
                  ),
                  RadioListTile<ThemePreference>(
                    title: const Text('ダークモード'),
                    value: ThemePreference.dark,
                    groupValue: settings.themePreference,
                    onChanged: (v) => settings.setThemePreference(v!),
                  ),
                  const Divider(),
                  // Color theme selection
                  ...AppTheme.values.map((theme) {
                    return RadioListTile<AppTheme>(
                      title: Text(_getThemeName(theme)),
                      value: theme,
                      groupValue: settings.theme,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setTheme(value);
                        }
                      },
                      secondary: Icon(
                        Icons.palette,
                        color: _getThemeColor(theme),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
          const Divider(),

          // Notification settings
          _buildSectionHeader(context, '通知設定'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('水やりリマインダー'),
                    subtitle: const Text('毎日指定した時刻に通知します'),
                    value: settings.notificationEnabled,
                    onChanged: (v) => settings.setNotificationEnabled(v),
                  ),
                  if (settings.notificationEnabled)
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('通知時刻'),
                      subtitle: Text(
                        '${settings.settings.notificationHour.toString().padLeft(2, '0')}:${settings.settings.notificationMinute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: settings.settings.notificationHour,
                            minute: settings.settings.notificationMinute,
                          ),
                        );
                        if (time != null) {
                          settings.setNotificationTime(time.hour, time.minute);
                        }
                      },
                    ),
                ],
              );
            },
          ),
          const Divider(),

          // Data management
          _buildSectionHeader(context, 'データ管理'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('データをエクスポート'),
            subtitle: const Text('すべてのデータをファイルに保存'),
            onTap: () {
              // TODO: Export data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('エクスポート機能は準備中です')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('データをインポート'),
            subtitle: const Text('ファイルからデータを復元'),
            onTap: () {
              // TODO: Import data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('インポート機能は準備中です')),
              );
            },
          ),
          const Divider(),

          // About
          _buildSectionHeader(context, 'アプリについて'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('バージョン'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('開発情報'),
            subtitle: const Text('Flutter製の水やり管理アプリ'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'WaterMe',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.eco, size: 48),
                children: const [
                  Text('植物の水やりを管理するためのアプリです。'),
                  SizedBox(height: 8),
                  Text('水やりの記録、リマインダー、日記機能を提供します。'),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.green:
        return 'グリーン';
      case AppTheme.blue:
        return 'ブルー';
      case AppTheme.purple:
        return 'パープル';
      case AppTheme.orange:
        return 'オレンジ';
    }
  }

  Color _getThemeColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.green:
        return Colors.green;
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.purple:
        return Colors.purple;
      case AppTheme.orange:
        return Colors.orange;
    }
  }
}
