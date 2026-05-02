import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<Expense> expenses;
  
  const ExpenseBarChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, double> dailyTotals = {};
    
    for (var expense in expenses.where((e) => !e.isIncome)) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }
    
    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });
    
    final spots = <FlSpot>[];
    for (int i = 0; i < last7Days.length; i++) {
      final total = dailyTotals[last7Days[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), total));
    }
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10).toDouble(),
          barGroups: spots.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.y,
                  color: const Color(0xFF2196F3),
                  width: 20,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < last7Days.length) {
                    return Text(
                      '${last7Days[index].day}',
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}