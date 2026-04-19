import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _loginKey = 'is_logged_in';
  static const String _cartCountKey = 'cart_count';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<void> saveLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, value);
  }

  Future<void> clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
  }

  Future<int> getCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cartCountKey) ?? 0;
  }

  Future<void> saveCartCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cartCountKey, value);
  }
}
