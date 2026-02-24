import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/plant_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/note_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_themes.dart';
import 'models/app_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          // Map ThemePreference to Flutter ThemeMode
          ThemeMode mode;
          switch (settingsProvider.themePreference) {
            case ThemePreference.light:
              mode = ThemeMode.light;
              break;
            case ThemePreference.dark:
              mode = ThemeMode.dark;
              break;
            case ThemePreference.system:
            default:
              mode = ThemeMode.system;
              break;
          }

          return MaterialApp(
            title: 'WaterMe',
            theme: AppThemes.getLightTheme(settingsProvider.theme),
            darkTheme: AppThemes.getDarkTheme(settingsProvider.theme),
            themeMode: mode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
