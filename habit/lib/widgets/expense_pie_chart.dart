import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  
  const ExpensePieChart({super.key, required this.expenses, required this.categories});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};
    
    for (var expense in expenses.where((e) => !e.isIncome)) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    
    final List<PieChartSectionData> sections = [];
    // ignore: unused_local_variable
    int index = 0;
    
    for (var entry in categoryTotals.entries) {
      final category = categories.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => Category(name: entry.key, icon: 'more_horiz', color: 0xFF9E9E9E, type: 'expense'),
      );
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
      
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          color: Color(category.color),
        ),
      );
      index++;
    }
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}