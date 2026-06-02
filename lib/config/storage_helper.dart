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
    String? userId,
  }) async {
    final p = await _getPrefs();

    // save user id first
    if (userId != null) {
      await p.setString('user_id', userId);
    }

    final uid = userId ?? p.getString('user_id');

  print('UID INSIDE STORAGE: $uid');

    if (uid != null) {
      await p.setString('${uid}_nom', nom);
      await p.setString('${uid}_prenom', prenom);
      await p.setString('${uid}_phone', phone);
      await p.setString('${uid}_email', email);
    }

    if (token != null) {
      await p.setString('token', token);
    }

    if (refreshToken != null) {
      await p.setString('refresh_token', refreshToken);
    }

    if (patientId != null) {
      await p.setString('patient_id', patientId);
    }
  }

  // ── Getters (user-specific)
  // ── Getters (PER USER)
  static Future<String?> getNom() async {
    final p = await _getPrefs();
    final userId = p.getString('user_id');

    if (userId == null) return null;

    return p.getString('${userId}_nom');
  }

  static Future<String?> getPrenom() async {
    final p = await _getPrefs();
    final userId = p.getString('user_id');

    if (userId == null) return null;

    return p.getString('${userId}_prenom');
  }

  static Future<String?> getPatientId() async {
    final p = await _getPrefs();
    final userId = p.getString('user_id');

    if (userId == null) return null;

    return p.getString('${userId}_patient_id');
  }

  static Future<String?> getPhone() async {
    final p = await _getPrefs();
    final userId = p.getString('user_id');

    if (userId == null) return null;

    return p.getString('${userId}_phone');
  }

  static Future<String?> getEmail() async {
    final p = await _getPrefs();
    final userId = p.getString('user_id');

    if (userId == null) return null;

    return p.getString('${userId}_email');
  }

  static Future<String?> getToken() async =>
      (await _getPrefs()).getString('token');

  static Future<String?> getRefreshToken() async =>
      (await _getPrefs()).getString('refresh_token');

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
