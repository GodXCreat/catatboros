import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyLineChart extends StatelessWidget {
  final Map<DateTime, int> data;
  const MonthlyLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 220,
      child: LineChart(LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 10000 : maxY * 1.2,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
        lineBarsData: [LineChartBarData(isCurved: true, barWidth: 4, dotData: const FlDotData(show: false), spots: [for (var i = 0; i < entries.length; i++) FlSpot(i.toDouble(), entries[i].value.toDouble())])],
      )),
    );
  }
}
