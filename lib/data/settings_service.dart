import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stegx/data/models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _firstLaunchKey = 'first_launch';

  // Load settings
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson == null) {
        return AppSettings(); // Return defaults
      }
      
      final map = jsonDecode(settingsJson) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (e) {
      return AppSettings(); // Return defaults on error
    }
  }

  // Save settings
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toMap());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw Exception('Failed to save settings: ${e.toString()}');
    }
  }

  // Check if first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  // Mark first launch as complete
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  // Clear all settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}
