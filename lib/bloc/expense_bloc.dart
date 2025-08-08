import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final Box<Transaction> box = Hive.box<Transaction>('transactionsBox');

  ExpenseBloc() : super(ExpenseState(transactions: [])) {
    on<AddTransaction>((event, emit) {
      final newTx = Transaction(
        const Uuid().v4(),
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

    on<DeleteTransaction>((event, emit) async {
      final keyToDelete = box.keys.firstWhere(
        (key) => box.get(key)?.id == event.id,
        orElse: () => null,
      );
      if (keyToDelete != null) {
        await box.delete(keyToDelete);
      }
      final updatedList = box.values.toList();
      emit(ExpenseState(transactions: updatedList));
    });
    //update
    on<EditTransaction>((event, emit) async {
      final keyToEdit = box.keys.firstWhere(
        (key) => box.get(key)?.id == event.id,
        orElse: () => null,
      );
      if (keyToEdit != null) {
        final updatedTx = Transaction(
          event.id,
          title: event.title,
          amount: event.amount,
          date: event.date,
          isIncome: event.isIncome,
          category: event.category,
          note: event.note,
        );
        await box.put(keyToEdit, updatedTx);
      }
      final updatedList = box.values.toList();
      emit(ExpenseState(transactions: updatedList));
    });
  }
}
