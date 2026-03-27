import 'package:shared_preferences/shared_preferences.dart'; //local storage 

class StorageHelper {

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Save after successful registration 
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
  }) async {
    final prefs = await _getPrefs(); 
    await prefs.setString('nom', nom);
    await prefs.setString('prenom', prenom);
    await prefs.setString('phone', phone);
    await prefs.setString('email', email);
    if (token != null) await prefs.setString('token', token);
  }

  // ── Getters 
  static Future<String?> getNom() async {
    final prefs = await _getPrefs(); 
    return prefs.getString('nom');
  }

  static Future<String?> getPrenom() async {
    final prefs = await _getPrefs();
    return prefs.getString('prenom');
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('token');
  }

  // ── Save token alone 
  static Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString('token', token);
  }

  // ── Check login 
  static Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getString('token') != null;
  }

  // ── Clear 
  static Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}