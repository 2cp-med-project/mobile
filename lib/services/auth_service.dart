// services/auth_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/storage_helper.dart';
import 'notification_service.dart';

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
      final res = await ApiClient.post(
        Endpoints.login,
        {
          'phone': phone,
          'password': password,
          'role': role,
        },
        auth: false,
      );
      print('🔵 LOGIN RAW RESPONSE: success=${res.success}, data=${res.data}, error=${res.error}');

      if (!res.success) {
        return res.error ?? 'Échec de connexion';
      }

      final data = res.data as Map<String, dynamic>;

      final token = data['token'] ??
          data['refreshToken'] ??
          data['access_token'] ??
          data['data']?['token'] ??
          '';

      if (token.toString().isEmpty) {
        return 'Token non reçu du serveur';
      }

      await StorageHelper.saveToken(token.toString());

      final user = (data['user'] ?? data['data']?['user'] ?? data) as Map<String, dynamic>;

      await StorageHelper.saveUser(
        nom: user['lastName']?.toString() ?? '',
        prenom: user['firstName']?.toString() ?? '',
        phone: user['phone']?.toString() ?? phone,
        email: user['email']?.toString() ?? '',
        token: token.toString(),
        refreshToken: data['refreshToken']?.toString() ?? '',
        patientId: user['_id']?.toString() ?? '',
        userId: user['_id']?.toString() ?? '',
      );

      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await registerFCMTokenToBackend(fcmToken);
      }

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
    final List<dynamic> contactsList = contacts != null ? jsonDecode(contacts) : [];

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

      final token = data['token'] ??
          data['refreshToken'] ??
          data['access_token'] ??
          data['data']?['token'];

      if (token != null) {
        await StorageHelper.saveToken(token.toString());
      }

      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await registerFCMTokenToBackend(fcmToken);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER FCM TOKEN WITH BACKEND
  // ─────────────────────────────────────────────
  static Future<void> registerFCMTokenToBackend(String fcmToken) async {
    try {
      print('🔵 [DEBUG] registerFCMTokenToBackend(fcmToken) STARTED');
      print('🔵 [DEBUG] FCM Token from NotificationService: $fcmToken');

      if (fcmToken.isNotEmpty) {
        print('🔵 [DEBUG] Sending to backend: ${Endpoints.registerFcmToken}');
        print('🔵 [DEBUG] Request body: {"fcmToken": "$fcmToken"}');

        final response = await ApiClient.post(
          Endpoints.registerFcmToken,
          {'fcmToken': fcmToken},
          auth: true,
        );

        print('🔵 [DEBUG] Response success: ${response.success}');
        print('🔵 [DEBUG] Response data: ${response.data}');
        print('🔵 [DEBUG] Response error: ${response.error}');

        if (response.success) {
          print('✅ FCM token sent to backend SUCCESSFULLY');
        } else {
          print('❌ Backend rejected: ${response.error}');
        }
      } else {
        print('⚠️ [DEBUG] FCM token is empty - not sent');
      }
    } catch (e) {
      print('❌ [DEBUG] Exception in registerFCMTokenToBackend: $e');
      print('❌ [DEBUG] Stack trace: ${StackTrace.current}');
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      await NotificationService.deleteToken();
      await ApiClient.post(Endpoints.logout, {});
    } catch (e) {
      print('Logout error: $e');
    }
    await StorageHelper.clear();
  }

  // ─────────────────────────────────────────────
  // OTP (Request & Verify)
  // ─────────────────────────────────────────────
  static Future<String?> requestOtp(String contact, bool isEmail) async {
    final body = {
      'phone': contact,
      'role': 'patient',
    };
    final response = await ApiClient.post(Endpoints.requestOtp, body, auth: false);
    if (response.success) {
      return null;
    }
    return response.error ?? 'Erreur lors de l\'envoi du code';
  }

  static Future<String?> verifyOtp(String code, String phone) async {
    final body = {
      'code': code,
      'role': 'patient',
      'phone': phone,
    };
    final response = await ApiClient.post(Endpoints.verifyOtp, body, auth: false);
    if (response.success) {
      final token = response.data['token'] ?? response.data['access_token'];
      if (token != null) {
        await StorageHelper.saveToken(token);
      }
      return null;
    }
    return response.error ?? 'Code invalide';
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
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