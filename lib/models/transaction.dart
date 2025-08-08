import 'package:hive/hive.dart';
import 'category_model.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isIncome;

  @HiveField(5)
  final CategoryModel category;

  @HiveField(6)
  String note;

  Transaction(
    this.id, {
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    this.note = "", 
  });
}
