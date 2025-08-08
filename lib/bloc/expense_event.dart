import '../models/category_model.dart';

abstract class ExpenseEvent {}

class AddTransaction extends ExpenseEvent {
  final String title;
  final double amount;
  final String note;
  final DateTime date;
  final bool isIncome;
  final CategoryModel category; 

  AddTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    required this.note, 
  });
}

class LoadTransactions extends ExpenseEvent {}

class FilterTransactions extends ExpenseEvent {
  final int month;
  final int year;

  FilterTransactions({required this.month, required this.year});
}

class ResetFilter extends ExpenseEvent {}

class DeleteTransaction extends ExpenseEvent {
  final String id;
  DeleteTransaction(this.id);
}
//update
class EditTransaction extends ExpenseEvent {
  final String id;
  final String title;
  final double amount;
  final String note;
  final DateTime date;
  final bool isIncome;
  final CategoryModel category;

  EditTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    required this.note,
  });
}



