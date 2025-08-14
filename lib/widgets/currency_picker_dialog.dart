import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/models/currency.dart';
import 'package:flutter/material.dart';

class CurrencyPickerDialog extends StatefulWidget {
  final List<Currency> currencies;
  final String selectedSymbol;
  final ValueChanged<String> onSelected;
  final bool? showConfirmationDialog;
  const CurrencyPickerDialog(
      {super.key,
      required this.currencies,
      required this.selectedSymbol,
      required this.onSelected,
      this.showConfirmationDialog = true});

  @override
  CurrencyPickerDialogState createState() => CurrencyPickerDialogState();
}

class CurrencyPickerDialogState extends State<CurrencyPickerDialog> {
  late TextEditingController _searchController;
  late List<Currency> _filteredCurrencies;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCurrencies = widget.currencies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = widget.currencies
          .where((c) => c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showConfirmDialog(Currency currency) {
    // If the selected currency is already the current one, do nothing.
    if (currency.symbol == widget.selectedSymbol) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Currency Change'),
        content: const Text(
            'When you change the default currency, historical data will not be converted based on exchange rates.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              widget.onSelected(currency.symbol);
              Navigator.of(dialogContext).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close picker dialog
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Select Currency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by name or code...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected = currency.symbol == widget.selectedSymbol;
                return ListTile(
                  title: Text('${currency.name} (${currency.code})'),
                  trailing: isSelected ? const Icon(Icons.check, color: primaryColor) : null,
                  tileColor: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: widget.showConfirmationDialog!
                      ? () => _showConfirmDialog(currency)
                      : () {
                          widget.onSelected(currency.symbol);
                          Navigator.of(context).pop();
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
