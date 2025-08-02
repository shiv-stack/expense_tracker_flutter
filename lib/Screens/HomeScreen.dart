import 'package:collection/collection.dart';
import 'package:expensely_app/Screens/Add_Expense.dart';
import 'package:expensely_app/Screens/Chart_Screen.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/constants/colors..dart';
import 'package:expensely_app/constants/extensions.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:expensely_app/utils/icon_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense_bloc.dart'; // Adjust path as needed
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String userName = '';
  bool isFilterApplied = false;
  String selectedMonth = DateFormat.MMMM().format(DateTime.now());
  int selectedYear = DateTime.now().year;
  final currentMonth = DateTime.now().month;

  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    context.read<ExpenseBloc>().add(LoadTransactions());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Transaction> filteredTransactions(ExpenseState state) {
    final filteredTransactions = isFilterApplied
        ? state.transactions
        : state.transactions.where((t) => t.date.month == currentMonth && t.date.year == selectedYear).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return filteredTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.userName,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.filter_list, color: Colors.white),
                                onPressed: () {
                                  showFilterBottomSheet(context);
                                  setState(() {
                                    isFilterApplied = true;
                                  });
                                },
                              ),
                              if (isFilterApplied)
                                IconButton(
                                  icon: Icon(Icons.refresh, color: Colors.white),
                                  onPressed: () {
                                    context.read<ExpenseBloc>().add(ResetFilter());
                                    setState(() {
                                      isFilterApplied = false;
                                      selectedMonth = DateFormat.MMMM().format(DateTime.now());
                                      selectedYear = DateTime.now().year;
                                    });
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF127A64),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Balance", style: TextStyle(color: Colors.white)),
                                // Icon(Icons.more_horiz, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₹ ${state.totalBalance.formatWithCommas()}",
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.white12,
                                        child: const Icon(Icons.arrow_downward, size: 18, color: Colors.green)),
                                    const SizedBox(height: 5),
                                    Text("₹${state.totalIncome.formatWithCommas()}",
                                        style: const TextStyle(color: Colors.white)),
                                    const Text("Income", style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.white12,
                                        child: const Icon(Icons.arrow_upward, size: 18, color: Colors.red)),
                                    const SizedBox(height: 5),
                                    Text("₹${state.totalExpenses.formatWithCommas()}",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                    const Text("Expenses", style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Transaction History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transactions History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          //  Text("See all", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      SizedBox(height: 15),
                      ...filteredTransactions(state) // Sort by latest date
                          .map((transaction) {
                        return _buildTransaction(
                            transaction.title,
                            DateFormat.yMMMd().format(transaction.date),
                            "${transaction.isIncome ? '+' : '-'} ₹${transaction.amount.formatWithCommas()}",
                            transaction.isIncome ? Colors.green : Colors.red,
                            transaction.note,
                            transaction.category.name);
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: 28,
                onPressed: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         HomeScreen(userName: widget.userName),
                  //   ),
                  // );
                },
                icon: const Icon(Icons.home),
              ),
              IconButton(
                iconSize: 28,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportScreen()),
                  );
                  // Navigate to Group/Friends screen
                },
                icon: const Icon(Icons.pie_chart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaction(
    String title,
    String date,
    String amount,
    Color color,
    String note,
    String categoryName,
  ) {
    final icon = iconMap[categoryName.toLowerCase()] ?? Icons.category;

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Icon(icon, color: primaryColor), // <- Use icon here
                    ),
                    title: Text(title),
                    subtitle: Text(note.isNotEmpty ? note : ''),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          amount,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  void showFilterBottomSheet(BuildContext context) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    List<int> years = List.generate(10, (index) => 2024 + index);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Filter Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: months.length,
                            itemBuilder: (context, index) {
                              final month = months[index];
                              final isSelected = selectedMonth == month;
                              return ListTile(
                                title: Text(
                                  month,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                                onTap: () {
                                  setState(() {
                                    selectedMonth = month;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: years.length,
                            itemBuilder: (context, index) {
                              final year = years[index];
                              final isSelected = selectedYear == year;
                              return ListTile(
                                title: Text(
                                  "$year",
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                                onTap: () {
                                  setState(() {
                                    selectedYear = year;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            int monthIndex = months.indexOf(selectedMonth) + 1;

                            context.read<ExpenseBloc>().add(FilterTransactions(
                                  month: monthIndex,
                                  year: selectedYear,
                                ));

                            Navigator.pop(context);
                          },
                          child: const Text("Apply Filter"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
