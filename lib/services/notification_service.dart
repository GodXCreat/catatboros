import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@drawable/ic_stat_catatboros');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder(String hhmm) async {
    await _plugin.cancel(10);
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    await _plugin.zonedSchedule(
      10,
      'Waktunya catat pengeluaran',
      'Biar tidak lupa, catat pengeluaran hari ini di CatatBoros.',
      _nextTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Pengingat Harian',
          channelDescription: 'Pengingat harian untuk mencatat pengeluaran.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklySummary() async {
    await _plugin.cancel(11);
    await _plugin.zonedSchedule(
      11,
      'Ringkasan mingguan CatatBoros',
      'Buka aplikasi untuk melihat kategori terboros minggu ini.',
      _nextSundayNight(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary',
          'Ringkasan Mingguan',
          channelDescription: 'Ringkasan pengeluaran mingguan.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelScheduled() async {
    await _plugin.cancel(10);
    await _plugin.cancel(11);
  }

  Future<void> showBudgetWarning(String message) async {
    await _plugin.show(20, 'Budget hampir habis', message, const NotificationDetails(android: AndroidNotificationDetails('budget_alerts', 'Alert Budget', channelDescription: 'Peringatan budget.', importance: Importance.high, priority: Priority.high)));
  }

  Future<void> showBudgetExceeded(String message) async {
    await _plugin.show(
      21,
      'Budget terlampaui',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Alert Budget',
          channelDescription: 'Peringatan saat budget terlampaui.',
          importance: Importance.max,
          priority: Priority.max,
          vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
        ),
      ),
    );
  }

  Future<void> showQuickInputNotification() async {
    await _plugin.show(
      30,
      'CatatBoros aktif',
      'Ketuk untuk cepat mencatat pengeluaran.',
      const NotificationDetails(
        android: AndroidNotificationDetails('quick_input', 'Quick Input', channelDescription: 'Shortcut cepat CatatBoros.', importance: Importance.low, priority: Priority.low, ongoing: true, autoCancel: false),
      ),
      payload: 'quick_input',
    );
  }

  Future<void> hideQuickInputNotification() => _plugin.cancel(30);

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  tz.TZDateTime _nextSundayNight() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
    while (scheduled.weekday != DateTime.sunday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
