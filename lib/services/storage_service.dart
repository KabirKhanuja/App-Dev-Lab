import 'package:shared_preferences/shared_preferences.dart';

// this file is basically the shared preferences of my app

class StorageService {
  static const String _loginKey = 'is_logged_in';
  static const String _cartCountKey = 'cart_count';
  static const String _darkModeKey = 'is_dark_mode';

  Future<bool> isLoggedIn() async {
    // LAB 9: Retrieve saved preference values from local storage
    // This reads a small flag from device storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<void> saveLoginStatus(bool value) async {
    // LAB 9: Persist login status for session recovery
    // It stores whether the user has already logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, value);
  }

  Future<void> clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
  }

  Future<int> getCartCount() async {
    // LAB 9: Read saved cart count preference
    // We restore previous cart count to keep continuity after app restart
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cartCountKey) ?? 0;
  }

  Future<void> saveCartCount(int value) async {
    // LAB 9: Store cart count locally
    // This makes the cart badge persist across launches
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cartCountKey, value);
  }

  Future<bool> isDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
