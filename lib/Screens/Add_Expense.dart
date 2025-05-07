import 'package:dotted_border/dotted_border.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? selectedService = "Netflix";
  String selectedCategory = "Expense"; // Default category
  TextEditingController amountController = TextEditingController(text: "48.00");
  DateTime selectedDate = DateTime(2022, 2, 22);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1A8E74);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with curved background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(color: Colors.white),
                  Text("Add Expense",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Icon(Icons.more_horiz, color: Colors.white),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Category Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: ['Expense', 'Income']
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown for Service/Transaction Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: ['Netflix', 'Spotify', 'Amazon Prime',"Others"]
                          .map((label) => DropdownMenuItem(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundImage: AssetImage(
                                          "assets/images/netflix_icon.png"),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(label),
                                  ],
                                ),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedService = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount Input
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      suffixIcon: TextButton(
                        onPressed: () {
                          amountController.clear();
                        },
                        child: const Text("Clear"),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Invoice (Optional)
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: [8, 4],
                    color: Colors.grey,
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      alignment: Alignment.center,
                      child: const Text("+ Add Invoice",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0.0;
                      final isIncome = selectedCategory == 'Income';

                      context.read<ExpenseBloc>().add(
                            AddTransaction(
                              title: selectedService ?? "Unknown",
                              amount: amount,
                              date: selectedDate,
                              isIncome: isIncome,
                            ),
                          );

                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
