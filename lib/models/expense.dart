class Expense {
  final int? id;
  final String title;
  final int amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final DateTime spentAt;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.spentAt,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    int? id,
    String? title,
    int? amount,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? spentAt,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_icon': categoryIcon,
        'spent_at': spentAt.toIso8601String(),
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      categoryIcon: map['category_icon'] as String,
      spentAt: DateTime.parse(map['spent_at'] as String),
      note: (map['note'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
