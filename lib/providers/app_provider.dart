import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/category_model.dart';
import '../models/expense.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/security_service.dart';
import '../services/smart_input_parser.dart';
import '../services/widget_service.dart';
import '../utils/date_labels.dart';
import '../utils/money_formatter.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final BackupService backupService;
  final SecurityService securityService;
  final WidgetService widgetService;
  final SmartInputParser parser = SmartInputParser();

  AppProvider({
    required this.databaseService,
    required this.notificationService,
    required this.backupService,
    required this.securityService,
    required this.widgetService,
  });

  bool isLoading = true;
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  AppSettings settings = AppSettings.defaults();
  Budget currentBudget = Budget.empty(DateLabels.monthKey(DateTime.now()));

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _categories = await databaseService.getCategories();
    _expenses = await databaseService.getExpenses();
    settings = await databaseService.getSettings();
    currentBudget = await databaseService.getBudget(DateLabels.monthKey(DateTime.now()));
    await _syncNotifications();
    await _autoBackup();
    await _updateWidget();
    isLoading = false;
    notifyListeners();
  }

  SmartInputResult preview(String text) => parser.parse(text, _categories);

  Future<void> addExpense({required String title, required int amount, required ExpenseCategory category, required DateTime spentAt, String note = ''}) async {
    final now = DateTime.now();
    await databaseService.insertExpense(Expense(
      title: title,
      amount: amount,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
      spentAt: spentAt,
      note: note,
      createdAt: now,
      updatedAt: now,
    ));
    await _reloadAfterChange(checkBudget: true);
  }

  Future<void> updateExpense(Expense expense) async {
    await databaseService.updateExpense(expense.copyWith(updatedAt: DateTime.now()));
    await _reloadAfterChange(checkBudget: true);
  }

  Future<void> deleteExpense(int id) async {
    await databaseService.deleteExpense(id);
    await _reloadAfterChange();
  }

  Future<void> deleteDay(DateTime day) async {
    await databaseService.deleteExpensesByDay(day);
    await _reloadAfterChange();
  }

  Future<void> saveCategory(ExpenseCategory category) async {
    await databaseService.upsertCategory(category);
    _categories = await databaseService.getCategories();
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    await databaseService.deleteCategory(id);
    await _reloadAfterChange();
  }

  Future<void> saveSettings(AppSettings newSettings) async {
    settings = newSettings;
    await databaseService.saveSettings(settings);
    await _syncNotifications();
    await _updateWidget();
    notifyListeners();
  }

  Future<void> finishOnboarding({int? firstBudget}) async {
    if (firstBudget != null && firstBudget > 0) {
      await saveBudget(currentBudget.copyWith(totalBudget: firstBudget, updatedAt: DateTime.now()));
    }
    await saveSettings(settings.copyWith(firstRun: false));
  }

  Future<void> saveBudget(Budget budget) async {
    currentBudget = budget.copyWith(updatedAt: DateTime.now());
    await databaseService.saveBudget(currentBudget);
    notifyListeners();
  }

  Future<void> exportJson() => backupService.exportJson();
  Future<void> exportCsv() => backupService.exportCsv(_expenses);
  Future<void> importJson() async {
    await backupService.importJsonFromPicker();
    await load();
  }

  int totalToday() => totalBetween(DateLabels.startOfDay(DateTime.now()), DateLabels.endOfDay(DateTime.now()));

  int totalThisWeek() {
    final start = DateLabels.startOfWeek(DateTime.now(), settings.weekStartsMonday);
    return totalBetween(start, start.add(const Duration(days: 7)));
  }

  int totalThisMonth() {
    final now = DateTime.now();
    return totalBetween(DateLabels.startOfMonth(now), DateLabels.nextMonth(now));
  }

  int totalPreviousMonth() {
    final prev = DateLabels.previousMonth(DateTime.now());
    return totalBetween(DateLabels.startOfMonth(prev), DateLabels.nextMonth(prev));
  }

  double? monthComparisonPercent() {
    final current = totalThisMonth();
    final previous = totalPreviousMonth();
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  int totalBetween(DateTime start, DateTime end) {
    return _expenses.where((e) => !e.spentAt.isBefore(start) && e.spentAt.isBefore(end)).fold(0, (sum, e) => sum + e.amount);
  }

  List<Expense> expensesBetween(DateTime start, DateTime end) {
    return _expenses.where((e) => !e.spentAt.isBefore(start) && e.spentAt.isBefore(end)).toList();
  }

  Map<String, int> categoryTotals(DateTime start, DateTime end) {
    final map = <String, int>{};
    for (final e in expensesBetween(start, end)) {
      map[e.categoryName] = (map[e.categoryName] ?? 0) + e.amount;
    }
    return map;
  }

  List<MapEntry<String, int>> topCategoriesThisMonth({int limit = 3}) {
    final now = DateTime.now();
    final list = categoryTotals(DateLabels.startOfMonth(now), DateLabels.nextMonth(now)).entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }

  Map<DateTime, int> dailyTotals({required int days}) {
    final today = DateLabels.startOfDay(DateTime.now());
    final map = <DateTime, int>{};
    for (var i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      map[day] = totalBetween(day, day.add(const Duration(days: 1)));
    }
    return map;
  }

  SplayTreeMap<String, List<Expense>> groupedByDay(List<Expense> list) {
    final grouped = SplayTreeMap<String, List<Expense>>((a, b) => b.compareTo(a));
    for (final e in list) {
      grouped.putIfAbsent(DateLabels.dayKey(e.spentAt), () => []).add(e);
    }
    return grouped;
  }

  List<Expense> filteredExpenses({String query = '', String categoryId = 'all', DateTime? start, DateTime? end, int? minAmount, int? maxAmount, String sort = 'terbaru'}) {
    final q = query.trim().toLowerCase();
    var list = _expenses.where((e) {
      final matchesQuery = q.isEmpty || e.title.toLowerCase().contains(q) || e.note.toLowerCase().contains(q) || e.categoryName.toLowerCase().contains(q);
      final matchesCategory = categoryId == 'all' || e.categoryId == categoryId;
      final matchesStart = start == null || !e.spentAt.isBefore(start);
      final matchesEnd = end == null || e.spentAt.isBefore(end.add(const Duration(days: 1)));
      final matchesMin = minAmount == null || e.amount >= minAmount;
      final matchesMax = maxAmount == null || e.amount <= maxAmount;
      return matchesQuery && matchesCategory && matchesStart && matchesEnd && matchesMin && matchesMax;
    }).toList();
    switch (sort) {
      case 'terlama':
        list.sort((a, b) => a.spentAt.compareTo(b.spentAt));
        break;
      case 'terbesar':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'terkecil':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        list.sort((a, b) => b.spentAt.compareTo(a.spentAt));
    }
    return list;
  }

  String money(int value) => MoneyFormatter.format(value, symbol: settings.currencySymbol, separator: settings.thousandsSeparator);

  Future<void> _reloadAfterChange({bool checkBudget = false}) async {
    _expenses = await databaseService.getExpenses();
    _categories = await databaseService.getCategories();
    currentBudget = await databaseService.getBudget(DateLabels.monthKey(DateTime.now()));
    await _updateWidget();
    if (checkBudget) await _checkBudgetNotification();
    notifyListeners();
  }

  Future<void> _syncNotifications() async {
    if (!settings.notificationsEnabled) {
      await notificationService.cancelScheduled();
      await notificationService.hideQuickInputNotification();
      return;
    }
    await notificationService.scheduleDailyReminder(settings.dailyReminderTime);
    if (settings.weeklySummaryEnabled) await notificationService.scheduleWeeklySummary();
    if (settings.quickInputNotification) {
      await notificationService.showQuickInputNotification();
    } else {
      await notificationService.hideQuickInputNotification();
    }
  }

  Future<void> _checkBudgetNotification() async {
    if (!settings.notificationsEnabled || !settings.budgetAlertsEnabled || currentBudget.totalBudget <= 0) return;
    final spent = totalThisMonth();
    final ratio = spent / currentBudget.totalBudget;
    if (ratio >= 1) {
      await notificationService.showBudgetExceeded('Pengeluaran bulan ini sudah ${money(spent)} dari budget ${money(currentBudget.totalBudget)}.');
    } else if (ratio >= 0.8) {
      await notificationService.showBudgetWarning('Pengeluaran bulan ini sudah ${(ratio * 100).toStringAsFixed(0)}% dari budget.');
    }
  }

  Future<void> _autoBackup() async {
    final file = await backupService.autoBackupIfNeeded(settings.lastAutoBackupDate);
    if (file != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      settings = settings.copyWith(lastAutoBackupDate: today);
      await databaseService.saveSettings(settings);
    }
  }

  Future<void> _updateWidget() async {
    await widgetService.updateTodayTotal(total: money(totalToday()), subtitle: 'Pengeluaran hari ini');
  }
}
