abstract class ExpenseEvent {}

class AddTransaction extends ExpenseEvent {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  AddTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
class LoadTransactions extends ExpenseEvent {}
