import 'package:hive/hive.dart';
import 'category_model.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isIncome;

  @HiveField(4)
  final CategoryModel category;

  @HiveField(5)
  String note;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    this.note = "",
  });
}
