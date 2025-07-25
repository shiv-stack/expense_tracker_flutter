import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPreferences? _prefs;

  SharedPrefsService._internal();

  static Future<SharedPrefsService> getInstance() async {
    if (_instance == null) {
      _instance = SharedPrefsService._internal();
    }
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Saving user's name
  Future<void> saveUserName(String name) async {
    await _prefs?.setString('userName', name);
  }

  /// Retriving saved user's name
  String? getUserName() {
    return _prefs?.getString('userName');
  }

  /// Clearing all saved preferences (for logout or reset)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
