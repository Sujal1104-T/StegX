import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stegx/data/settings_service.dart';
import 'package:stegx/data/models/settings_model.dart';

// Settings service provider
final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService) : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    state = settings;
  }

  Future<void> updateAutoSaveHistory(bool value) async {
    state = state.copyWith(autoSaveHistory: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateShowNotifications(bool value) async {
    state = state.copyWith(showNotifications: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> resetSettings() async {
    await _settingsService.clearSettings();
    state = AppSettings();
  }
}

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsServiceProvider));
});
