import 'package:collection/collection.dart';
import 'package:expensely_app/constants/category_data.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

Map<String, List<Transaction>> groupTransactionsByDate(List<Transaction> transactions) {
  // Use the groupBy function from the collection package
  final grouped = groupBy(transactions, (Transaction txn) {
    // Normalize the date to ignore time, using yyyy-MM-dd as the key
    return DateFormat('yyyy-MM-dd').format(txn.date);
  });
  return grouped;
}

String formatDate(DateTime date) {
  // Format the date to a more readable string
  return DateFormat('MMMM dd, yyyy').format(date);
}

Future<void> initializeDefaultCategories() async {
  var box = await Hive.openBox<CategoryModel>('categories');
  if (box.isEmpty) {
    // If box is empty, add static categories
    final allDefaults = [...expenseCategories, ...incomeCategories];
    for (var category in allDefaults) {
      box.add(category);
    }
  }
}
