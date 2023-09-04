import 'package:flutter_application_1/cookies/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCookieService implements CookieService {
  @override
  Future<void> setCookie(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getCookie(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> deleteCookie(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
