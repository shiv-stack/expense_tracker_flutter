import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Chart"),
        backgroundColor: const Color(0xFF1A8E74),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state.totalIncome == 0 && state.totalExpenses == 0) {
            return const Center(
              child: Text("No data available to display."),
            );
          }

          final total = state.totalIncome + state.totalExpenses;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Income vs Expenses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: state.totalIncome,
                          title:
                              '${((state.totalIncome / total) * 100).toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: state.totalExpenses,
                          title:
                              '${((state.totalExpenses / total) * 100).toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegend("Income", Colors.green),
                    _buildLegend("Expenses", Colors.red),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
