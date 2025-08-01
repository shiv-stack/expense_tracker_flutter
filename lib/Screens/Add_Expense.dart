import 'package:dotted_border/dotted_border.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/widgets/category_modal_sheet.dart';
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
  // String selectedCategory = "Expense";
  String selectedType = 'Expense'; // default
  CategoryModel? selectedCategory; // Default category
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now(); //  today's date

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
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
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
                  Text("Add Expense", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 40)
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                spacing: 15,
                children: [
                  // Category Dropdown
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => CategoryModalSheet(
                          isExpense: selectedType == 'Expense',
                          onCategorySelected: (_) {}, // optional hai abhi
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          selectedCategory = result['category'];
                          selectedType = result['isIncome'] ? 'Income' : 'Expense';
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                      child: Row(
                        children: [
                          Icon(selectedCategory?.icon ?? Icons.category),
                          const SizedBox(width: 10),
                          Text(
                            selectedCategory?.name ?? 'Choose Category',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dropdown for Service/Transaction Title
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.grey.shade300),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: DropdownButtonFormField<String>(
                  //     value: selectedService,
                  //     decoration: const InputDecoration(
                  //       border: InputBorder.none,
                  //     ),
                  //     icon: const Icon(Icons.keyboard_arrow_down),
                  //     items: ['Netflix', 'Spotify', 'Amazon Prime', "Others"]
                  //         .map((label) => DropdownMenuItem(
                  //               child: Row(
                  //                 children: [
                  //                   const CircleAvatar(
                  //                     radius: 14,
                  //                     backgroundImage: AssetImage(
                  //                         "assets/images/netflix_icon.png"),
                  //                   ),
                  //                   const SizedBox(width: 10),
                  //                   Text(label),
                  //                 ],
                  //               ),
                  //               value: label,
                  //             ))
                  //         .toList(),
                  //     onChanged: (value) {
                  //       setState(() {
                  //         selectedService = value!;
                  //       });
                  //     },
                  //   ),
                  // ),

                  // Amount Input
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹',
                      suffixIcon: TextButton(
                        onPressed: () {
                          amountController.clear();
                        },
                        child: const Text("Clear"),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  //note
                  TextFormField(
                    controller: noteController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Date Picker
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

                  // Add Invoice (Optional)
                  GestureDetector(
                    onTap: () {
                      final overlay = Overlay.of(context);
                      final overlayEntry = OverlayEntry(
                        builder: (context) => Positioned(
                          top: MediaQuery.of(context).size.height * 0.7,
                          left: MediaQuery.of(context).size.width * 0.1,
                          right: MediaQuery.of(context).size.width * 0.1,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  "🚧 This feature will roll out soon!",
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );

                      overlay.insert(overlayEntry);

                      Future.delayed(const Duration(seconds: 2), () {
                        overlayEntry.remove();
                      });
                    },
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      dashPattern: [8, 4],
                      color: Colors.grey,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        alignment: Alignment.center,
                        child: const Text("+ Add Invoice", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),

                  // Save Button
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A8E74), // ✅ Background color
                        foregroundColor: Colors.white, // ✅ Text/icon color
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (amountController.text.isEmpty || selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please fill all fields")),
                          );
                          return;
                        }
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        final isIncome = selectedType == 'Income';

                        context.read<ExpenseBloc>().add(
                              AddTransaction(
                                title: selectedCategory?.name ?? "Unknown",
                                amount: amount,
                                date: selectedDate,
                                isIncome: isIncome,
                                category: selectedCategory!,
                                note: noteController.text.trim(),
                              ),
                            );

                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
