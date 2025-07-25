import 'package:expensely_app/utils/icon_map.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String iconKey;

  @HiveField(2)
  final String type;

  CategoryModel({
    required this.name,
    required this.iconKey,
    required this.type,
  });

  IconData get icon => iconMap[iconKey] ?? Icons.category;
}
