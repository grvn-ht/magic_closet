abstract class CookieService {
  Future<void> setCookie(String key, String value);
  Future<String?> getCookie(String key);
  Future<void> deleteCookie(String key);
}
