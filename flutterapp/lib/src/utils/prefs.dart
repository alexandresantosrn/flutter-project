import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  final bool notifications;
  final String selectedTime;
  final bool darkMode;
  final int lessonSize;

  const SettingsData({
    required this.notifications,
    required this.selectedTime,
    required this.darkMode,
    required this.lessonSize,
  });

  SettingsData copyWith({
    bool? notifications,
    String? selectedTime,
    bool? darkMode,
    int? lessonSize,
  }) {
    return SettingsData(
      notifications: notifications ?? this.notifications,
      selectedTime: selectedTime ?? this.selectedTime,
      darkMode: darkMode ?? this.darkMode,
      lessonSize: lessonSize ?? this.lessonSize,
    );
  }
}

class SettingsPrefs {
  static const _kNotifications = 'settings_notifications';
  static const _kSelectedTime = 'settings_selected_time';
  static const _kDarkMode = 'settings_dark_mode';
  static const _kLessonSize = 'settings_lesson_size';

  // valores padrão
  static const SettingsData defaults = SettingsData(
    notifications: true,
    selectedTime: '12:00',
    darkMode: false,
    lessonSize: 5,
  );

  static Future<SettingsData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsData(
      notifications: prefs.getBool(_kNotifications) ?? defaults.notifications,
      selectedTime: prefs.getString(_kSelectedTime) ?? defaults.selectedTime,
      darkMode: prefs.getBool(_kDarkMode) ?? defaults.darkMode,
      lessonSize: prefs.getInt(_kLessonSize) ?? defaults.lessonSize,
    );
  }

  static Future<void> save(SettingsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, data.notifications);
    await prefs.setString(_kSelectedTime, data.selectedTime);
    await prefs.setBool(_kDarkMode, data.darkMode);
    await prefs.setInt(_kLessonSize, data.lessonSize);
  }

  // métodos auxiliares para salvar valores individuais
  static Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
  }

  static Future<void> setSelectedTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedTime, time);
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  static Future<void> setLessonSize(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLessonSize, value);
  }
}
