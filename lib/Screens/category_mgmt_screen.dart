import 'package:expensely_app/Screens/add_edit_category_screen.dart';
import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/widgets/premimum_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  String _selectedType = 'Expense';
  final Box<CategoryModel> categoriesBox = Hive.box<CategoryModel>('categories');

  @override
  void initState() {
    super.initState();
  }

  void _goToAddEditCategory({CategoryModel? category, int? key}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(
          categoriesBox: categoriesBox,
          initialCategory: category,
          categoryKey: key,
        ),
      ),
    );
  }

  void _reorderCategories(int oldIndex, int newIndex, List<CategoryModel> categories) async {
    if (oldIndex < newIndex) newIndex -= 1;

    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);

    // Update Hive in the same filtered order
    final filteredKeys = categoriesBox.keys.where((k) => categoriesBox.get(k)!.type == _selectedType).toList();

    for (int i = 0; i < categories.length; i++) {
      final key = filteredKeys[i];
      await categoriesBox.put(key, categories[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
            onPressed: () {
              final allCategories = categoriesBox.values.toList();

              if (allCategories.length >= 40) {
                showPremiumBottomSheet(context);
              } else {
                _goToAddEditCategory();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Expense'),
                labelStyle: TextStyle(
                  color: _selectedType == 'Expense' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                checkmarkColor: _selectedType == 'Expense' ? Colors.white : Colors.black,
                selectedColor: primaryColor,
                selected: _selectedType == 'Expense',
                onSelected: (_) => setState(() => _selectedType = 'Expense'),
              ),
              ChoiceChip(
                label: const Text('Income'),
                labelStyle: TextStyle(
                  color: _selectedType == 'Income' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                checkmarkColor: _selectedType == 'Income' ? Colors.white : Colors.black,
                selectedColor: primaryColor,
                selected: _selectedType == 'Income',
                onSelected: (_) => setState(() => _selectedType = 'Income'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: categoriesBox.listenable(),
              builder: (context, Box<CategoryModel> box, _) {
                final categories = box.values.where((cat) => cat.type == _selectedType).toList();

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      "No categories yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: categories.length,
                  onReorder: (oldIndex, newIndex) => _reorderCategories(oldIndex, newIndex, categories),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final hiveKey = box.keyAt(box.values.toList().indexOf(cat));

                    return Container(
                      margin: EdgeInsets.all(3),
                      key: ValueKey("cat_$hiveKey +$i"),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Icon(cat.icon, color: primaryColor),
                        ),
                        title: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(cat.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _goToAddEditCategory(category: cat, key: hiveKey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => box.delete(hiveKey),
                            ),
                            const Icon(Icons.drag_handle, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
