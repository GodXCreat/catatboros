import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, int> data;
  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('Belum ada data kategori.')));
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.cyan, Colors.indigo, Colors.brown, Colors.grey];
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Column(children: [
      SizedBox(
        height: 220,
        child: PieChart(PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 48,
          sections: [
            for (var i = 0; i < entries.length; i++)
              PieChartSectionData(
                value: entries[i].value.toDouble(),
                color: colors[i % colors.length],
                radius: 58,
                title: '${((entries[i].value / total) * 100).toStringAsFixed(0)}%',
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
          ],
        )),
      ),
      Wrap(spacing: 10, runSpacing: 6, children: [
        for (var i = 0; i < entries.length; i++)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(entries[i].key, style: Theme.of(context).textTheme.bodySmall),
          ]),
      ]),
    ]);
  }
}
