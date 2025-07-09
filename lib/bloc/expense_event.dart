import '../models/category_model.dart';

abstract class ExpenseEvent {}

class AddTransaction extends ExpenseEvent {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final CategoryModel category; // ⬅️ New

  AddTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
  });
}

class LoadTransactions extends ExpenseEvent {}
