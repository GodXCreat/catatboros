import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String amountText;
  final VoidCallback onTap;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  const ExpenseTile({super.key, required this.expense, required this.amountText, required this.onTap, this.confirmDismiss});

  @override
  Widget build(BuildContext context) {
    final tile = Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(child: Text(expense.categoryIcon)),
        title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${expense.categoryName} • ${DateFormat('HH:mm').format(expense.spentAt)}${expense.note.isNotEmpty ? ' • ${expense.note}' : ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(amountText, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        onTap: onTap,
      ),
    );
    return Dismissible(
      key: ValueKey('expense-${expense.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: confirmDismiss,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: tile,
    );
  }
}
