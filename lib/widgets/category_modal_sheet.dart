import 'package:expensely_app/constants/colors..dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../constants/category_data.dart';

class CategoryModalSheet extends StatefulWidget {
  final bool isExpense;
  final Function(CategoryModel) onCategorySelected;

  const CategoryModalSheet({
    super.key,
    required this.isExpense,
    required this.onCategorySelected,
  });

  @override
  State<CategoryModalSheet> createState() => _CategoryModalSheetState();
}

class _CategoryModalSheetState extends State<CategoryModalSheet> {
  late bool isExpenseTab;

  @override
  void initState() {
    super.initState();
    isExpenseTab = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    final categories = isExpenseTab ? expenseCategories : incomeCategories;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            // color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: [isExpenseTab, !isExpenseTab],
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 40,
                  ),
                  fillColor: primaryColor,
                  selectedColor: Colors.white,
                  onPressed: (index) {
                    setState(() {
                      isExpenseTab = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("Expense"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("Income"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    children: categories.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          widget.onCategorySelected(cat);
                          Navigator.pop(context, {
                            'category': cat,
                            'isIncome': !isExpenseTab,
                          });
                        },
                        child: SizedBox(
                          height: 90,
                          width: 60,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  cat.icon,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
