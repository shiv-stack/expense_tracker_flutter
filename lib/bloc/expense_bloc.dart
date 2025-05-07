import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_event.dart';
import 'expense_state.dart';
import '../models/transaction.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseState(transactions: [])) {
    on<AddTransaction>((event, emit) {
      final updated = List<Transaction>.from(state.transactions)
        ..add(Transaction(
          title: event.title,
          amount: event.amount,
          date: event.date,
          isIncome: event.isIncome,
        ));
      emit(ExpenseState(transactions: updated));
    });
  }
}
