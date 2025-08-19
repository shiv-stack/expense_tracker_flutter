import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/constants/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
// If you're using google_fonts, make sure to import it
// import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = DateTime.now().month.toString().padLeft(2, '0');

  final List<String> _tabs = [
    "Income vs Expense (Pie)",
    "Balance Over Time",
    "Top Expenses",
    "Yearly Summary",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getMonthName(int monthNumber) {
    const monthNames = [
      '', // 0-indexed, so index 1 is Jan, 2 is Feb, etc.
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (monthNumber >= 1 && monthNumber <= 12) {
      return monthNames[monthNumber];
    }
    return ''; // Or handle invalid input appropriately
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reports",
          // style: GoogleFonts.poppins(fontWeight: FontWeight.w600), // Uncomment if you have google_fonts
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.onPrimary), // Default style
        ),
        backgroundColor: primaryColor,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        // Removed filter icon from AppBar
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
          indicatorColor: colors.onPrimary,
          indicatorWeight: 3,
          tabs: _tabs.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No data available to display.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Ensure selectedYear is valid (this logic remains relevant)
          final years = state.monthlyDataByYear.keys.toList()..sort();
          if (!years.contains(selectedYear) && years.isNotEmpty) {
            selectedYear = years.last; // Default to the most recent year if current isn't available
          } else if (years.isEmpty) {
            selectedYear = DateTime.now().year.toString(); // Fallback if no years exist
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverallPieChart(state),
              _buildMonthlyBalanceChart(state),
              _buildTopExpensesPieChart(state),
              _buildYearlySummaryTable(state),
            ],
          );
        },
      ),
    );
  }

  // New helper widget for the dropdown filters, to be used within each tab's content
  Widget _buildFilterDropdowns(ExpenseState state, {required bool showMonthFilter}) {
    final years = state.monthlyDataByYear.keys.toList()..sort();
    final months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedYear = val;
                  });
                }
              },
              items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
          ),
          if (showMonthFilter) ...[
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedMonth = val;
                    });
                  }
                },
                items: months.map((e) => DropdownMenuItem(value: e, child: Text(_getMonthName(int.parse(e))))).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallPieChart(ExpenseState state) {
    // Filter data for the selected month and year
    final transactionsForMonth = state.transactions.where((t) {
      return t.date.year.toString() == selectedYear && t.date.month.toString().padLeft(2, '0') == selectedMonth;
    }).toList();

    final income = transactionsForMonth.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactionsForMonth.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
    final total = income + expense;

    List<PieChartSectionData> sections = [];
    if (income > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.green.shade600,
          value: income,
          title: '${((income / total) * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
          badgeWidget: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
          badgePositionPercentageOffset: 1.2,
        ),
      );
    }
    if (expense > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.red.shade600,
          value: expense,
          title: '${((expense / total) * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
          badgeWidget: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
          badgePositionPercentageOffset: 1.2,
        ),
      );
    }

    if (sections.isEmpty) {
      return Column(
        // Wrap in column to include filter
        children: [
          _buildFilterDropdowns(state, showMonthFilter: true), // Show year and month filters
          const Expanded(child: Center(child: Text("No income or expense data for Pie Chart in the selected period."))),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterDropdowns(state, showMonthFilter: true), // Show year and month filters
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Income vs Expenses (${_getMonthName(int.parse(selectedMonth))} $selectedYear)",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 8,
                          centerSpaceRadius: 60,
                          sections: sections,
                          borderData: FlBorderData(show: false),
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  return;
                                }
                                // You can add interactive feedback here if needed
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildOverallPieLegend(income, expense),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallPieLegend(double income, double expense) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green.shade600, 'Income', income.formatWithCommas()),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.red.shade600, 'Expense', expense.formatWithCommas()),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text('$title: $value'),
      ],
    );
  }

  Widget _buildMonthlyBalanceChart(ExpenseState state) {
    // This chart naturally uses data for the entire selectedYear
    final data = state.monthlyDataByYear[selectedYear] ?? [];
    if (data.isEmpty) {
      return Column(
        // Wrap in column to include filter
        children: [
          _buildFilterDropdowns(state, showMonthFilter: false), // Only show year filter
          const Expanded(child: Center(child: Text("No monthly balance data for selected year."))),
        ],
      );
    }

    double minY = 0;
    double maxY = 0;

    List<FlSpot> spots = data.map((e) {
      final month = (e['monthNum'] as int);
      final balance = (e['income'] as double) - (e['expense'] as double);
      if (balance > maxY) maxY = balance;
      if (balance < minY) minY = balance;
      return FlSpot(month.toDouble(), balance);
    }).toList();

    maxY = maxY * 1.2;
    minY = minY * 1.2;

    return Column(
      children: [
        _buildFilterDropdowns(state, showMonthFilter: false), // Only show year filter
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Monthly Balance Trend ($selectedYear)",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          minY: minY,
                          maxY: maxY,
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 1 && value.toInt() <= 12) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 8.0,
                                      child: Text(
                                        _getMonthName(value.toInt()),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  final textStyle = TextStyle(
                                    color: touchedSpot.bar.gradient?.colors[0] ?? touchedSpot.bar.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  final monthIndex = touchedSpot.x.toInt();
                                  final monthName = _getMonthName(monthIndex);
                                  return LineTooltipItem(
                                    '$monthName:\n\$${touchedSpot.y.toStringAsFixed(0)}',
                                    textStyle,
                                  );
                                }).toList();
                              },
                              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                              tooltipRoundedRadius: 8.0,
                            ),
                            handleBuiltInTouches: true,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: primaryColor,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: primaryColor,
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: .14)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopExpensesPieChart(ExpenseState state) {
    // This chart uses the selected month and year
    final key = '$selectedYear-${selectedMonth}';
    final topExpenses = state.topExpensesByMonthYear[key] ?? [];
    final top4 = topExpenses.take(4).toList();

    if (top4.isEmpty) {
      return Column(
        // Wrap in column to include filter
        children: [
          _buildFilterDropdowns(state, showMonthFilter: true), // Show year and month filters
          const Expanded(child: Center(child: Text("No expenses for the selected month."))),
        ],
      );
    }

    final List<Color> pieColors = [
      Colors.deepOrange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.grey,
    ];

    List<PieChartSectionData> sections = [];
    double totalTop4Amount = 0;
    for (var expense in top4) {
      totalTop4Amount += expense['amount'];
    }

    double otherAmount = topExpenses.skip(4).fold(0.0, (sum, item) => sum + item['amount']);
    double totalOverallExpenses = totalTop4Amount + otherAmount;

    for (int i = 0; i < top4.length; i++) {
      final item = top4[i];
      sections.add(
        PieChartSectionData(
          color: pieColors[i % pieColors.length],
          value: item['amount'],
          title: '${((item['amount'] / totalOverallExpenses) * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 1)],
          ),
        ),
      );
    }

    if (otherAmount > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade400,
          value: otherAmount,
          title: '${((otherAmount / totalOverallExpenses) * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 1)],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildFilterDropdowns(state, showMonthFilter: true), // Show year and month filters
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Top Expenses by Category (${_getMonthName(int.parse(selectedMonth))} $selectedYear)",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 8,
                          centerSpaceRadius: 60,
                          sections: sections,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTopExpensesPieLegend(top4, otherAmount, pieColors),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopExpensesPieLegend(List<Map<String, dynamic>> top4Expenses, double otherAmount, List<Color> colors) {
    List<Widget> legendItems = [];

    for (int i = 0; i < top4Expenses.length; i++) {
      final item = top4Expenses[i];
      legendItems.add(
        _buildLegendItem(colors[i % colors.length], item['category'], (item['amount'] as double).formatWithCommas()),
      );
    }
    if (otherAmount > 0) {
      legendItems.add(
        _buildLegendItem(Colors.grey.shade400, 'Other', otherAmount.formatWithCommas()),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: legendItems,
    );
  }

  Widget _buildYearlySummaryTable(ExpenseState state) {
    // This chart naturally uses data for the entire selectedYear
    final data = state.monthlyDataByYear[selectedYear] ?? [];

    if (data.isEmpty) {
      return Column(
        // Wrap in column to include filter
        children: [
          _buildFilterDropdowns(state, showMonthFilter: false), // Only show year filter
          const Expanded(child: Center(child: Text("No summary data for selected year."))),
        ],
      );
    }

    final totalIncomeYear = data.fold<double>(0, (sum, item) => sum + (item['income'] as double));
    final totalExpenseYear = data.fold<double>(0, (sum, item) => sum + (item['expense'] as double));
    final totalBalanceYear = (totalIncomeYear - totalExpenseYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterDropdowns(state, showMonthFilter: false), // Only show year filter
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Yearly Summary for $selectedYear",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            headingRowColor:
                                WidgetStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Income', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Expense', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: [
                              ...data.map((e) {
                                final balance = (e['income'] as double) - (e['expense'] as double);
                                return DataRow(cells: [
                                  DataCell(Text(e['month'])), // Displaying the month name
                                  DataCell(Text((e['income'] as double).formatWithCommas(),
                                      style: const TextStyle(color: Colors.green))),
                                  DataCell(Text((e['expense'] as double).formatWithCommas(),
                                      style: const TextStyle(color: Colors.red))),
                                  DataCell(Text(balance.formatWithCommas(),
                                      style: TextStyle(color: balance >= 0 ? Colors.blue : Colors.deepOrange))),
                                ]);
                              }),
                              DataRow(
                                color: WidgetStateProperty.all(Colors.grey.shade100),
                                cells: [
                                  const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(totalIncomeYear.formatWithCommas(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                                  DataCell(Text(totalExpenseYear.formatWithCommas(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                                  DataCell(Text(totalBalanceYear.formatWithCommas(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: totalBalanceYear >= 0 ? Colors.blue : Colors.deepOrange))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
