import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/app_provider.dart';
import '../utils/date_labels.dart';
import '../utils/money_formatter.dart';
import '../widgets/charts/category_pie_chart.dart';
import '../widgets/charts/monthly_line_chart.dart';
import 'settings_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String range = 'month';
  DateTimeRange? customRange;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final resolved = _range();
    final expenses = app.expensesBetween(resolved.start, resolved.end);
    final total = expenses.fold<int>(0, (a, b) => a + b.amount);
    final categoryTotals = app.categoryTotals(resolved.start, resolved.end);
    final biggest = [...expenses]..sort((a, b) => b.amount.compareTo(a.amount));
    final dayTotals = <DateTime, int>{};
    for (var d = DateLabels.startOfDay(resolved.start); d.isBefore(resolved.end); d = d.add(const Duration(days: 1))) {
      dayTotals[d] = app.totalBetween(d, d.add(const Duration(days: 1)));
    }
    final borosDay = dayTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final average = dayTotals.isEmpty ? 0 : total ~/ dayTotals.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen(openBudget: true))), icon: const Icon(Icons.savings_outlined))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('Minggu ini'), selected: range == 'week', onSelected: (_) => setState(() => range = 'week')),
          ChoiceChip(label: const Text('Bulan ini'), selected: range == 'month', onSelected: (_) => setState(() => range = 'month')),
          ChoiceChip(label: const Text('3 bulan'), selected: range == '3month', onSelected: (_) => setState(() => range = '3month')),
          ChoiceChip(label: const Text('Custom'), selected: range == 'custom', onSelected: (_) => _pickCustomRange()),
        ]),
        const SizedBox(height: 12),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _InfoRow(label: 'Total pengeluaran', value: app.money(total)),
          _InfoRow(label: 'Rata-rata per hari', value: app.money(average)),
          _InfoRow(label: 'Hari paling boros', value: borosDay.isEmpty || borosDay.first.value == 0 ? '-' : '${DateLabels.humanDay(borosDay.first.key)} (${app.money(borosDay.first.value)})'),
          _InfoRow(label: 'Transaksi terbesar', value: biggest.isEmpty ? '-' : '${biggest.first.title} (${app.money(biggest.first.amount)})'),
        ]))),
        const SizedBox(height: 10),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tren pengeluaran', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), MonthlyLineChart(data: dayTotals)]))),
        const SizedBox(height: 10),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Breakdown kategori', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), CategoryPieChart(data: categoryTotals), const SizedBox(height: 10), ...categoryTotals.entries.map((e) => _InfoRow(label: e.key, value: '${app.money(e.value)} • ${total == 0 ? 0 : ((e.value / total) * 100).toStringAsFixed(1)}%'))]))),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: () => _showBudgetDialog(context, app), icon: const Icon(Icons.savings_outlined), label: const Text('Set Budget Bulanan')),
      ]),
    );
  }

  DateTimeRange _range() {
    final now = DateTime.now();
    if (range == 'week') {
      final start = DateLabels.startOfWeek(now, true);
      return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
    }
    if (range == '3month') return DateTimeRange(start: DateTime(now.year, now.month - 2), end: DateLabels.nextMonth(now));
    if (range == 'custom' && customRange != null) return DateTimeRange(start: customRange!.start, end: customRange!.end.add(const Duration(days: 1)));
    return DateTimeRange(start: DateLabels.startOfMonth(now), end: DateLabels.nextMonth(now));
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: now.add(const Duration(days: 1)), initialDateRange: customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now));
    if (picked != null) setState(() { range = 'custom'; customRange = picked; });
  }

  Future<void> _showBudgetDialog(BuildContext context, AppProvider app) async {
    final controller = TextEditingController(text: app.currentBudget.totalBudget == 0 ? '' : app.currentBudget.totalBudget.toString());
    final value = await showDialog<int>(context: context, builder: (_) => AlertDialog(title: const Text('Set budget bulan ini'), content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ', labelText: 'Total budget')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, MoneyFormatter.parse(controller.text)), child: const Text('Simpan'))]));
    if (value != null && context.mounted) await app.saveBudget(Budget(monthKey: DateLabels.monthKey(DateTime.now()), totalBudget: value, categoryBudgets: app.currentBudget.categoryBudgets, updatedAt: DateTime.now()));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label)), const SizedBox(width: 10), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800)))]));
}
