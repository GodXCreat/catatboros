import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/date_labels.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/charts/category_pie_chart.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/summary_card.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final comparison = app.monthComparisonPercent();
    final monthData = app.categoryTotals(DateLabels.startOfMonth(DateTime.now()), DateLabels.nextMonth(DateTime.now()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatatBoros'),
        actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings_outlined))],
      ),
      body: RefreshIndicator(
        onRefresh: app.load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
          SummaryCard(title: 'Pengeluaran Hari Ini', value: app.money(app.totalToday()), icon: Icons.today_rounded, color: Theme.of(context).colorScheme.primary, subtitle: DateLabels.humanDay(DateTime.now())),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: SummaryCard(title: 'Minggu Ini', value: app.money(app.totalThisWeek()), icon: Icons.calendar_view_week, color: Colors.blue)),
            const SizedBox(width: 10),
            Expanded(child: SummaryCard(title: 'Bulan Ini', value: app.money(app.totalThisMonth()), icon: Icons.calendar_month, color: Colors.green, subtitle: comparison == null ? 'Belum ada bulan lalu' : '${comparison >= 0 ? 'Naik' : 'Turun'} ${comparison.abs().toStringAsFixed(1)}% vs bulan lalu')),
          ]),
          const SizedBox(height: 10),
          BudgetProgressCard(spent: app.totalThisMonth(), budget: app.currentBudget.totalBudget, spentText: app.money(app.totalThisMonth()), budgetText: app.money(app.currentBudget.totalBudget)),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('3 kategori terboros bulan ini', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (app.topCategoriesThisMonth().isEmpty) const Text('Belum ada transaksi bulan ini.') else ...app.topCategoriesThisMonth().map((e) => ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(e.key), trailing: Text(app.money(e.value), style: const TextStyle(fontWeight: FontWeight.w800)))),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Persentase kategori bulan ini', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), CategoryPieChart(data: monthData)]))),
          const SizedBox(height: 10),
          Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('7 hari terakhir', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), WeeklyBarChart(data: app.dailyTotals(days: 7))]))),
        ]),
      ),
    );
  }
}
