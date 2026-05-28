// services/auth_service.dart — DEBUG VERSION (FULL LOGGING)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/storage_helper.dart';

class AuthService {
  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  static Future<String?> login({
    required String phone,
    required String password,
    String role = 'patient',
  }) async {
    try {
      final res = await ApiClient.post(Endpoints.login, {
        'phone': phone,
        'password': password,
        'role': role,
      }, auth: false);

      if (!res.success) {
        return res.error ?? 'Échec de connexion';
      }

      final data = res.data as Map<String, dynamic>;

      final token =
          data['token'] ??
          data['refreshToken'] ??
          data['access_token'] ??
          data['data']?['token'] ??
          '';

      if (token.toString().isEmpty) {
        return 'Token non reçu du serveur';
      }

      await StorageHelper.saveToken(token.toString());

      final user =
          (data['user'] ?? data['data']?['user'] ?? data)
              as Map<String, dynamic>;

      await StorageHelper.saveUser(
        nom: user['lastName']?.toString() ?? '',
        prenom: user['firstName']?.toString() ?? '',
        phone: user['phone']?.toString() ?? phone,
        email: user['email']?.toString() ?? '',
        token: user['accessToken']?.toString() ?? '',
        refreshToken: user['refreshToken']?.toString() ?? '',
        patientId: user['_id']?.toString() ?? '',
        userId: user['_id']?.toString() ?? '', // ADDED THIS
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  static Future<String?> register() async {
    final prefs = await SharedPreferences.getInstance();

    final firstName = prefs.getString('prenom');
    final lastName = prefs.getString('nom');
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    final password = prefs.getString('_temp_password');

    final contacts = prefs.getString('emergency_contacts');
    final List<dynamic> contactsList = contacts != null
        ? jsonDecode(contacts)
        : [];

    final requestBody = {
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'dateOfBirth': _toIsoDate(prefs.getString('date_naissance') ?? ''),
      'placeOfBirth': prefs.getString('lieu_naissance') ?? '',
      'gender': _toBackendGender(prefs.getString('genre') ?? ''),
      'address': prefs.getString('adresse') ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'password': password ?? '',
      'role': 'patient',
      'emergencyContacts': contactsList,
    };

    try {
      final res = await ApiClient.post(
        Endpoints.signin,
        requestBody,
        auth: false,
      );

      if (!res.success) {
        return res.error ?? 'Échec de création du compte';
      }

      final data = res.data as Map<String, dynamic>;

      final token =
          data['token'] ??
          data['refreshToken'] ??
          data['access_token'] ??
          data['data']?['token'];

      if (token != null) {
        await StorageHelper.saveToken(token.toString());
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> verifyOtp(String code) async {
    final res = await ApiClient.post(Endpoints.verifyOtp, {'code': code});

    if (!res.success) return res.error ?? 'Code incorrect';
    return null;
  }

  static Future<String?> resendOtp({bool isEmail = true}) async {
    final prefs = await SharedPreferences.getInstance();

    final res = await ApiClient.post(Endpoints.requestOtp, {
      'channel': isEmail ? 'email' : 'phone',
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
    }, auth: false);

    if (!res.success) return res.error ?? 'Échec de renvoi';
    return null;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post(Endpoints.logout, {});
    } catch (e) {}
    await StorageHelper.clear();
  }

  static String _toIsoDate(String dob) {
    if (dob.isEmpty) return '';
    final parts = dob.replaceAll(' ', '').split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dob;
  }

  static String _toBackendGender(String g) {
    final lower = g.toLowerCase();
    if (lower == 'homme' || lower == 'male') return 'male';
    if (lower == 'femme' || lower == 'female') return 'female';
    return 'male';
  }
}
