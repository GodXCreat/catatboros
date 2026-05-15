import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/app_provider.dart';
import '../utils/date_labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import 'edit_expense_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final queryController = TextEditingController();
  String categoryId = 'all';
  String sort = 'terbaru';
  DateTimeRange? range;

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final list = app.filteredExpenses(query: queryController.text, categoryId: categoryId, start: range?.start, end: range?.end, sort: sort);
    final grouped = app.groupedByDay(list);
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditExpenseScreen())), icon: const Icon(Icons.add))]),
      body: RefreshIndicator(
        onRefresh: app.load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
          TextField(controller: queryController, decoration: const InputDecoration(hintText: 'Cari transaksi...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            DropdownButton<String>(value: categoryId, items: [const DropdownMenuItem(value: 'all', child: Text('Semua kategori')), ...app.categories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${c.name}')))], onChanged: (v) => setState(() => categoryId = v ?? 'all')),
            const SizedBox(width: 12),
            DropdownButton<String>(value: sort, items: const [DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')), DropdownMenuItem(value: 'terlama', child: Text('Terlama')), DropdownMenuItem(value: 'terbesar', child: Text('Terbesar')), DropdownMenuItem(value: 'terkecil', child: Text('Terkecil'))], onChanged: (v) => setState(() => sort = v ?? 'terbaru')),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: _pickRange, icon: const Icon(Icons.date_range), label: Text(range == null ? 'Rentang tanggal' : '${DateLabels.dayKey(range!.start)} - ${DateLabels.dayKey(range!.end)}')),
            if (range != null) IconButton(onPressed: () => setState(() => range = null), icon: const Icon(Icons.close)),
          ])),
          const SizedBox(height: 10),
          if (list.isEmpty) const SizedBox(height: 430, child: EmptyState(title: 'Belum ada transaksi', message: 'Mulai catat pengeluaran dari tab Catat.')),
          for (final entry in grouped.entries) _DayGroup(dayKey: entry.key, expenses: entry.value),
        ]),
      ),
    );
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: now.add(const Duration(days: 1)), initialDateRange: range ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now));
    if (picked != null) setState(() => range = picked);
  }
}

class _DayGroup extends StatelessWidget {
  final String dayKey;
  final List<Expense> expenses;
  const _DayGroup({required this.dayKey, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final date = DateTime.parse(dayKey);
    final total = expenses.fold<int>(0, (a, b) => a + b.amount);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Row(children: [
          Expanded(child: Text('${DateLabels.humanDay(date)} • ${app.money(total)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
          TextButton(onPressed: () => _deleteDay(context, date), child: const Text('Hapus hari')),
        ]),
      ),
      ...expenses.map((e) => ExpenseTile(
            expense: e,
            amountText: app.money(e.amount),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e))),
            confirmDismiss: (_) async {
              final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Hapus transaksi?'), content: Text(e.title), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus'))]));
              if (ok == true) await context.read<AppProvider>().deleteExpense(e.id!);
              return ok;
            },
          )),
    ]);
  }

  Future<void> _deleteDay(BuildContext context, DateTime day) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Hapus semua transaksi hari ini?'), content: Text(DateLabels.humanDay(day)), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus'))]));
    if (ok == true && context.mounted) await context.read<AppProvider>().deleteDay(day);
  }
}
