import 'package:expensely_app/models/transaction.dart'; // Ensure this path is correct

class ExpenseState {
  final List<Transaction> transactions;

  ExpenseState({required this.transactions});

  // Helper function to get month name from month number
  String _getMonthName(int monthNumber) {
    const monthNames = [
      '', // 0-indexed, so we can ignore index 0
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[monthNumber];
  }

  /// ✅ Grouped Monthly Data for Line Chart & Table
  /// Format: { '2025': [ {month: 'January', monthNum: 1, income: 1200, expense: 800}, ... ] }
  Map<String, List<Map<String, dynamic>>> get monthlyDataByYear {
    final Map<String, List<Map<String, dynamic>>> result = {};

    for (var t in transactions) {
      final year = t.date.year.toString();
      final monthNumber = t.date.month;
      final monthName = _getMonthName(monthNumber); // Get month name

      result.putIfAbsent(year, () => []);

      var monthly = result[year]!.firstWhere(
        (e) => e['month'] == monthName, // Use monthName for comparison
        orElse: () {
          final map = {'month': monthName, 'monthNum': monthNumber, 'income': 0.0, 'expense': 0.0};
          result[year]!.add(map);
          return map;
        },
      );

      if (t.isIncome) {
        monthly['income'] += t.amount;
      } else {
        monthly['expense'] += t.amount;
      }
    }

    // Sort by month number
    result.forEach((key, list) {
      list.sort((a, b) => (a['monthNum'] as int).compareTo(b['monthNum'] as int));
    });

    return result;
  }

  /// ✅ Top Expenses by Category per month-year
  /// Format: { '2025-07': [ {category: 'Food', amount: 500}, ... ] }
  Map<String, List<Map<String, dynamic>>> get topExpensesByMonthYear {
    final Map<String, List<Map<String, dynamic>>> result = {};
    final expenses = transactions.where((t) => !t.isIncome);

    for (var t in expenses) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}'; // Keep original key for lookup
      result.putIfAbsent(key, () => []);

      var existing = result[key]!.firstWhere(
        (e) => e['category'] == t.category.name,
        orElse: () {
          final map = {'category': t.category.name, 'amount': 0.0};
          result[key]!.add(map);
          return map;
        },
      );

      existing['amount'] += t.amount;
    }

    // Sort by amount descending
    result.forEach((key, list) {
      list.sort((a, b) => b['amount'].compareTo(a['amount']));
    });

    return result;
  }

  


}


