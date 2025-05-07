import 'package:expensely_app/Screens/Add_Expense.dart';
import 'package:expensely_app/Screens/Profile.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_bloc.dart'; // Adjust path as needed
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A8E74);

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
                      const Text(
                        "Good afternoon,",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Shivam Thapa",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
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
                                Text("Total Balance",
                                    style: TextStyle(color: Colors.white70)),
                                Icon(Icons.more_horiz, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$${state.totalBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.arrow_downward,
                                        color: Colors.white70),
                                    const SizedBox(height: 5),
                                    Text(
                                        "\$${state.totalIncome.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const Text("Income",
                                        style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.arrow_upward,
                                        color: Colors.white70),
                                    const SizedBox(height: 5),
                                    Text(
                                        "\$${state.totalExpenses.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const Text("Expenses",
                                        style: TextStyle(color: Colors.white70)),
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
                          Text("Transactions History",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("See all", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...?state?.transactions.map((transaction) {
                        return _buildTransaction(
                          transaction.title,
                          DateFormat.yMMMd().format(transaction.date),
                          "${transaction.isIncome ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}",
                          transaction.isIncome ? Colors.green : Colors.red,
                        );
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
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  icon: const Icon(Icons.home)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.pie_chart)),
              const SizedBox(width: 40),
              IconButton(onPressed: () {}, icon: const Icon(Icons.receipt_long)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaction(
      String title, String date, String amount, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(title[0], style: const TextStyle(color: Colors.black)),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
