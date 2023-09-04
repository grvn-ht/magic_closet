import 'package:flutter_application_1/cookies/service.dart';
import 'package:universal_html/html.dart' as html;

class WebCookieService implements CookieService {
  @override
  Future<void> setCookie(String key, String value) async {
    final cookies = "$key=$value; max-age=3600";
    html.document.cookie = cookies;
  }

  @override
  Future<String?> getCookie(String key) async {
    final cookies = html.document.cookie;
    if (cookies != null) {
      final cookieParts = cookies.split('; ');
      for (final cookie in cookieParts) {
        final parts = cookie.split('=');
        if (parts.length == 2 && parts[0] == key) {
          final extractedCookie = parts[1];
          return extractedCookie;
        }
      }
    }
    return null;
  }

  @override
  Future<void> deleteCookie(String key) async {
    html.document.cookie =
        '$key=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
  }
}
