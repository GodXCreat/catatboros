import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/smart_input_parser.dart';
import '../utils/date_labels.dart';
import '../widgets/category_picker.dart';

class SmartInputScreen extends StatefulWidget {
  const SmartInputScreen({super.key});
  @override
  State<SmartInputScreen> createState() => _SmartInputScreenState();
}

class _SmartInputScreenState extends State<SmartInputScreen> {
  final inputController = TextEditingController();
  final noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  SmartInputResult? result;
  dynamic manualCategory;

  @override
  void dispose() {
    inputController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final parsed = inputController.text.trim().isEmpty ? null : app.preview(inputController.text);
    result = parsed == null || manualCategory == null || parsed.isValid == false
        ? parsed
        : SmartInputResult(isValid: true, originalText: parsed.originalText, title: parsed.title, amount: parsed.amount, rawAmount: parsed.rawAmount, category: manualCategory, confidence: parsed.confidence);
    final active = result?.isValid == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Cepat')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
        Text('Tulis bebas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(
          controller: inputController,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: 'Contoh: mie ayam 15k', border: OutlineInputBorder(), prefixIcon: Icon(Icons.auto_awesome)),
          onChanged: (_) => setState(() => manualCategory = null),
          onSubmitted: (_) => active ? _save() : null,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: ['kopi 8k', 'bensin 50rb', 'listrik 150k'].map((e) => ActionChip(label: Text(e), onPressed: () => setState(() => inputController.text = e))).toList()),
        const SizedBox(height: 18),
        if (result != null) _PreviewCard(result: result!, money: app.money(result!.amount), selectedDate: selectedDate, onPickDate: _pickDate),
        const SizedBox(height: 14),
        if (result?.isValid == true) ...[
          TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Catatan tambahan opsional', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          Text('Ubah kategori bila perlu', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          CategoryPicker(categories: app.categories, selected: result!.category, onChanged: (cat) {
            setState(() {
              manualCategory = cat;
            });
          }),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Simpan Pengeluaran')),
        ],
      ]),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
    if (picked != null) setState(() => selectedDate = DateTime(picked.year, picked.month, picked.day, selectedDate.hour, selectedDate.minute));
  }

  Future<void> _save() async {
    final app = context.read<AppProvider>();
    final parsed = result ?? app.preview(inputController.text);
    if (!parsed.isValid) return;
    await app.addExpense(title: parsed.title, amount: parsed.amount, category: parsed.category, spentAt: selectedDate, note: noteController.text.trim());
    if (!mounted) return;
    setState(() {
      inputController.clear();
      noteController.clear();
      result = null;
      manualCategory = null;
      selectedDate = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengeluaran berhasil disimpan.')));
  }
}

class _PreviewCard extends StatelessWidget {
  final SmartInputResult result;
  final String money;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  const _PreviewCard({required this.result, required this.money, required this.selectedDate, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    if (!result.isValid) return Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Text(result.error, style: TextStyle(color: Theme.of(context).colorScheme.error))));
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Preview sebelum simpan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text(result.category.icon)), title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${result.category.name} • keyakinan ${(result.confidence * 100).toStringAsFixed(0)}%'), trailing: Text(money, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
          OutlinedButton.icon(onPressed: onPickDate, icon: const Icon(Icons.calendar_today), label: Text('${DateLabels.humanDay(selectedDate)} • ${DateFormat('HH:mm').format(selectedDate)}')),
        ]),
      ),
    );
  }
}
