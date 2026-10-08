import 'package:flutter/material.dart';
import 'package:job_application_tracker/app/app.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  final themeModeString = await storageService.loadThemeMode();
  ThemeMode initialThemeMode = ThemeMode.dark;
  if (themeModeString == 'system') {
    initialThemeMode = ThemeMode.system;
  } else if (themeModeString == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (themeModeString == 'dark') {
    initialThemeMode = ThemeMode.dark;
  }
  
  runApp(App(initialThemeMode: initialThemeMode));
}
