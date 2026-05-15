import 'package:flutter/material.dart';

class BudgetProgressCard extends StatelessWidget {
  final int spent;
  final int budget;
  final String spentText;
  final String budgetText;
  const BudgetProgressCard({super.key, required this.spent, required this.budget, required this.spentText, required this.budgetText});

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget > 0;
    final progress = hasBudget ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final over = hasBudget && spent > budget;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.savings_outlined),
            const SizedBox(width: 10),
            Text('Budget Bulanan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          Text(hasBudget ? '$spentText dari $budgetText' : 'Budget belum diatur'),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(99), color: over ? Colors.red : Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(hasBudget ? (over ? 'Budget sudah terlampaui.' : 'Terpakai ${(progress * 100).toStringAsFixed(0)}%.') : 'Atur budget di tab Pengaturan/Laporan.', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}
