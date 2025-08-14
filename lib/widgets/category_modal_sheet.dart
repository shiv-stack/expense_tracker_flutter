import 'package:expensely_app/constants/colors.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../constants/category_data.dart';

class CategoryModalSheet extends StatefulWidget {
  final bool isExpense;
  final Function(CategoryModel) onCategorySelected;
  final String? selectedCategory;

  const CategoryModalSheet({
    super.key,
    required this.isExpense,
    required this.onCategorySelected,
    this.selectedCategory,
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
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 500
                        ? 6
                        : MediaQuery.of(context).size.width < 390
                            ? 3
                            : 4, // Number of columns
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true, // So it doesn't take infinite height
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling if inside a scroll view
                    children: categories.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          widget.onCategorySelected(cat);
                          Navigator.pop(context, {
                            'category': cat,
                            'isIncome': !isExpenseTab,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: widget.selectedCategory == cat.name ? primaryColor.withValues(alpha: .4) : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: .5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  cat.icon,
                                  color: primaryColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
