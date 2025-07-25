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
        category: event.category,
        note: event.note, 
      );

      box.add(newTx); // Saving  to Hive
      final updated = List<Transaction>.from(box.values);
      emit(ExpenseState(transactions: updated));
    });

    on<LoadTransactions>((event, emit) {
      final saved = box.values.toList();
      emit(ExpenseState(transactions: saved));
    });
    on<FilterTransactions>((event, emit) {
      final allTransactions = box.values.toList();

      final filtered = allTransactions
          .where((tx) =>
              tx.date.month == event.month && tx.date.year == event.year)
          .toList();

      emit(ExpenseState(transactions: filtered));
    });

    on<ResetFilter>((event, emit) {
      final all = box.values.toList();
      emit(ExpenseState(transactions: all));
    });
  }
}
