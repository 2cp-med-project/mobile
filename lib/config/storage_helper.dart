// storage_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // USER ID
  // ──────────────────────────────────────────────────────────────────────────
  static Future<String?> getUserId() async =>
      (await _getPrefs()).getString('user_id');

  // ──────────────────────────────────────────────────────────────────────────
  // SAVE USER (with user‑specific fields and optional FCM token)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
    String? refreshToken,
    String? patientId,
    String? userId,
    String? fcmToken,          // from HEAD – keep
  }) async {
    final p = await _getPrefs();

    // Save user id first (global)
    if (userId != null) {
      await p.setString('user_id', userId);
    }

    final uid = userId ?? p.getString('user_id');
    print('UID INSIDE STORAGE: $uid');

    if (uid != null) {
      // User‑specific data stored under the user's ID
      await p.setString('${uid}_nom', nom);
      await p.setString('${uid}_prenom', prenom);
      await p.setString('${uid}_phone', phone);
      await p.setString('${uid}_email', email);
    }

    // Global tokens and identifiers
    if (token != null) await p.setString('token', token);
    if (refreshToken != null) await p.setString('refresh_token', refreshToken);
    if (patientId != null) await p.setString('patient_id', patientId);
    if (fcmToken != null) await p.setString('fcm_token', fcmToken);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GETTERS (user‑specific)
  // ──────────────────────────────────────────────────────────────────────────
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

  // ──────────────────────────────────────────────────────────────────────────
  // GLOBAL GETTERS (tokens, patient id, etc.)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async =>
      (await _getPrefs()).getString('token');

  static Future<String?> getRefreshToken() async =>
      (await _getPrefs()).getString('refresh_token');

  static Future<String?> getPatientId() async =>
      (await _getPrefs()).getString('patient_id');

  static Future<String?> getFcmToken() async =>
      (await _getPrefs()).getString('fcm_token');

  // ──────────────────────────────────────────────────────────────────────────
  // TOKEN MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final p = await _getPrefs();
    await p.setString('token', token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final p = await _getPrefs();
    await p.setString('refresh_token', token);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PROFILE IMAGE
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveProfileImage(String path) async {
    final p = await _getPrefs();
    await p.setString('profile_image_path', path);
  }

  static Future<String?> getProfileImage() async {
    return (await _getPrefs()).getString('profile_image_path');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FCM TOKEN (separate method for cases where user is not yet saved)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveFcmToken(String token) async {
    final p = await _getPrefs();
    await p.setString('fcm_token', token);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AUTHENTICATION CHECK
  // ──────────────────────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final p = await _getPrefs();
    return p.getString('token') != null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLEAR ALL DATA (logout)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> clear() async {
    final p = await _getPrefs();

    await p.remove('token');
    await p.remove('refresh_token');
    await p.remove('user_id');
    await p.remove('patient_id');
    await p.remove('fcm_token');      // ensure FCM token is removed
    // Note: user‑specific prefixed keys (e.g., '123_nom') are not removed
    // because the user ID is gone – they become orphaned but harmless.
    // If you want to clean them, you would need to iterate over all keys.
  }
}