import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final Box<Transaction> box = Hive.box<Transaction>('transactionsBox');

  ExpenseBloc() : super(ExpenseState(transactions: [])) {
    on<AddTransaction>((event, emit) {
      final newTx = Transaction(
        title: event.title,
        amount: event.amount,
        date: event.date,
        isIncome: event.isIncome,
        category: event.category, // ✅ Now storing category
      );

      box.add(newTx); // Save to Hive
      final updated = List<Transaction>.from(box.values);
      emit(ExpenseState(transactions: updated));
    });

    on<LoadTransactions>((event, emit) {
      final saved = box.values.toList();
      emit(ExpenseState(transactions: saved));
    });
  }
}
