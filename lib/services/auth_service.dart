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
      print('================ LOGIN START ================');

      final res = await ApiClient.post(Endpoints.login, {
        'phone': phone,
        'password': password,
        'role': role,
      }, auth: false);

      print('LOGIN RESPONSE: ${res.data}');

      if (!res.success) {
        return res.error ?? 'Échec de connexion';
      }

      final data = res.data as Map<String, dynamic>;

      // Extract token
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

      // Extract user data (supports both '_id' and 'userId')
      final user =
          (data['user'] ?? data['data']?['user'] ?? data)
              as Map<String, dynamic>;
      final userId =
          user['_id']?.toString() ?? user['userId']?.toString() ?? '';

      print('USER ID FOUND: $userId');

      // Save complete user information
      await StorageHelper.saveUser(
        nom: user['lastName']?.toString() ?? '',
        prenom: user['firstName']?.toString() ?? '',
        phone: user['phone']?.toString() ?? phone,
        email: user['email']?.toString() ?? '',
        token: token.toString(),
        refreshToken: data['refreshToken']?.toString(),
        patientId: userId,
        userId: userId,
      );

      print('UID AFTER SAVE: ${await StorageHelper.getUserId()}');

      // Register FCM token if available
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await registerFCMTokenToBackend(fcmToken);
      }

      print('================ LOGIN END ================');
      return null;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return e.toString();
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  static Future<String?> register() async {
    try {
      print('================ REGISTER START ================');

      final prefs = await SharedPreferences.getInstance();

      // READ DIRECTLY FROM SIGNUP FORM DATA
      final firstName =
          prefs.getString('prenom') ?? prefs.getString('firstName') ?? '';

      final lastName =
          prefs.getString('nom') ?? prefs.getString('lastName') ?? '';

      final email = prefs.getString('email') ?? '';

      final phone = prefs.getString('phone') ?? '';

      final password = prefs.getString('_temp_password') ?? '';

      final contacts = prefs.getString('emergency_contacts');

      final List<dynamic> contactsList = contacts != null
          ? jsonDecode(contacts)
          : [];

      print('REGISTER FIRSTNAME: $firstName');
      print('REGISTER LASTNAME: $lastName');
      print('REGISTER EMAIL: $email');
      print('REGISTER PHONE: $phone');
      print('nom = ${prefs.getString('nom')}');
      print('prenom = ${prefs.getString('prenom')}');
      print('phone = ${prefs.getString('phone')}');
      print('email = ${prefs.getString('email')}');
      print('date_naissance = ${prefs.getString('date_naissance')}');
      print('lieu_naissance = ${prefs.getString('lieu_naissance')}');
      print('genre = ${prefs.getString('genre')}');
      print('adresse = ${prefs.getString('adresse')}');
      print('emergency_contacts = ${prefs.getString('emergency_contacts')}');

      final requestBody = {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': _toIsoDate(prefs.getString('date_naissance') ?? ''),
        'placeOfBirth': prefs.getString('lieu_naissance') ?? '',
        'gender': _toBackendGender(prefs.getString('genre') ?? ''),
        'address': prefs.getString('adresse') ?? '',
        'phone': phone,
        'email': email,
        'password': password,
        'role': 'patient',
        'emergencyContacts': contactsList,
      };

      print('REGISTER REQUEST BODY: $requestBody');
      print('REGISTER ENDPOINT: ${Endpoints.signin}');

      final res = await ApiClient.post(
        Endpoints.signin,
        requestBody,
        auth: false,
      );

      print('REGISTER RESPONSE: ${res.data}');
      print('REGISTER SUCCESS: ${res.success}');
      print('REGISTER ERROR: ${res.error}');

      if (!res.success) {
        return res.error ?? 'Échec de création du compte';
      }

      return null;
    } catch (e, stack) {
      print('REGISTER EXCEPTION: $e');
      print(stack);
      return e.toString();
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER FCM TOKEN WITH BACKEND
  // ─────────────────────────────────────────────
  static Future<void> registerFCMTokenToBackend(String fcmToken) async {
    try {
      print('🔵 [DEBUG] registerFCMTokenToBackend STARTED');
      print('🔵 [DEBUG] FCM Token: $fcmToken');

      if (fcmToken.isNotEmpty) {
        print('🔵 [DEBUG] Sending to: ${Endpoints.registerFcmToken}');

        final response = await ApiClient.post(Endpoints.registerFcmToken, {
          'fcmToken': fcmToken,
        }, auth: true);

        print('🔵 [DEBUG] Response success: ${response.success}');

        if (response.success) {
          print('✅ FCM token registered successfully');
        } else {
          print('❌ Backend rejected: ${response.error}');
        }
      } else {
        print('⚠️ FCM token empty - not sent');
      }
    } catch (e) {
      print('❌ Exception in registerFCMTokenToBackend: $e');
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
    final body = {'phone': contact, 'role': 'patient'};
    final response = await ApiClient.post(
      Endpoints.requestOtp,
      body,
      auth: false,
    );
    if (response.success) {
      return null;
    }
    return response.error ?? 'Erreur lors de l\'envoi du code';
  }

  static Future<String?> verifyOtp(String code, String phone) async {
    final body = {'code': code, 'role': 'patient', 'phone': phone};
    final response = await ApiClient.post(
      Endpoints.verifyOtp,
      body,
      auth: false,
    );
    if (response.success) {
      final token = response.data['token'] ?? response.data['access_token'];
      if (token != null) {
        await StorageHelper.saveToken(token);
      }
      return null;
    }
    return response.error ?? 'Code invalide';
  }

  // Optional: resend OTP (if needed by your backend)
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
