import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/expense.dart';
import '../providers/app_provider.dart';
import '../utils/money_formatter.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const EditExpenseScreen({super.key, this.expense});
  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  late final TextEditingController noteController;
  late DateTime spentAt;
  ExpenseCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    titleController = TextEditingController(text: e?.title ?? '');
    amountController = TextEditingController(text: e == null ? '' : e.amount.toString());
    noteController = TextEditingController(text: e?.note ?? '');
    spentAt = e?.spentAt ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    selectedCategory ??= app.categories.firstWhere((c) => c.id == widget.expense?.categoryId, orElse: () => app.categories.last);
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Tambah Transaksi' : 'Edit Transaksi')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: titleController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nama item', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Nominal', prefixText: '${app.settings.currencySymbol} ', border: const OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<ExpenseCategory>(
          value: selectedCategory,
          items: app.categories.map((c) => DropdownMenuItem(value: c, child: Text('${c.icon} ${c.name}'))).toList(),
          onChanged: (v) => setState(() => selectedCategory = v),
          decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(controller: noteController, maxLines: 2, decoration: const InputDecoration(labelText: 'Catatan tambahan', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _pickDateTime, icon: const Icon(Icons.calendar_month), label: Text(DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID').format(spentAt))),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Simpan')),
        if (widget.expense != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _delete, icon: const Icon(Icons.delete), label: const Text('Hapus transaksi')),
        ],
      ]),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(context: context, initialDate: spentAt, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(spentAt));
    if (time == null) return;
    setState(() => spentAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final app = context.read<AppProvider>();
    final category = selectedCategory;
    final amount = MoneyFormatter.parse(amountController.text);
    if (titleController.text.trim().isEmpty || amount <= 0 || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi nama, nominal, dan kategori.')));
      return;
    }
    if (widget.expense == null) {
      await app.addExpense(title: titleController.text.trim(), amount: amount, category: category, spentAt: spentAt, note: noteController.text.trim());
    } else {
      await app.updateExpense(widget.expense!.copyWith(title: titleController.text.trim(), amount: amount, categoryId: category.id, categoryName: category.name, categoryIcon: category.icon, spentAt: spentAt, note: noteController.text.trim()));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Hapus transaksi?'), content: const Text('Data transaksi ini akan dihapus dari perangkat.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus'))]));
    if (ok == true && mounted) {
      await context.read<AppProvider>().deleteExpense(widget.expense!.id!);
      if (mounted) Navigator.pop(context);
    }
  }
}
