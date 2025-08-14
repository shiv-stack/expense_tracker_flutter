import 'package:expensely_app/models/currency.dart';
import 'package:expensely_app/services/shared_prefs_service.dart';
import 'package:expensely_app/widgets/currency_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  String _currencySymbol = SharedPrefService.getCurrency(); // Default currency symbol

  void _saveNameAndNavigate() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _currencyController.text.isNotEmpty) {
      await SharedPrefService.saveData('userName', name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(name.isEmpty ? 'Please enter your name' : 'Please select a currency'),
        ),
      );
    }
  }

  Future<void> _showCurrencyPicker() async {
    showDialog(
      context: context,
      builder: (context) => CurrencyPickerDialog(
        currencies: currencies,
        showConfirmationDialog: false,
        selectedSymbol: _currencySymbol,
        onSelected: (newSymbol) {
          _saveCurrency(newSymbol);
        },
      ),
    );
  }

  Future<void> _saveCurrency(String newSymbol) async {
    await SharedPrefService.saveData('currencySymbol', newSymbol);
    _currencyController.text = newSymbol; // Update the text field with the new symbol
    if (mounted) {
      setState(() {
        _currencySymbol = newSymbol;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _currencyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/expensemanager_logo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Save your money with\nExpense Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Save money! The more your money works for you, the less you have to work for money.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 60),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey, // 🟢 outline color when not focused
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF127A64), // 🟢 outline color when focused
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: _showCurrencyPicker,
                    child: TextField(
                      controller: _currencyController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Select your currency',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey, // 🟢 outline color when not focused
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF127A64), // 🟢 outline color when focused
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF127A64),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveNameAndNavigate,
                      child: const Text(
                        "Let's Start",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
