import 'package:expensely_app/constants/colors.dart';
import 'package:flutter/material.dart';

/// A stateful widget to manage the TextEditingController for the edit dialog.
/// This ensures the controller is always disposed correctly.
class EditNameDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onSave;

  const EditNameDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  // The controller is now a state variable of this widget.
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller here.
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    // This is the crucial step: dispose of the controller when the dialog is closed.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Your Name'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter your name'),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
          onPressed: () {
            final newName = _nameController.text;
            if (newName.isNotEmpty) {
              widget.onSave(newName); // Use the callback to save the name
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
