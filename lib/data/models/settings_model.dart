class AppSettings {
  final bool autoSaveHistory;
  final bool showNotifications;

  AppSettings({
    this.autoSaveHistory = true,
    this.showNotifications = false,
  });

  AppSettings copyWith({
    bool? autoSaveHistory,
    bool? showNotifications,
  }) {
    return AppSettings(
      autoSaveHistory: autoSaveHistory ?? this.autoSaveHistory,
      showNotifications: showNotifications ?? this.showNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoSaveHistory': autoSaveHistory,
      'showNotifications': showNotifications,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      autoSaveHistory: map['autoSaveHistory'] as bool? ?? true,
      showNotifications: map['showNotifications'] as bool? ?? false,
    );
  }
}
