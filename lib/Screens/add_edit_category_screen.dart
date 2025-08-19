import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/utils/icon_map.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Box<CategoryModel> categoriesBox;
  final CategoryModel? initialCategory;
  final int? categoryKey; // Use key instead of index

  const AddEditCategoryScreen({
    super.key,
    required this.categoriesBox,
    this.initialCategory,
    this.categoryKey, // Changed from categoryIndex
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _iconKey;
  late String _type;

  @override
  void initState() {
    super.initState();
    _name = widget.initialCategory?.name ?? '';
    _iconKey = widget.initialCategory?.iconKey ?? iconMap.keys.first;
    _type = widget.initialCategory?.type ?? 'Expense';
  }

  void _saveOrUpdateCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final cat = CategoryModel(name: _name, iconKey: _iconKey, type: _type);

      if (widget.categoryKey != null) {
        // Use the key to update the existing category
        widget.categoriesBox.put(widget.categoryKey!, cat);
      } else {
        // Add a new category
        widget.categoriesBox.add(cat);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = iconMap;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        title: Text(widget.initialCategory == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: _type == 'Expense',
                    labelStyle: TextStyle(
                      color: _type == 'Expense' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    checkmarkColor: _type == 'Expense' ? Colors.white : Colors.black,
                    selectedColor: primaryColor,
                    onSelected: (_) => setState(() => _type = 'Expense'),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: _type == 'Income',
                    labelStyle: TextStyle(
                      color: _type == 'Income' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    checkmarkColor: _type == 'Income' ? Colors.white : Colors.black,
                    selectedColor: primaryColor,
                    onSelected: (_) => setState(() => _type = 'Income'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a name' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 20),
              const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: icons.keys.length,
                  itemBuilder: (context, i) {
                    final k = icons.keys.elementAt(i);
                    return GestureDetector(
                      onTap: () => setState(() => _iconKey = k),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icons[k], size: 32, color: _iconKey == k ? primaryColor : Colors.black45),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveOrUpdateCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(180, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  widget.initialCategory == null ? 'Save Category' : 'Update Category',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
