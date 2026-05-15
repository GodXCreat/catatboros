import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/category_model.dart';
import '../providers/app_provider.dart';
import '../utils/date_labels.dart';
import '../utils/money_formatter.dart';

class SettingsScreen extends StatefulWidget {
  final bool openBudget;
  const SettingsScreen({super.key, this.openBudget = false});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool openedBudget = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.openBudget && !openedBudget) {
      openedBudget = true;
      Future.microtask(() => _showBudgetDialog(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final settings = app.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        _Section(title: 'Tampilan', children: [
          DropdownButtonFormField<String>(value: settings.themeModeName, decoration: const InputDecoration(labelText: 'Mode tema'), items: const [DropdownMenuItem(value: 'system', child: Text('Auto ikut sistem')), DropdownMenuItem(value: 'light', child: Text('Light mode')), DropdownMenuItem(value: 'dark', child: Text('Dark mode'))], onChanged: (v) => app.saveSettings(settings.copyWith(themeModeName: v))),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(value: settings.fontScaleName, decoration: const InputDecoration(labelText: 'Ukuran font'), items: const [DropdownMenuItem(value: 'small', child: Text('Kecil')), DropdownMenuItem(value: 'normal', child: Text('Normal')), DropdownMenuItem(value: 'large', child: Text('Besar'))], onChanged: (v) => app.saveSettings(settings.copyWith(fontScaleName: v))),
        ]),
        _Section(title: 'Format', children: [
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Pemisah ribuan'), subtitle: Text(settings.thousandsSeparator == '.' ? '1.000' : '1,000'), trailing: Switch(value: settings.thousandsSeparator == '.', onChanged: (v) => app.saveSettings(settings.copyWith(thousandsSeparator: v ? '.' : ',')))),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Awal minggu hari Senin'), trailing: Switch(value: settings.weekStartsMonday, onChanged: (v) => app.saveSettings(settings.copyWith(weekStartsMonday: v)))),
        ]),
        _Section(title: 'Budget & Notifikasi', children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.savings_outlined), title: const Text('Budget bulanan'), subtitle: Text(app.currentBudget.totalBudget == 0 ? 'Belum diatur' : app.money(app.currentBudget.totalBudget)), onTap: () => _showBudgetDialog(context)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Notifikasi aktif'), value: settings.notificationsEnabled, onChanged: (v) => app.saveSettings(settings.copyWith(notificationsEnabled: v))),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Alert budget 80% dan terlampaui'), value: settings.budgetAlertsEnabled, onChanged: (v) => app.saveSettings(settings.copyWith(budgetAlertsEnabled: v))),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Ringkasan mingguan Minggu malam'), value: settings.weeklySummaryEnabled, onChanged: (v) => app.saveSettings(settings.copyWith(weeklySummaryEnabled: v))),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Notifikasi persistent + Catat'), value: settings.quickInputNotification, onChanged: (v) => app.saveSettings(settings.copyWith(quickInputNotification: v))),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Jam pengingat harian'), subtitle: Text(settings.dailyReminderTime), onTap: () => _pickReminderTime(context)),
        ]),
        _Section(title: 'Keamanan', children: [
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('PIN lock'), subtitle: Text(settings.pinEnabled ? 'Aktif' : 'Mati'), value: settings.pinEnabled, onChanged: (v) => v ? _setPin(context) : app.saveSettings(settings.copyWith(pinHash: '', biometricEnabled: false))),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Biometric lock'), subtitle: const Text('Fingerprint/biometrik perangkat'), value: settings.biometricEnabled, onChanged: (v) async { if (!v) { app.saveSettings(settings.copyWith(biometricEnabled: false)); } else if (await app.securityService.canUseBiometric()) { app.saveSettings(settings.copyWith(biometricEnabled: true)); } else if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrik tidak tersedia di perangkat ini.'))); } }),
          DropdownButtonFormField<int>(value: settings.autoLockMinutes, decoration: const InputDecoration(labelText: 'Auto lock setelah'), items: const [DropdownMenuItem(value: 1, child: Text('1 menit')), DropdownMenuItem(value: 5, child: Text('5 menit')), DropdownMenuItem(value: 15, child: Text('15 menit')), DropdownMenuItem(value: 30, child: Text('30 menit'))], onChanged: (v) => app.saveSettings(settings.copyWith(autoLockMinutes: v))),
        ]),
        _Section(title: 'Kategori', children: [
          ...app.categories.map((c) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text(c.icon)), title: Text(c.name), subtitle: Text(c.keywords.take(6).join(', ')), trailing: c.isDefault ? null : IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => app.removeCategory(c.id)), onTap: () => _editCategory(context, c))),
          OutlinedButton.icon(onPressed: () => _editCategory(context, null), icon: const Icon(Icons.add), label: const Text('Tambah kategori custom')),
        ]),
        _Section(title: 'Backup & Restore', children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.upload_file), title: const Text('Export JSON'), subtitle: const Text('Backup lengkap data lokal'), onTap: () => app.exportJson()),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.table_chart_outlined), title: const Text('Export CSV'), subtitle: const Text('Cocok dibuka di spreadsheet'), onTap: () => app.exportCsv()),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.restore), title: const Text('Import backup JSON'), subtitle: const Text('Mengganti data dengan isi file backup'), onTap: () => _confirmImport(context)),
          const Text('Backup otomatis dibuat harian saat aplikasi dibuka. File disimpan di folder Downloads jika sistem mengizinkan, jika tidak maka disimpan di folder aplikasi.'),
        ]),
      ]),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final app = context.read<AppProvider>();
    final controller = TextEditingController(text: app.currentBudget.totalBudget == 0 ? '' : app.currentBudget.totalBudget.toString());
    final value = await showDialog<int>(context: context, builder: (_) => AlertDialog(title: const Text('Set budget bulan ini'), content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ', labelText: 'Total budget')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, MoneyFormatter.parse(controller.text)), child: const Text('Simpan'))]));
    if (value != null && context.mounted) await app.saveBudget(Budget(monthKey: DateLabels.monthKey(DateTime.now()), totalBudget: value, categoryBudgets: app.currentBudget.categoryBudgets, updatedAt: DateTime.now()));
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final app = context.read<AppProvider>();
    final parts = app.settings.dailyReminderTime.split(':');
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 20, minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0));
    if (picked != null) await app.saveSettings(app.settings.copyWith(dailyReminderTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'));
  }

  Future<void> _setPin(BuildContext context) async {
    final app = context.read<AppProvider>();
    final controller = TextEditingController();
    final pin = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Buat PIN'), content: TextField(controller: controller, obscureText: true, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'PIN 4-6 digit')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Simpan'))]));
    if (pin != null && RegExp(r'^\d{4,6}$').hasMatch(pin)) await app.saveSettings(app.settings.copyWith(pinHash: app.securityService.hashPin(pin)));
  }

  Future<void> _editCategory(BuildContext context, ExpenseCategory? category) async {
    final app = context.read<AppProvider>();
    final name = TextEditingController(text: category?.name ?? '');
    final icon = TextEditingController(text: category?.icon ?? '📌');
    final keywords = TextEditingController(text: category?.keywords.join(', ') ?? '');
    final saved = await showDialog<ExpenseCategory>(context: context, builder: (_) => AlertDialog(title: Text(category == null ? 'Tambah kategori' : 'Edit kategori'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: icon, decoration: const InputDecoration(labelText: 'Icon emoji')), TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama kategori')), TextField(controller: keywords, decoration: const InputDecoration(labelText: 'Keyword, pisahkan koma'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () { final id = category?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}'; Navigator.pop(context, ExpenseCategory(id: id, name: name.text.trim().isEmpty ? 'Kategori Baru' : name.text.trim(), icon: icon.text.trim().isEmpty ? '📌' : icon.text.trim(), keywords: keywords.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(), colorValue: 0xFFE53935, isDefault: category?.isDefault ?? false, sortOrder: category?.sortOrder ?? 50)); }, child: const Text('Simpan'))]));
    if (saved != null) await app.saveCategory(saved);
  }

  Future<void> _confirmImport(BuildContext context) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Import backup?'), content: const Text('Data sekarang akan diganti dengan isi file backup JSON.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import'))]));
    if (ok == true && context.mounted) await context.read<AppProvider>().importJson();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 14), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 10), ...children])));
}
