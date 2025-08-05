import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static SharedPreferences? _prefs;

  // Initialize only once in main
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save data (handles String, int, bool, double)
  static Future<bool> saveData(String key, dynamic value) async {
    if (_prefs == null) return false;

    if (value is String) return await _prefs!.setString(key, value);
    if (value is int) return await _prefs!.setInt(key, value);
    if (value is bool) return await _prefs!.setBool(key, value);
    if (value is double) return await _prefs!.setDouble(key, value);

    throw Exception('Unsupported type');
  }

  // Get data (returns dynamic, you can cast it)
  static dynamic getData(String key) {
    return _prefs?.get(key);
  }

  // Remove specific key
  static Future<bool> clearData(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  // Clear all
  static Future<bool> clearAll() async {
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }

  static String getCurrency() {
    return _prefs?.getString('currencySymbol') ?? '₹'; // Default to ₹ if not set
  }
}
