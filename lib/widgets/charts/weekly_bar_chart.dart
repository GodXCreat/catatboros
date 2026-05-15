import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<DateTime, int> data;
  const WeeklyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 220,
      child: BarChart(BarChartData(
        maxY: maxY == 0 ? 10000 : maxY * 1.25,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= entries.length) return const SizedBox.shrink();
            return Padding(padding: const EdgeInsets.only(top: 6), child: Text(DateFormat('E', 'id_ID').format(entries[index].key), style: const TextStyle(fontSize: 11)));
          })),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: entries[i].value.toDouble(), width: 18, borderRadius: BorderRadius.circular(8))])
        ],
      )),
    );
  }
}
