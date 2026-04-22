/* import 'package:shared_preferences/shared_preferences.dart'; //local storage 

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
} */
// config/storage_helper.dart  — UPDATED
// Added: saveRefreshToken, getRefreshToken, savePatientId, getPatientId


//integrated with backend

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Core user fields ──────────────────────────────────────────────────────
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
    String? refreshToken,
    String? patientId,
  }) async {
    final p = await _getPrefs();
    await p.setString('nom',    nom);
    await p.setString('prenom', prenom);
    await p.setString('phone',  phone);
    await p.setString('email',  email);
    if (token        != null) await p.setString('token',         token);
    if (refreshToken != null) await p.setString('refresh_token', refreshToken);
    if (patientId    != null) await p.setString('patient_id',    patientId);
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  static Future<String?> getNom()          async => (await _getPrefs()).getString('nom');
  static Future<String?> getPrenom()       async => (await _getPrefs()).getString('prenom');
  static Future<String?> getToken()        async => (await _getPrefs()).getString('token');
  static Future<String?> getRefreshToken() async => (await _getPrefs()).getString('refresh_token');
  static Future<String?> getPatientId()    async => (await _getPrefs()).getString('patient_id');

  // ── Token management ──────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final p = await _getPrefs();
    await p.setString('token', token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final p = await _getPrefs();
    await p.setString('refresh_token', token);
  }

  // ── Auth check ────────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final p = await _getPrefs();
    return p.getString('token') != null;
  }

  // ── Clear all (logout) ────────────────────────────────────────────────────
  static Future<void> clear() async {
    final p = await _getPrefs();
    await p.clear();
  }
}