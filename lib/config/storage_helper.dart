// storage_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String?> getUserId() async =>
      (await _getPrefs()).getString('user_id');

  // ── Core user fields ──────────────────────────────────────────────────────
  // ✅ MERGED: both `userId` (from HEAD) and `fcmToken` (from incoming) are included.
  static Future<void> saveUser({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    String? token,
    String? refreshToken,
    String? patientId,
    String? userId,      // from HEAD
    String? fcmToken,    // from incoming (e3f67ad)
  }) async {
    final p = await _getPrefs();

    await p.setString('nom', nom);
    await p.setString('prenom', prenom);
    await p.setString('phone', phone);
    await p.setString('email', email);

    if (token != null) await p.setString('token', token);
    if (refreshToken != null) await p.setString('refresh_token', refreshToken);
    if (patientId != null) await p.setString('patient_id', patientId);
    if (userId != null) await p.setString('user_id', userId);       // from HEAD
    if (fcmToken != null) await p.setString('fcm_token', fcmToken); // from incoming
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  static Future<String?> getNom() async =>
      (await _getPrefs()).getString('nom');
  static Future<String?> getPrenom() async =>
      (await _getPrefs()).getString('prenom');
  static Future<String?> getToken() async =>
      (await _getPrefs()).getString('token');
  static Future<String?> getRefreshToken() async =>
      (await _getPrefs()).getString('refresh_token');
  static Future<String?> getPatientId() async =>
      (await _getPrefs()).getString('patient_id');

  // ✅ ADDED: getter for fcm_token (from incoming)
  static Future<String?> getFcmToken() async =>
      (await _getPrefs()).getString('fcm_token');

  // ── Token management (from HEAD) ──────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final p = await _getPrefs();
    await p.setString('token', token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final p = await _getPrefs();
    await p.setString('refresh_token', token);
  }

  // ── Profile image (from HEAD) ─────────────────────────────────────────────
  static Future<void> saveProfileImage(String path) async {
    final p = await _getPrefs();
    await p.setString('profile_image_path', path);
  }

  static Future<String?> getProfileImage() async {
    return (await _getPrefs()).getString('profile_image_path');
  }

  // ── FCM Token separate method (from HEAD) ─────────────────────────────────
  // ⚠️ Note: incoming version also saves fcmToken inside saveUser().
  // Both are kept – this method allows saving token outside of user registration.
  static Future<void> saveFcmToken(String token) async {
    final p = await _getPrefs();
    await p.setString('fcm_token', token);
  }

  // ── Auth check (from HEAD) ────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final p = await _getPrefs();
    return p.getString('token') != null;
  }

  // ── Logout / clear (from HEAD, but enhanced to also remove fcm_token) ─────
  static Future<void> clear() async {
    final p = await _getPrefs();

    await p.remove('token');
    await p.remove('refresh_token');
    await p.remove('user_id');
    await p.remove('patient_id');
    await p.remove('fcm_token'); // ✅ added for completeness
  }
}