import 'package:collection/collection.dart';
import 'package:expensely_app/Screens/Add_Expense.dart';
import 'package:expensely_app/Screens/Chart_Screen.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/constants/colors..dart';
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

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadTransactions());
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
                                    });
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Balance", style: TextStyle(color: Colors.white70)),
                                // Icon(Icons.more_horiz, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "₹${state.totalBalance.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.arrow_downward, color: Colors.white70),
                                    const SizedBox(height: 5),
                                    Text("₹${state.totalIncome.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Colors.white)),
                                    const Text("Income", style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.arrow_upward, color: Colors.white70),
                                    const SizedBox(height: 5),
                                    Text("₹${state.totalExpenses.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Colors.white)),
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
              padding: const EdgeInsets.all(20.0),
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
                      ...state.transactions
                          .sorted((a, b) => b.date.compareTo(a.date)) // Sort by latest date
                          .map((transaction) {
                        return _buildTransaction(
                            transaction.title,
                            DateFormat.yMMMd().format(transaction.date),
                            "${transaction.isIncome ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}",
                            transaction.isIncome ? Colors.green : Colors.red,
                            transaction.note,
                            transaction.category.name);
                      }).toList(),
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black), // <- Use icon here
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
    );
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

    String selectedMonth = DateFormat.MMMM().format(DateTime.now());
    int selectedYear = DateTime.now().year;

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
