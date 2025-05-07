// models/expense.dart

class ExpenseModel {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome; // true = income, false = expense

  ExpenseModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
