import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    super.key,
    required this.transactions,
    required this.formatter,
  });

  final List<ExpenseTransaction> transactions;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final expenseMap = <String, double>{};
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      expenseMap[tx.category] = (expenseMap[tx.category] ?? 0) + tx.amount;
    }

    if (expenseMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = expenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                  sections: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    return PieChartSectionData(
                      value: entry.value,
                      color: colors[i % colors.length],
                      title: '${max(1, (entry.value / total * 100).round())}%',
                      radius: 54,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(entries.length, (i) {
              final entry = entries[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(formatter.format(entry.value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
