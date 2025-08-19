import 'package:expensely_app/Screens/category_mgmt_screen.dart';
import 'package:expensely_app/Screens/more_apps_screen.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/models/currency.dart';
import 'package:expensely_app/services/shared_prefs_service.dart';
import 'package:expensely_app/widgets/currency_picker_dialog.dart';
import 'package:expensely_app/widgets/edit_name_dialog.dart';
import 'package:expensely_app/widgets/premimum_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PackageInfo? _packageInfo;
  String _userName = 'User';
  String _currencySymbol = SharedPrefService.getCurrency(); // Default currency symbol

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initializeInfo();
  }

  Future<void> _loadUserName() async {
    if (mounted) {
      setState(() {
        _userName = SharedPrefService.getData('userName') ?? 'User'; // Provide a default value
      });
    }
  }

  Future<void> _saveUserName(String newName) async {
    await SharedPrefService.saveData('userName', newName);
    if (mounted) {
      setState(() {
        _userName = newName;
      });
    }
  }

  Future<void> _saveCurrency(String newSymbol) async {
    context.read<ExpenseBloc>().add(LoadTransactions());
    await SharedPrefService.saveData('currencySymbol', newSymbol);
    if (mounted) {
      setState(() {
        _currencySymbol = newSymbol;
      });
    }
  }

  Future<void> _initializeInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  void _shareApp() {
    // Customize the text and link to your app
    final String appLink =
        "https://play.google.com/store/apps/details?id=com.shivam.expensely_app"; // Replace with your app's link
    final String shareText = "Check out Expensely, the best app for tracking your finances!\n\n$appLink";
    ShareParams params = ShareParams(
      text: shareText,
      subject: 'Discover Expensely!',
    );

    SharePlus.instance.share(params);
  }
  // No changes needed for imports or your main widget state class.
// This is just the updated method and the new private widget to add.

  Future<void> _showEditNameDialog() async {
    // This method now simply shows our new stateful dialog widget.
    return showDialog<void>(
      context: context,
      // The builder now returns our custom widget that handles the controller.
      builder: (BuildContext context) {
        return EditNameDialog(
          initialName: _userName,
          onSave: (newName) {
            _saveUserName(newName);
          },
        );
      },
    );
  }

  Future<void> _showCurrencyPicker() async {
    showDialog(
      context: context,
      builder: (context) => CurrencyPickerDialog(
        currencies: currencies,
        selectedSymbol: _currencySymbol,
        onSelected: (newSymbol) {
          _saveCurrency(newSymbol);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, _userName),
              const SizedBox(height: 32),
              _buildSectionTitle("Account"),
              _buildProfileCard(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: _showEditNameDialog,
                  ),
                  _buildProfileOption(
                    icon: Icons.attach_money_outlined,
                    title: 'Update Currency',
                    subtitle: 'Current: $_currencySymbol', // Display current currency
                    onTap: _showCurrencyPicker,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle("General"),
              _buildProfileCard(
                children: [
                  _buildProfileOption(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Premimum',
                    onTap: () {
                      showPremiumBottomSheet(context);
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.category_rounded,
                    title: 'Manage Categories',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryManagerScreen(),
                        ),
                      );
                    },
                  ),

                  // UPDATED: The onTap now calls the _shareApp method
                  _buildProfileOption(
                    icon: Icons.share_outlined,
                    title: 'Share with Friends',
                    onTap: _shareApp,
                  ),

                  _buildProfileOption(
                      icon: Icons.apps_outlined,
                      title: 'More Apps',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MoreAppsScreen()),
                        );
                      }),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: _packageInfo != null ? 'Version ${_packageInfo!.version}' : 'Loading...',
                    onTap: () {
                      if (_packageInfo != null) {
                        _showCustomAboutDialog(context, _packageInfo!);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // No changes needed for the rest of the helper methods
  void _showCustomAboutDialog(BuildContext context, PackageInfo packageInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(packageInfo.appName),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Version: ${packageInfo.version}'),
              const SizedBox(height: 10),
              const Text('© 2025 AI Developers'),
              const SizedBox(height: 20),
              const Text('The best app to track your expenses.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: primaryColor,
          child: Image.asset(
            'assets/avatar.png',
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Manage your profile',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    );
  }
}
