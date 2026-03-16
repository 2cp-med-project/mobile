// config/storage_helper.dart
// Local storage — save and get user data using shared_preferences

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {

  // ── Save after successful registration 
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom',    nom);
    await prefs.setString('prenom', prenom);
    await prefs.setString('phone',  phone);
    await prefs.setString('email',  email);
    if (token != null) await prefs.setString('token', token);
  }

  // ── Getters 
  static Future<String?> getNom()    async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nom');
  }

  static Future<String?> getPrenom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('prenom');
  }

  static Future<String?> getToken()  async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ── Save token alone (after login) 
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ── Check if logged in 
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // ── Clear all on logout 
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}