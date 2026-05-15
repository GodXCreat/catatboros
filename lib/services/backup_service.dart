import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import 'database_service.dart';

class BackupService {
  final DatabaseService databaseService;
  BackupService(this.databaseService);

  Future<File> exportJson({bool share = true}) async {
    final data = await databaseService.exportAll();
    final file = await _createFile('catatboros-backup-${_stamp()}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    if (share) await Share.shareXFiles([XFile(file.path)], text: 'Backup CatatBoros');
    return file;
  }

  Future<File> exportCsv(List<Expense> expenses, {bool share = true}) async {
    final rows = <List<dynamic>>[
      ['id', 'tanggal', 'jam', 'nama', 'kategori', 'nominal', 'catatan'],
      ...expenses.map((e) => [e.id ?? '', DateFormat('yyyy-MM-dd').format(e.spentAt), DateFormat('HH:mm').format(e.spentAt), e.title, e.categoryName, e.amount, e.note]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final file = await _createFile('catatboros-export-${_stamp()}.csv');
    await file.writeAsString(csv);
    if (share) await Share.shareXFiles([XFile(file.path)], text: 'Export CSV CatatBoros');
    return file;
  }

  Future<void> importJsonFromPicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    await databaseService.importAll(data);
  }

  Future<File?> autoBackupIfNeeded(String lastBackupDate) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastBackupDate == today) return null;
    return exportJson(share: false);
  }

  Future<File> _createFile(String fileName) async {
    final downloadDir = Directory('/storage/emulated/0/Download');
    final dir = await downloadDir.exists() ? downloadDir : await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  String _stamp() => DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
}
