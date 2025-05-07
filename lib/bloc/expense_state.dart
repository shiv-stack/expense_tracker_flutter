import '../models/transaction.dart';

class ExpenseState {
  final List<Transaction> transactions;

  ExpenseState({required this.transactions});

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpenses;
}
