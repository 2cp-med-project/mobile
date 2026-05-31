//integrated with backend

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String?> getUserId() async =>
      (await _getPrefs()).getString('user_id');

  // ── Core user fields
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
    String? refreshToken,
    String? patientId,
    String? userId, // NEW
  }) async {
    final p = await _getPrefs();

    await p.setString('nom', nom);
    await p.setString('prenom', prenom);
    await p.setString('phone', phone);
    await p.setString('email', email);

    if (token != null) {
      await p.setString('token', token);
    }

    if (refreshToken != null) {
      await p.setString('refresh_token', refreshToken);
    }

    if (patientId != null) {
      await p.setString('patient_id', patientId);
    }

    if (userId != null) {
      await p.setString('user_id', userId);
    }
  }

  // ── Getters
  static Future<String?> getNom() async => (await _getPrefs()).getString('nom');
  static Future<String?> getPrenom() async =>
      (await _getPrefs()).getString('prenom');
  static Future<String?> getToken() async =>
      (await _getPrefs()).getString('token');
  static Future<String?> getRefreshToken() async =>
      (await _getPrefs()).getString('refresh_token');
  static Future<String?> getPatientId() async =>
      (await _getPrefs()).getString('patient_id');

  // ── Token management
  static Future<void> saveToken(String token) async {
    final p = await _getPrefs();
    await p.setString('token', token);
  }

  // ── Profile image 
  static Future<void> saveProfileImage(String path) async {
    final p = await _getPrefs();
    await p.setString('profile_image_path', path);
  }

  static Future<String?> getProfileImage() async {
    return (await _getPrefs()).getString('profile_image_path');
  }

  static Future<void> saveRefreshToken(String token) async {
    final p = await _getPrefs();
    await p.setString('refresh_token', token);
  }

  // ── Auth check
  static Future<bool> isLoggedIn() async {
    final p = await _getPrefs();
    return p.getString('token') != null;
  }

  // ── (logout)
  static Future<void> clear() async {
  final p = await _getPrefs();

  await p.remove('token');
  await p.remove('refresh_token');
  await p.remove('user_id');
  await p.remove('patient_id');
}
}
