import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import 'package:expensely_app/models/category_model.dart';

class AddExpenseAnimatedScreen extends StatefulWidget {
  final Transaction? editingTx;

  const AddExpenseAnimatedScreen({
    super.key,
    this.editingTx,
  });

  @override
  State<AddExpenseAnimatedScreen> createState() => _AddExpenseAnimatedScreenState();
}

class _AddExpenseAnimatedScreenState extends State<AddExpenseAnimatedScreen> with SingleTickerProviderStateMixin {
  bool isIncome = false;
  CategoryModel? selectedCategory;
  bool showAmountContainer = false;
  String expr = '';
  num result = 0;
  DateTime selectedDate = DateTime.now();
  TextEditingController noteController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Box<CategoryModel> categoryBox;
  late List<CategoryModel> allCategories;

  String? selectedCat = "";
  String selectedType = 'Expense'; // default

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<CategoryModel>('categories');
    allCategories = categoryBox.values.toList();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 340),
    );
    _heightAnimation = Tween<double>(begin: 0, end: 405).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.editingTx != null) {
      // Prefill for edit mode
      final tx = widget.editingTx!;
      selectedType = tx.isIncome ? 'Income' : 'Expense';
      selectedCategory = tx.category;
      selectedCat = tx.category.name;
      result = tx.amount;
      isIncome = tx.isIncome;
      noteController = TextEditingController(text: tx.note);
      selectedDate = tx.date;
      showAmountContainer = true;
      _controller.forward();
    } else {
      // Defaults for add mode
      noteController = TextEditingController();
      selectedDate = DateTime.now();
    }
  }

  void _onCategoryTap(CategoryModel cat) {
    setState(() {
      selectedCategory = cat;
      selectedCat = cat.name;
      expr = '';
      result = 0;
      noteController.clear();
      showAmountContainer = true;
      _controller.forward();
    });
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'C') {
        expr = '';
        result = 0;
      } else if (key == '←') {
        if (expr.isNotEmpty) expr = expr.substring(0, expr.length - 1);
      } else {
        expr += key;
      }
      _calculateResult();
    });
  }

  void _calculateResult() {
    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(expr.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      result = exp.evaluate(EvaluationType.REAL, cm);
    } catch (_) {
      result = 0;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingTx != null;

    final categories = allCategories.where((cat) => cat.type == (isIncome ? 'Income' : 'Expense')).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Add Expense",
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface)),
        backgroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.surface),
          onPressed: () {
            // if (showAmountContainer) {
            //   setState(() {
            //     showAmountContainer = false;
            //     _controller.reverse();
            //   });
            // } else {
            Navigator.pop(context);
            //  }
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: [!isIncome, isIncome],
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 40,
                  ),
                  fillColor: primaryColor,
                  selectedColor: Colors.white,
                  onPressed: (index) {
                    setState(() {
                      isIncome = index == 1;
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

                SizedBox(height: 12),
                // Category grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: categories
                        .map((cat) => GestureDetector(
                              onTap: () => _onCategoryTap(cat),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedCat == cat.name ? primaryColor : Colors.white,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: selectedCat == cat.name ? primaryColor.withValues(alpha: .2) : Colors.white,
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Icon(cat.icon,
                                        color: selectedCat == cat.name ? primaryColor : Colors.grey, size: 25),
                                  ),
                                  SizedBox(height: 7),
                                  Text(cat.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                                ]),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
          // Animated KeYpad Container
          AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, child) {
              ColorScheme colorScheme = Theme.of(context).colorScheme;
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: _heightAnimation.value,
                  decoration: BoxDecoration(
                    color: offWhiteColor,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, -4))],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: (_heightAnimation.value > 10)
                      ? SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Calculation & Close
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedCategory?.name ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                                      onPressed: () {
                                        setState(() => showAmountContainer = false);
                                        _controller.reverse();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Calculator display
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          expr.isEmpty ? 'Enter Amount...' : expr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '₹$result',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Note Text Field
                                TextField(
                                  controller: noteController,
                                  //  maxLength: 40,
                                  decoration: InputDecoration(
                                    hintText: "Add a note (optional)",
                                    prefixIcon: Icon(Icons.notes_rounded),
                                    filled: true,
                                    fillColor: colorScheme.primaryContainer,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Numeric Keypad
                                _buildKeypad(isEditing),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(bool isEditing) {
    return Column(
      children: [
        Row(
          children: [
            _keypadBtn('7'),
            _keypadBtn('8'),
            _keypadBtn('9'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _getDateLabel(selectedDate),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _keypadBtn('4'),
            _keypadBtn('5'),
            _keypadBtn('6'),
            _keypadBtn('+'),
          ],
        ),
        Row(
          children: [
            _keypadBtn('1'),
            _keypadBtn('2'),
            _keypadBtn('3'),
            _keypadBtn('-'),
          ],
        ),
        // . 0 ← save
        Row(
          children: [
            _keypadBtn('.'),
            _keypadBtn('0'),
            _keypadBtn('←'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: IconButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: (result > 0 && selectedCategory != null)
                      ? () {
                          if (isEditing) {
                            context.read<ExpenseBloc>().add(
                                  EditTransaction(
                                    id: widget.editingTx!.id,
                                    title: selectedCategory!.name,
                                    amount: double.parse(result.toString()),
                                    date: selectedDate,
                                    isIncome: isIncome,
                                    category: selectedCategory!,
                                    note: noteController.text.trim(),
                                  ),
                                );
                          } else {
                            context.read<ExpenseBloc>().add(
                                  AddTransaction(
                                    title: selectedCategory!.name,
                                    amount: double.parse(result.toString()),
                                    date: selectedDate,
                                    isIncome: isIncome,
                                    category: selectedCategory!,
                                    note: noteController.text.trim(),
                                  ),
                                );
                          }
                          // widget.onSave(
                          //     result, expr, selectedDate, selectedCategory!, noteController.text.trim(), isIncome);
                          setState(() {
                            showAmountContainer = false;
                            selectedCategory = null;
                          });
                          _controller.reverse();
                          expr = '';
                          result = 0;
                          noteController.clear();
                          Navigator.pop(context);
                        }
                      : null,
                  icon: Icon(Icons.check, size: 22),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }

// Helper function for keypad buttons
  Widget _keypadBtn(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            elevation: 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: key.isNotEmpty ? () => _onKeyTap(key) : null,
          child: key == '←'
              ? Icon(Icons.backspace_outlined, color: Colors.black, size: 22)
              : Text(key,
                  style: TextStyle(
                      fontSize: 18,
                      color: [
                        '+',
                        '-',
                      ].contains(key)
                          ? primaryColor
                          : Colors.black,
                      fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    noteController.dispose();
    super.dispose();
  }
}
