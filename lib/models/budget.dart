import 'dart:convert';

class Budget {
  final String monthKey;
  final int totalBudget;
  final Map<String, int> categoryBudgets;
  final DateTime updatedAt;

  const Budget({
    required this.monthKey,
    required this.totalBudget,
    required this.categoryBudgets,
    required this.updatedAt,
  });

  Budget copyWith({String? monthKey, int? totalBudget, Map<String, int>? categoryBudgets, DateTime? updatedAt}) {
    return Budget(
      monthKey: monthKey ?? this.monthKey,
      totalBudget: totalBudget ?? this.totalBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'month_key': monthKey,
        'total_budget': totalBudget,
        'category_budgets': jsonEncode(categoryBudgets),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Budget.fromMap(Map<String, dynamic> map) {
    final raw = jsonDecode((map['category_budgets'] as String?) ?? '{}') as Map<String, dynamic>;
    return Budget(
      monthKey: map['month_key'] as String,
      totalBudget: (map['total_budget'] as int?) ?? 0,
      categoryBudgets: raw.map((key, value) => MapEntry(key, (value as num).toInt())),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Budget empty(String monthKey) => Budget(
        monthKey: monthKey,
        totalBudget: 0,
        categoryBudgets: const {},
        updatedAt: DateTime.now(),
      );
}
