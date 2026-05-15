import 'dart:convert';
import 'package:flutter/material.dart';

class AppSettings {
  final bool firstRun;
  final String currencySymbol;
  final String thousandsSeparator;
  final bool weekStartsMonday;
  final String themeModeName;
  final String fontScaleName;
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final bool budgetAlertsEnabled;
  final bool weeklySummaryEnabled;
  final bool quickInputNotification;
  final String pinHash;
  final bool biometricEnabled;
  final int autoLockMinutes;
  final String lastAutoBackupDate;

  const AppSettings({
    required this.firstRun,
    required this.currencySymbol,
    required this.thousandsSeparator,
    required this.weekStartsMonday,
    required this.themeModeName,
    required this.fontScaleName,
    required this.notificationsEnabled,
    required this.dailyReminderTime,
    required this.budgetAlertsEnabled,
    required this.weeklySummaryEnabled,
    required this.quickInputNotification,
    required this.pinHash,
    required this.biometricEnabled,
    required this.autoLockMinutes,
    required this.lastAutoBackupDate,
  });

  static AppSettings defaults() => const AppSettings(
        firstRun: true,
        currencySymbol: 'Rp',
        thousandsSeparator: '.',
        weekStartsMonday: true,
        themeModeName: 'system',
        fontScaleName: 'normal',
        notificationsEnabled: true,
        dailyReminderTime: '20:00',
        budgetAlertsEnabled: true,
        weeklySummaryEnabled: true,
        quickInputNotification: false,
        pinHash: '',
        biometricEnabled: false,
        autoLockMinutes: 5,
        lastAutoBackupDate: '',
      );

  bool get pinEnabled => pinHash.isNotEmpty;
  bool get securityEnabled => pinEnabled || biometricEnabled;

  ThemeMode get themeMode {
    switch (themeModeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  double get fontScale {
    switch (fontScaleName) {
      case 'small':
        return 0.92;
      case 'large':
        return 1.14;
      default:
        return 1.0;
    }
  }

  AppSettings copyWith({
    bool? firstRun,
    String? currencySymbol,
    String? thousandsSeparator,
    bool? weekStartsMonday,
    String? themeModeName,
    String? fontScaleName,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? budgetAlertsEnabled,
    bool? weeklySummaryEnabled,
    bool? quickInputNotification,
    String? pinHash,
    bool? biometricEnabled,
    int? autoLockMinutes,
    String? lastAutoBackupDate,
  }) {
    return AppSettings(
      firstRun: firstRun ?? this.firstRun,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      thousandsSeparator: thousandsSeparator ?? this.thousandsSeparator,
      weekStartsMonday: weekStartsMonday ?? this.weekStartsMonday,
      themeModeName: themeModeName ?? this.themeModeName,
      fontScaleName: fontScaleName ?? this.fontScaleName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      quickInputNotification: quickInputNotification ?? this.quickInputNotification,
      pinHash: pinHash ?? this.pinHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      lastAutoBackupDate: lastAutoBackupDate ?? this.lastAutoBackupDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstRun': firstRun,
        'currencySymbol': currencySymbol,
        'thousandsSeparator': thousandsSeparator,
        'weekStartsMonday': weekStartsMonday,
        'themeModeName': themeModeName,
        'fontScaleName': fontScaleName,
        'notificationsEnabled': notificationsEnabled,
        'dailyReminderTime': dailyReminderTime,
        'budgetAlertsEnabled': budgetAlertsEnabled,
        'weeklySummaryEnabled': weeklySummaryEnabled,
        'quickInputNotification': quickInputNotification,
        'pinHash': pinHash,
        'biometricEnabled': biometricEnabled,
        'autoLockMinutes': autoLockMinutes,
        'lastAutoBackupDate': lastAutoBackupDate,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final base = AppSettings.defaults();
    return AppSettings(
      firstRun: (json['firstRun'] as bool?) ?? base.firstRun,
      currencySymbol: (json['currencySymbol'] as String?) ?? base.currencySymbol,
      thousandsSeparator: (json['thousandsSeparator'] as String?) ?? base.thousandsSeparator,
      weekStartsMonday: (json['weekStartsMonday'] as bool?) ?? base.weekStartsMonday,
      themeModeName: (json['themeModeName'] as String?) ?? base.themeModeName,
      fontScaleName: (json['fontScaleName'] as String?) ?? base.fontScaleName,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? base.notificationsEnabled,
      dailyReminderTime: (json['dailyReminderTime'] as String?) ?? base.dailyReminderTime,
      budgetAlertsEnabled: (json['budgetAlertsEnabled'] as bool?) ?? base.budgetAlertsEnabled,
      weeklySummaryEnabled: (json['weeklySummaryEnabled'] as bool?) ?? base.weeklySummaryEnabled,
      quickInputNotification: (json['quickInputNotification'] as bool?) ?? base.quickInputNotification,
      pinHash: (json['pinHash'] as String?) ?? base.pinHash,
      biometricEnabled: (json['biometricEnabled'] as bool?) ?? base.biometricEnabled,
      autoLockMinutes: (json['autoLockMinutes'] as int?) ?? base.autoLockMinutes,
      lastAutoBackupDate: (json['lastAutoBackupDate'] as String?) ?? base.lastAutoBackupDate,
    );
  }

  String encode() => jsonEncode(toJson());
  factory AppSettings.decode(String raw) => AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
