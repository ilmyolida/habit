import 'package:flutter/material.dart';
import 'category.dart';

class UserSettings {
  bool darkMode;
  int themeColor;
  bool passwordLock;
  String language;
  int firstDayOfWeek;
  bool use24HourFormat;
  bool vibrateOnTap;
  bool completionSound;
  bool goalAchievedSound;
  String alarmTone;
  bool hideCompletedActivities;
  List<Category> customCategories;
  List<String> habitOrder;
  String defaultScreen;
  String currencySymbol;
  double usdToUzs;
  bool autoBackup;
  bool notificationsEnabled;
  String reminderTime;

  UserSettings({
    required this.darkMode,
    required this.themeColor,
    required this.passwordLock,
    required this.language,
    required this.firstDayOfWeek,
    required this.use24HourFormat,
    required this.vibrateOnTap,
    required this.completionSound,
    required this.goalAchievedSound,
    required this.alarmTone,
    required this.hideCompletedActivities,
    required this.customCategories,
    required this.habitOrder,
    required this.defaultScreen,
    required this.currencySymbol,
    required this.usdToUzs,
    required this.autoBackup,
    required this.notificationsEnabled,
    required this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'darkMode': darkMode ? 1 : 0,
      'themeColor': themeColor,
      'passwordLock': passwordLock ? 1 : 0,
      'language': language,
      'firstDayOfWeek': firstDayOfWeek,
      'use24HourFormat': use24HourFormat ? 1 : 0,
      'vibrateOnTap': vibrateOnTap ? 1 : 0,
      'completionSound': completionSound ? 1 : 0,
      'goalAchievedSound': goalAchievedSound ? 1 : 0,
      'alarmTone': alarmTone,
      'hideCompletedActivities': hideCompletedActivities ? 1 : 0,
      'customCategories': _encodeCategories(customCategories),
      'habitOrder': habitOrder.join(','),
      'defaultScreen': defaultScreen,
      'currencySymbol': currencySymbol,
      'usdToUzs': usdToUzs,
      'autoBackup': autoBackup ? 1 : 0,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'reminderTime': reminderTime,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      darkMode: map['darkMode'] == 1,
      themeColor: map['themeColor'],
      passwordLock: map['passwordLock'] == 1,
      language: map['language'],
      firstDayOfWeek: map['firstDayOfWeek'],
      use24HourFormat: map['use24HourFormat'] == 1,
      vibrateOnTap: map['vibrateOnTap'] == 1,
      completionSound: map['completionSound'] == 1,
      goalAchievedSound: map['goalAchievedSound'] == 1,
      alarmTone: map['alarmTone'],
      hideCompletedActivities: map['hideCompletedActivities'] == 1,
      customCategories: _decodeCategories(map['customCategories']),
      habitOrder: map['habitOrder'].toString().split(','),
      defaultScreen: map['defaultScreen'],
      currencySymbol: map['currencySymbol'] ?? 'so\'m',
      usdToUzs: map['usdToUzs'] ?? 12800.0,
      autoBackup: map['autoBackup'] == 1,
      notificationsEnabled: map['notificationsEnabled'] == 1,
      reminderTime: map['reminderTime'] ?? '09:00',
    );
  }

  static String _encodeCategories(List<Category> categories) {
    if (categories.isEmpty) return '';
    return categories.map((c) => '${c.name}|${c.icon}|${c.color}|${c.type}').join(';');
  }

  static List<Category> _decodeCategories(String data) {
    if (data.isEmpty) return [];
    return data.split(';').map((e) {
      final parts = e.split('|');
      if (parts.length < 4) return null;
      return Category(
        name: parts[0],
        icon: parts[1],
        color: int.parse(parts[2]),
        type: parts[3],
      );
    }).whereType<Category>().toList();
  }
}