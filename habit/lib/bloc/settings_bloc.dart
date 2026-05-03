import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:habit/models/category.dart';
import '../models/user_settings.dart';
import '../utils/database_helper.dart';

// Events
abstract class SettingsEvent {}
class LoadSettings extends SettingsEvent {}
class ToggleDarkMode extends SettingsEvent { final bool value; ToggleDarkMode(this.value); }
class ChangeThemeColor extends SettingsEvent { final int color; ChangeThemeColor(this.color); }
class TogglePasswordLock extends SettingsEvent { final bool value; TogglePasswordLock(this.value); }
class ChangeLanguage extends SettingsEvent { final String language; ChangeLanguage(this.language); }
class ChangeFirstDay extends SettingsEvent { final int day; ChangeFirstDay(this.day); }
class Toggle24HourFormat extends SettingsEvent { final bool value; Toggle24HourFormat(this.value); }
class ToggleVibration extends SettingsEvent { final bool value; ToggleVibration(this.value); }
class ToggleCompletionSound extends SettingsEvent { final bool value; ToggleCompletionSound(this.value); }
class ToggleGoalAchievedSound extends SettingsEvent { final bool value; ToggleGoalAchievedSound(this.value); }
class ChangeAlarmTone extends SettingsEvent { final String tone; ChangeAlarmTone(this.tone); }
class ToggleHideCompleted extends SettingsEvent { final bool value; ToggleHideCompleted(this.value); }
class UpdateCategories extends SettingsEvent { final List<Category> categories; UpdateCategories(this.categories); }
class ReorderHabits extends SettingsEvent { final List<String> order; ReorderHabits(this.order); }
class ChangeDefaultScreen extends SettingsEvent { final String screen; ChangeDefaultScreen(this.screen); }
class ChangeCurrencySymbol extends SettingsEvent { final String symbol; ChangeCurrencySymbol(this.symbol); }
class ChangeUsdToUzs extends SettingsEvent { final double rate; ChangeUsdToUzs(this.rate); }
class ToggleAutoBackup extends SettingsEvent { final bool value; ToggleAutoBackup(this.value); }
class ToggleNotifications extends SettingsEvent { final bool value; ToggleNotifications(this.value); }
class ChangeReminderTime extends SettingsEvent { final String time; ChangeReminderTime(this.time); }

// States
abstract class SettingsState {}
class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  SettingsLoaded(this.settings);
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ChangeThemeColor>(_onChangeThemeColor);
    on<TogglePasswordLock>(_onTogglePasswordLock);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeFirstDay>(_onChangeFirstDay);
    on<Toggle24HourFormat>(_onToggle24HourFormat);
    on<ToggleVibration>(_onToggleVibration);
    on<ToggleCompletionSound>(_onToggleCompletionSound);
    on<ToggleGoalAchievedSound>(_onToggleGoalAchievedSound);
    on<ChangeAlarmTone>(_onChangeAlarmTone);
    on<ToggleHideCompleted>(_onToggleHideCompleted);
    on<UpdateCategories>(_onUpdateCategories);
    on<ReorderHabits>(_onReorderHabits);
    on<ChangeDefaultScreen>(_onChangeDefaultScreen);
    on<ChangeCurrencySymbol>(_onChangeCurrencySymbol);
    on<ChangeUsdToUzs>(_onChangeUsdToUzs);
    on<ToggleAutoBackup>(_onToggleAutoBackup);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ChangeReminderTime>(_onChangeReminderTime);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final settings = await DatabaseHelper.instance.getSettings();
    emit(SettingsLoaded(settings));
  }

  Future<void> _updateSettings(SettingsState state, UserSettings newSettings, Emitter<SettingsState> emit) async {
    await DatabaseHelper.instance.updateSettings(newSettings);
    emit(SettingsLoaded(newSettings));
  }

  Future<void> _onToggleDarkMode(ToggleDarkMode event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(darkMode: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeThemeColor(ChangeThemeColor event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(themeColor: event.color);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onTogglePasswordLock(TogglePasswordLock event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(passwordLock: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(language: event.language);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeFirstDay(ChangeFirstDay event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(firstDayOfWeek: event.day);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggle24HourFormat(Toggle24HourFormat event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(use24HourFormat: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleVibration(ToggleVibration event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(vibrateOnTap: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleCompletionSound(ToggleCompletionSound event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(completionSound: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleGoalAchievedSound(ToggleGoalAchievedSound event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(goalAchievedSound: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeAlarmTone(ChangeAlarmTone event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(alarmTone: event.tone);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleHideCompleted(ToggleHideCompleted event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(hideCompletedActivities: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onUpdateCategories(UpdateCategories event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(customCategories: event.categories);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onReorderHabits(ReorderHabits event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(habitOrder: event.order);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeDefaultScreen(ChangeDefaultScreen event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(defaultScreen: event.screen);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeCurrencySymbol(ChangeCurrencySymbol event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(currencySymbol: event.symbol);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeUsdToUzs(ChangeUsdToUzs event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(usdToUzs: event.rate);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleAutoBackup(ToggleAutoBackup event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(autoBackup: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onToggleNotifications(ToggleNotifications event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(notificationsEnabled: event.value);
      await _updateSettings(state, newSettings, emit);
    }
  }

  Future<void> _onChangeReminderTime(ChangeReminderTime event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final newSettings = (state as SettingsLoaded).settings.copyWith(reminderTime: event.time);
      await _updateSettings(state, newSettings, emit);
    }
  }
}

// Extension for copyWith
extension UserSettingsCopyWith on UserSettings {
  UserSettings copyWith({
    bool? darkMode,
    int? themeColor,
    bool? passwordLock,
    String? language,
    int? firstDayOfWeek,
    bool? use24HourFormat,
    bool? vibrateOnTap,
    bool? completionSound,
    bool? goalAchievedSound,
    String? alarmTone,
    bool? hideCompletedActivities,
    List<Category>? customCategories,
    List<String>? habitOrder,
    String? defaultScreen,
    String? currencySymbol,
    double? usdToUzs,
    bool? autoBackup,
    bool? notificationsEnabled,
    String? reminderTime,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      themeColor: themeColor ?? this.themeColor,
      passwordLock: passwordLock ?? this.passwordLock,
      language: language ?? this.language,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      vibrateOnTap: vibrateOnTap ?? this.vibrateOnTap,
      completionSound: completionSound ?? this.completionSound,
      goalAchievedSound: goalAchievedSound ?? this.goalAchievedSound,
      alarmTone: alarmTone ?? this.alarmTone,
    hideCompletedActivities: hideCompletedActivities ?? this.hideCompletedActivities,
    customCategories: customCategories ?? this.customCategories,
    habitOrder: habitOrder ?? this.habitOrder,
      defaultScreen: defaultScreen ?? this.defaultScreen,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      usdToUzs: usdToUzs ?? this.usdToUzs,
      autoBackup: autoBackup ?? this.autoBackup,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}