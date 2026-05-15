import '../models/category_model.dart';
import '../utils/category_catalog.dart';

class SmartInputResult {
  final bool isValid;
  final String originalText;
  final String title;
  final int amount;
  final String rawAmount;
  final ExpenseCategory category;
  final String error;
  final double confidence;

  const SmartInputResult({
    required this.isValid,
    required this.originalText,
    required this.title,
    required this.amount,
    required this.rawAmount,
    required this.category,
    this.error = '',
    this.confidence = 0,
  });
}

class SmartInputParser {
  static final RegExp _amountRegex = RegExp(
    r'(?:rp\s*)?(\d+(?:[\.,]\d{1,3})*(?:[\.,]\d+)?|\d+)\s*(k|rb|ribu)?',
    caseSensitive: false,
  );

  SmartInputResult parse(String text, List<ExpenseCategory> categories) {
    final original = text.trim();
    final fallbackCategory = CategoryCatalog.fallback(categories);
    if (original.isEmpty) {
      return SmartInputResult(
        isValid: false,
        originalText: original,
        title: '',
        amount: 0,
        rawAmount: '',
        category: fallbackCategory,
        error: 'Tulis pengeluaran dulu, misalnya: kopi 8k',
      );
    }

    final matches = _amountRegex.allMatches(original).where((m) {
      final token = m.group(0) ?? '';
      return RegExp(r'\d').hasMatch(token);
    }).toList();

    if (matches.isEmpty) {
      return SmartInputResult(
        isValid: false,
        originalText: original,
        title: _smartTitle(original),
        amount: 0,
        rawAmount: '',
        category: _detectCategory(original, categories).category,
        error: 'Nominal belum terdeteksi. Contoh: 15k, 15rb, 15000, 15.000, 15ribu.',
      );
    }

    final amountMatch = matches.last;
    final rawAmount = amountMatch.group(0)!.trim();
    final amount = _parseAmount(amountMatch.group(1)!, amountMatch.group(2));

    if (amount <= 0) {
      return SmartInputResult(
        isValid: false,
        originalText: original,
        title: _smartTitle(original),
        amount: 0,
        rawAmount: rawAmount,
        category: fallbackCategory,
        error: 'Nominal harus lebih dari 0.',
      );
    }

    var titleRaw = original.replaceRange(amountMatch.start, amountMatch.end, ' ');
    titleRaw = titleRaw.replaceAll(RegExp(r'\brp\b', caseSensitive: false), ' ');
    titleRaw = titleRaw.replaceAll(RegExp(r'\s+'), ' ').trim();
    final detection = _detectCategory(titleRaw.isEmpty ? original : titleRaw, categories);

    return SmartInputResult(
      isValid: true,
      originalText: original,
      title: _smartTitle(titleRaw.isEmpty ? detection.category.name : titleRaw),
      amount: amount,
      rawAmount: rawAmount,
      category: detection.category,
      confidence: detection.confidence,
    );
  }

  int _parseAmount(String numberPart, String? suffix) {
    final normalizedSuffix = (suffix ?? '').toLowerCase().trim();
    var cleaned = numberPart.trim().toLowerCase();
    if (normalizedSuffix.isNotEmpty) {
      cleaned = cleaned.replaceAll(',', '.');
      final isDecimal = RegExp(r'^\d+[\.]\d{1,2}$').hasMatch(cleaned);
      final number = isDecimal ? double.parse(cleaned) : double.parse(cleaned.replaceAll(RegExp(r'[\.,]'), ''));
      return (number * 1000).round();
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  ({ExpenseCategory category, double confidence}) _detectCategory(String text, List<ExpenseCategory> categories) {
    final normalized = ' ${text.toLowerCase()} ';
    ExpenseCategory? best;
    var bestScore = 0;
    for (final category in categories) {
      var score = 0;
      for (final keyword in category.keywords) {
        final k = keyword.toLowerCase().trim();
        if (k.isEmpty) continue;
        if (normalized.contains(' $k ')) {
          score += 4;
        } else if (normalized.contains(k)) {
          score += 2;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = category;
      }
    }
    final fallback = CategoryCatalog.fallback(categories);
    if (best == null || bestScore == 0) return (category: fallback, confidence: 0.3);
    return (category: best, confidence: (0.55 + bestScore / 20).clamp(0.55, 0.98));
  }

  String _smartTitle(String raw) {
    final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (trimmed.isEmpty) return 'Pengeluaran';
    return trimmed
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
