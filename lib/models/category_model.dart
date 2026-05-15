import 'dart:convert';
import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final List<String> keywords;
  final int colorValue;
  final bool isDefault;
  final int sortOrder;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.keywords,
    required this.colorValue,
    required this.isDefault,
    required this.sortOrder,
  });

  Color get color => Color(colorValue);

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? icon,
    List<String>? keywords,
    int? colorValue,
    bool? isDefault,
    int? sortOrder,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      keywords: keywords ?? this.keywords,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'keywords': jsonEncode(keywords),
        'color': colorValue,
        'is_default': isDefault ? 1 : 0,
        'sort_order': sortOrder,
      };

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      keywords: List<String>.from(jsonDecode(map['keywords'] as String)),
      colorValue: map['color'] as int,
      isDefault: (map['is_default'] as int) == 1,
      sortOrder: map['sort_order'] as int,
    );
  }
}
