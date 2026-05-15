import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryPicker extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;
  const CategoryPicker({super.key, required this.categories, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final active = category.id == selected.id;
        return ChoiceChip(
          label: Text('${category.icon} ${category.name}'),
          selected: active,
          onSelected: (_) => onChanged(category),
        );
      }).toList(),
    );
  }
}
