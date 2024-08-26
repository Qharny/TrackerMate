import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // Get a boolean value
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // Save a string value
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // Get a string value
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // Save an integer value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // Get an integer value
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  // Save a double value
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // Get a double value
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // Save a list of strings
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // Get a list of strings
  static List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  // Remove a value
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all data
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // Check if a key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // Get all keys
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // Specifically for login status
  static bool isLoggedIn() {
    return getBool('isLoggedIn', defaultValue: false);
  }

  static Future<bool> setLoggedIn(bool value) async {
    return await setBool('isLoggedIn', value);
  }

  // Example of storing user data
  static Future<bool> setUserData(Map<String, dynamic> userData) async {
    return await setString('userData', userData.toString());
  }

  static Map<String, dynamic> getUserData() {
    String userDataString = getString('userData');
    // This is a simple conversion. In a real app, you might want to use json encoding/decoding
    return userDataString.isNotEmpty ? Map<String, dynamic>.from(userDataString as Map) : {};
  }
}